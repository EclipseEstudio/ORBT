extends SceneTree

const Carregador = preload("res://src/Nivel/carregador_fase.gd")
const CenaNave = preload("res://src/Nave/Nave.tscn")
const Partida = preload("res://src/ControladorJogo/partida.gd")
const Documento = preload("res://addons/orbt_editor/documento.gd")
const Mapa = preload("res://addons/orbt_editor/mapa.gd")
const DELTA = 1.0 / 60.0
var verificacoes := 0
var falhas := 0


func _initialize() -> void:
	_executar.call_deferred()


func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)


func testar_contrato(dados: Dictionary) -> void:
	var legado := Carregador.validar(dados)
	conferir(legado.nivel != null and legado.nivel.obter_posicao_inicial().is_equal_approx(Vector2(90, 222)), "Início legado mantém apoio e posição")
	var livre: Dictionary = dados.duplicate(true)
	livre.start = {"position": [90, 400]}
	var resultado := Carregador.validar(livre)
	conferir(resultado.nivel != null and resultado.nivel.obter_posicao_inicial() == Vector2(90, 400), "Início livre aceita coordenadas autorais")
	conferir(resultado.nivel.dados_autorais.start.position == [90, 400] and resultado.nivel.inicio.position is Array, "Validação mantém arrays autorais sem mutação")
	for valor in [[0], [0, 0, 0], [NAN, 0], [true, 0], "90,400", null]:
		var copia := livre.duplicate(true)
		copia.start.position = valor
		conferir(Carregador.validar(copia).nivel == null, "Posição inicial inválida rejeitada: %s" % str(valor))
	for campo in ["body_id", "angle_degrees"]:
		var copia := livre.duplicate(true)
		copia.start[campo] = "origem" if campo == "body_id" else -90
		conferir(Carregador.validar(copia).nivel == null, "Início livre não mistura " + campo)
	for posicao in [[-181, 400], [90, 601], [90, 250], [90, 282], [90, 60]]:
		var copia := livre.duplicate(true)
		copia.start.position = posicao
		conferir(Carregador.validar(copia).nivel == null, "Início fora dos limites ou dentro de contato é rejeitado: %s" % str(posicao))
	var perigos := livre.duplicate(true)
	var asteroide: Dictionary = perigos.bodies[2].duplicate(true)
	asteroide.id = "outro_asteroide"
	asteroide.position = [-37, 100]
	perigos.bodies.append(asteroide)
	conferir(Carregador.validar(perigos).nivel != null, "Asteroides sobrepostos podem formar muros")
	asteroide.type = "sun"
	asteroide.mass = 100
	conferir(Carregador.validar(perigos).nivel != null, "Sobreposição entre dois tipos de perigo também é válida")
	asteroide.position = perigos.bodies[0].position.duplicate()
	conferir(Carregador.validar(perigos).nivel == null, "Sobreposição entre perigo e apoio continua rejeitada")
	var seguros := livre.duplicate(true)
	seguros.bodies[1].position = seguros.bodies[0].position.duplicate()
	conferir(Carregador.validar(seguros).nivel == null, "Sobreposição entre apoios continua rejeitada")
	for valor in [0, -1, 5, NAN, true, "0.5"]:
		var copia := livre.duplicate(true)
		copia.camera = {"zoom": valor}
		conferir(Carregador.validar(copia).nivel == null, "Zoom inválido rejeitado: %s" % str(valor))
	for visao in [null, {}, {"position": [0, 0], "size": [0, 600]}, {"position": [0, INF], "size": [900, 600]}]:
		var copia := livre.duplicate(true)
		copia.camera = {"overview": visao}
		conferir(Carregador.validar(copia).nivel == null, "Visão geral inválida rejeitada")
	var com_camera := livre.duplicate(true)
	com_camera.camera = {"zoom": 0.5, "overview": {"position": [-30, -30], "size": [960, 660]}}
	conferir(Carregador.validar(com_camera).nivel != null, "Câmera autoral opcional aceita zoom e visão geral")


func _executar() -> void:
	var dados: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://Recursos/Fases/teste_001.json"))
	testar_contrato(dados)
	dados.start = {"position": [90, 400]}
	var nivel: NivelRes = Carregador.validar(dados).nivel
	var nave = CenaNave.instantiate()
	root.add_child(nave)
	var partida = Partida.new()
	root.add_child(partida)
	partida.set_physics_process(false)
	partida.iniciar(nivel, nave)
	conferir(nave.condicao == nave.Condicao.PRONTA and nave.corpo_apoio.is_empty() and nave.origem_decolagem.is_empty(), "Início livre aguarda impulso sem apoio fictício")
	partida.avancar(10)
	conferir(nave.global_position == Vector2(90, 400) and nave.velocidade == Vector2.ZERO and partida.tempo_restante == 30, "Aguardar no espaço não aplica gravidade nem conta tempo")
	nave.entrada.gesto.iniciar(0, Vector2(90, 140))
	nave.entrada.gesto.mover(0, Vector2(10, 140))
	var previa: PackedVector2Array = nave.prever_trajetoria()
	conferir(previa.size() > 1 and previa[0] == Vector2(90, 400), "Prévia parte da posição livre antes do lançamento")
	nave.entrada.cancelar()
	conferir(nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2(80, 0)), "Primeiro impulso livre é aceito")
	for passo in range(3):
		partida.avancar(DELTA)
	conferir(nave.condicao == nave.Condicao.EM_VOO and nave.combustivel == 4 and partida.temporizador_ativo, "Primeiro lançamento ativa voo, tempo e uma cobrança")
	conferir(nave.global_position.distance_to(previa[1]) < 0.001, "Prévia e voo coincidem depois do início livre")
	conferir(nave.velocidade.y < 0 and not nave.global_position.is_equal_approx(Vector2(94, 400)), "Gravidade passa a atuar após o lançamento")
	nave.pousar(nivel.obter_corpo("origem"))
	partida.reiniciar()
	conferir(nave.condicao == nave.Condicao.PRONTA and nave.global_position == Vector2(90, 400) and nave.velocidade == Vector2.ZERO and nave.combustivel == 5 and nave.corpo_apoio.is_empty() and nave.posicao_relativa == Vector2.ZERO, "Reinício após pouso restaura início livre sem vínculo residual")
	var documento := Documento.new()
	documento.dados = dados.duplicate(true)
	var mapa := Mapa.new()
	mapa.documento = documento
	mapa.size = Vector2(540, 800)
	root.add_child(mapa)
	mapa.enquadrar()
	conferir(mapa.mundo(mapa.tela(nivel.obter_posicao_inicial())).distance_to(Vector2(90, 400)) < 0.001, "Mapa do editor usa a mesma posição inicial")
	mapa.queue_redraw()
	await process_frame
	mapa.queue_free()
	nave.queue_free()
	partida.queue_free()
	await process_frame
	print("Início livre: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
