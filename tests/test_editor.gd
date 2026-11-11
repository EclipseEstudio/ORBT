extends SceneTree

const Documento = preload("res://addons/orbt_editor/documento.gd")
const Painel = preload("res://addons/orbt_editor/painel.gd")
const Carregador = preload("res://src/Nivel/carregador_fase.gd")
const Teste = preload("res://addons/orbt_editor/teste.gd")
var verificacoes := 0
var falhas := 0


func _initialize() -> void:
	_executar.call_deferred()


func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)


func _executar() -> void:
	testar_historico()
	await testar_correcoes()
	var itens: Array = load("res://src/Campanha/catalogo.gd").carregar("res://Recursos/Niveis.json").itens
	for item in itens:
		var fase := Documento.new()
		conferir(fase.abrir(item.arquivo).is_empty() and fase.validar().nivel != null and not fase.modificado(), item.id + ": abre e valida no editor sem alterações")
	var documento := Documento.new()
	var original := FileAccess.get_file_as_string(Documento.EXEMPLO)
	conferir(documento.abrir(Documento.EXEMPLO).is_empty(), "Abre exemplo pelo carregador comum")
	conferir(not documento.modificado(), "Abertura não marca documento alterado")
	var dados: Dictionary = documento.dados.duplicate(true)
	documento.selecionar(0)
	conferir(not documento.modificado(), "Seleção não altera dados")
	var posicao := Vector2(91.123456789, 250)
	documento.mover(0, posicao)
	conferir(documento.dados.bodies[0].id == dados.bodies[0].id and documento.modificado(), "Mover preserva ID e marca alteração")
	documento.editar(["bodies", 0, "id"], "novo_apoio")
	conferir(documento.dados.start.body_id == "novo_apoio", "Renomear apoio atualiza referência")
	documento.editar(["initial_fuel"], 3)
	documento.editar(["flight_timeout"], 45)
	conferir(documento.validar().nivel.combustivel_inicial == 3 and documento.validar().nivel.tempo_voo == 45, "Propriedades usam parâmetros por fase")
	var destino := "res://.godot/teste-editor-fase.json"
	conferir(documento.salvar(destino).is_empty() and not documento.modificado(), "Salvar limpa marca de alteração")
	var outro := Documento.new()
	conferir(outro.abrir(destino).is_empty() and outro.dados == JSON.parse_string(JSON.stringify(documento.dados, "", true, true)), "Reabrir mantém todos os parâmetros")
	conferir(absf(outro.dados.bodies[0].position[0] - posicao.x) < 0.0000000001, "Gravação mantém precisão numérica")
	documento.editar(["name"], "Sobrescrita")
	conferir(documento.salvar(destino).is_empty() and outro.abrir(destino).is_empty() and outro.dados == JSON.parse_string(JSON.stringify(documento.dados, "", true, true)), "Substituição mantém parâmetros")
	documento.mover(0, Vector2(90, 250))
	var antes := documento.dados.duplicate(true)
	conferir(not documento.abrir("res://.godot/ausente.json").is_empty() and documento.dados == antes, "Falha de abertura preserva edição")
	var invalido := FileAccess.open("res://.godot/editor-invalido.json", FileAccess.WRITE)
	invalido.store_string("{")
	invalido.close()
	conferir(not documento.abrir("res://.godot/editor-invalido.json").is_empty() and documento.dados == antes, "JSON malformado preserva documento")
	conferir(not documento.salvar("res://.godot/pasta-inexistente/fase.json").is_empty() and documento.modificado(), "Falha de gravação mantém trabalho sujo")
	documento.inserir("planet", Vector2(1000, 1000))
	var id: String = documento.objeto(documento.selecao).id
	documento.inserir("planet", Vector2(1100, 1000))
	conferir(documento.objeto(documento.selecao).id != id, "Inserção gera IDs únicos")
	documento.excluir()
	conferir(documento.selecao == -2 and documento.dados.bodies.size() == dados.bodies.size() + 1, "Excluir limpa seleção e objeto correto")
	documento.selecionar(0)
	documento.excluir()
	conferir(documento.validar().nivel == null and not documento.validar().erros.is_empty(), "Excluir origem aponta referência inválida")
	conferir(not documento.exportar_teste("res://.godot/teste-editor-bloqueado.json").is_empty(), "Teste inválido bloqueado antes da construção")
	documento.abrir(Documento.EXEMPLO)
	var teste := "res://.godot/orbt-editor-preview.json"
	conferir(documento.exportar_teste(teste).is_empty(), "Teste gera cópia independente")
	var nivel = Carregador.carregar(teste).nivel
	nivel.corpos[0].position = Vector2.ZERO
	nivel.combustivel_inicial = 0
	conferir(documento.dados == dados and FileAccess.get_file_as_string(Documento.EXEMPLO) == original, "Simulação não modifica edição nem JSON autoral")
	documento.mover(1, Vector2(160, 250))
	conferir(documento.validar().nivel != null and not documento.validar().avisos.is_empty(), "Passagem estreita é aviso não bloqueante")
	for ciclo in range(2):
		var painel := Painel.new()
		painel.persistir_sessao = false
		root.add_child(painel)
		await process_frame
		conferir(painel.documento.dados == dados and painel.mapa.get_child_count() == 0, "Editor desenha sem instanciar física")
		painel.documento.selecionar(-1)
		painel.documento.mover(-1, Vector2(100, 60))
		conferir(painel._propriedades.get_child_count() > 0 and painel.documento.dados.goal.position == [100.0, 60.0], "Seleção e edição da Terra atualizam painel")
		painel.queue_free()
		await process_frame
		conferir(not is_instance_valid(painel), "Ciclo libera painel e sinais")
	var rascunho := "res://.godot/editor-teste-rascunho.json"
	if FileAccess.file_exists(rascunho):
		DirAccess.remove_absolute(rascunho)
	var painel_rascunho := Painel.new()
	painel_rascunho.caminho_rascunho = rascunho
	root.add_child(painel_rascunho)
	painel_rascunho.documento.selecionar(0)
	painel_rascunho.documento.editar(["initial_fuel"], 3)
	painel_rascunho.queue_free()
	await process_frame
	painel_rascunho = Painel.new()
	painel_rascunho.caminho_rascunho = rascunho
	root.add_child(painel_rascunho)
	conferir(painel_rascunho.documento.modificado() and painel_rascunho.documento.selecao == 0 and painel_rascunho.documento.dados.initial_fuel == 3, "Rascunho restaura alterações e seleção")
	painel_rascunho.documento.salvar(destino)
	painel_rascunho.queue_free()
	await process_frame
	painel_rascunho = Painel.new()
	painel_rascunho.caminho_rascunho = rascunho
	root.add_child(painel_rascunho)
	conferir(not painel_rascunho.documento.modificado(), "Rascunho salvo restaura sem alteração fantasma")
	painel_rascunho.queue_free()
	await process_frame
	documento.abrir(Documento.EXEMPLO)
	documento.exportar_teste(teste)
	var jogo := Teste.new()
	root.add_child(jogo)
	await process_frame
	var partida = jogo.nivel.partida
	partida.set_physics_process(false)
	jogo.nivel.camera._process(2.0)
	var nave = jogo.nivel.get_node("Nave")
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	conferir(nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2(0, -80)), "Teste joga com controle de produção")
	for passo in range(180):
		partida.avancar(1.0 / 60)
	conferir(partida.estado == partida.Estado.CONCLUIDA and nave.combustivel == 4, "Mesma rota vence no teste do editor")
	partida.reiniciar()
	nave.condicao = nave.Condicao.EM_VOO
	nave.global_position = Vector2(10000, 10000)
	partida.temporizador_ativo = true
	partida.tempo_restante = 0.001
	partida.avancar(1.0 / 60)
	conferir(partida.estado == partida.Estado.PERDIDA and partida.motivo == "Oxigênio esgotado", "Teste do editor permite derrota por oxigênio no espaço aberto")
	conferir(documento.dados == dados and FileAccess.get_file_as_string(Documento.EXEMPLO) == original, "Vitória, reinício e derrota preservam dados")
	jogo.queue_free()
	await process_frame
	print("Editor: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)


func testar_historico() -> void:
	var documento := Documento.new()
	documento.abrir(Documento.EXEMPLO)
	var original := documento.dados.duplicate(true)
	conferir(not documento.pode_desfazer() and not documento.pode_refazer(), "Abrir fase começa sem histórico anterior")
	documento.selecionar(0)
	documento.iniciar_grupo()
	documento.mover(0, Vector2(100, 200))
	documento.mover(0, Vector2(110, 210))
	documento.terminar_grupo()
	conferir(documento.desfazer() and documento.dados == original and not documento.modificado(), "Desfazer um arraste recupera fase salva inteira")
	conferir(documento.refazer() and documento.dados.bodies[0].position == [110.0, 210.0] and documento.modificado(), "Refazer recupera posição final do arraste")
	documento.desfazer()
	documento.editar(["name"], "Outra edição")
	conferir(not documento.pode_refazer(), "Nova edição substitui caminho de refazer")
	documento.selecionar(0)
	var quantidade: int = documento.dados.bodies.size()
	conferir(documento.duplicar(), "Duplicar cria cópia do corpo selecionado")
	var copia := documento.objeto(documento.selecao)
	conferir(documento.dados.bodies.size() == quantidade + 1 and copia.id != original.bodies[0].id and copia.position == [original.bodies[0].position[0] + 40, original.bodies[0].position[1] + 40], "Cópia tem ID novo e deslocamento sem alterar origem")
	conferir(documento.desfazer() and documento.dados.bodies.size() == quantidade, "Desfazer remove somente a cópia")
	documento.abrir("res://Recursos/Fases/demo_portais.json")
	documento.selecionar(0)
	conferir(documento.duplicar(Vector2(0, 60)), "Duplicar portal cria par")
	var primeiro: Dictionary = documento.dados.bodies[-2]
	var segundo: Dictionary = documento.dados.bodies[-1]
	conferir(primeiro.target_id == segundo.id and segundo.target_id == primeiro.id and documento.dados.bodies[0].target_id == documento.dados.bodies[1].id, "Par duplicado preserva ligações próprias e par original")


func clicar(mapa: Control, ponto: Vector2, pressionado: bool) -> void:
	var evento := InputEventMouseButton.new()
	evento.button_index = MOUSE_BUTTON_LEFT
	evento.pressed = pressionado
	evento.position = mapa.tela(ponto)
	mapa._gui_input(evento)


func mover_mouse(mapa: Control, ponto: Vector2) -> void:
	var evento := InputEventMouseMotion.new()
	evento.position = mapa.tela(ponto)
	mapa._gui_input(evento)


func testar_correcoes() -> void:
	var painel := Painel.new()
	painel.persistir_sessao = false
	root.add_child(painel)
	await process_frame
	var doc = painel.documento
	doc.selecionar(1)
	conferir(painel._propriedades.get_node("RotacaoAtiva").button_pressed and not doc.modificado(), "Checkbox reflete giro padrão sem modificar JSON ao selecionar planeta")
	painel._propriedades.get_node("RotacaoAtiva").button_pressed = false
	conferir(doc.validar().nivel.obter_corpo("apoio").rotation.degrees_per_second == 0 and not painel._propriedades.get_node("RotacaoAtiva").button_pressed, "Desmarcar rotação do planeta desliga giro no carregador do jogo")
	conferir(doc.desfazer() and not doc.dados.bodies[1].has("rotation") and painel._propriedades.get_node("RotacaoAtiva").button_pressed, "Desfazer recupera giro implícito e estado do checkbox")
	conferir(doc.refazer() and doc.validar().nivel.obter_corpo("apoio").rotation.degrees_per_second == 0, "Refazer volta ao giro explicitamente desligado")
	doc.editar(["bodies", 1, "rotation", "initial_degrees"], 45.0)
	painel._propriedades.get_node("RotacaoAtiva").button_pressed = true
	painel._propriedades.get_node("RotacaoAtiva").button_pressed = false
	conferir(doc.dados.bodies[1].rotation.initial_degrees == 45, "Alternar rotação preserva orientação inicial")
	doc.editar(["bodies", 1, "rotation", "degrees_per_second"], -20.0)
	conferir(painel._propriedades.get_node("RotacaoAtiva").button_pressed, "Editar velocidade atualiza checkbox inclusive em giro anti-horário")
	doc.configurar_rotacao(false)
	var destino := "res://.godot/editor-correcao-%d.json" % OS.get_process_id()
	var reaberto := Documento.new()
	conferir(doc.salvar(destino).is_empty() and reaberto.abrir(destino).is_empty() and reaberto.validar().nivel.obter_corpo("apoio").rotation.degrees_per_second == 0, "Salvar/reabrir mantém giro desligado")
	DirAccess.remove_absolute(destino)
	doc.selecionar(-1)
	painel._propriedades.get_node("RotacaoAtiva").button_pressed = false
	conferir(doc.validar().nivel.obter_corpo("terra").rotation.degrees_per_second == 0, "Terra também permite desligar giro padrão")
	doc.selecionar(0)
	conferir(not painel._propriedades.get_node("RotacaoAtiva").button_pressed, "Estação sem giro começa desmarcada")
	painel._propriedades.get_node("RotacaoAtiva").button_pressed = true
	conferir(doc.validar().nivel.obter_corpo("origem").rotation.degrees_per_second == 30, "Ativar rotação da estação cria giro válido")

	doc.abrir("res://Recursos/Fases/demo_orbitas.json")
	doc.editar(["start", "time_seconds"], 3.0)
	var nivel = doc.validar().nivel
	var apoio_inicial: Vector2 = Carregador.Fisica.posicao_corpo(nivel.obter_corpo("origem"), 3.0)
	conferir(doc.posicao_no_inicio(0).is_equal_approx(Vector2(30, 310)) and doc.posicao_no_inicio(0).is_equal_approx(apoio_inicial), "Mapa usa mesmo instante inicial do jogo para o apoio orbital")
	painel.mapa.escala = 1.5
	painel.mapa.centro = Vector2(80, 240)
	var antes: Dictionary = doc.dados.duplicate(true)
	clicar(painel.mapa, apoio_inicial, true)
	conferir(doc.selecao == 0 and painel.mapa.arrastando and doc.dados == antes, "Clique no apoio desenhado seleciona sem alterar os dados")
	mover_mouse(painel.mapa, apoio_inicial + Vector2(18, -15))
	clicar(painel.mapa, apoio_inicial + Vector2(18, -15), false)
	conferir(doc.posicao_no_inicio(0).is_equal_approx(apoio_inicial + Vector2(18, -15)) and doc.dados.bodies[0].orbit == antes.bodies[0].orbit, "Arraste orbital segue mouse sem salto nem mudança de centro/período")
	conferir(doc.desfazer() and doc.dados == antes, "Arraste orbital desfaz em um passo")
	conferir(doc.refazer() and doc.posicao_no_inicio(0).is_equal_approx(apoio_inicial + Vector2(18, -15)), "Refazer restaura posição orbital exibida")
	doc.desfazer()
	# Campo inválido em outro lugar não deve mudar o local onde o corpo é selecionado.
	doc.editar(["initial_fuel"], 0)
	clicar(painel.mapa, apoio_inicial, true)
	conferir(doc.selecao == 0 and painel.mapa.arrastando, "Apoio orbital continua selecionável com erro em outro campo")
	clicar(painel.mapa, apoio_inicial, false)
	doc.desfazer()
	var nave_inicial: Vector2 = doc.validar().nivel.obter_posicao_inicial()
	clicar(painel.mapa, nave_inicial, true)
	conferir(doc.selecao == 0 and painel.mapa.arrastando, "Clique na nave pousada inicia arraste do apoio")
	mover_mouse(painel.mapa, nave_inicial + Vector2(15, -10))
	clicar(painel.mapa, nave_inicial + Vector2(15, -10), false)
	conferir(doc.validar().nivel.obter_posicao_inicial().is_equal_approx(nave_inicial + Vector2(15, -10)) and doc.dados.start == antes.start, "Arrastar nave orbital move apoio e preserva vínculo/ângulo/tempo inicial")
	conferir(doc.desfazer() and doc.dados == antes, "Desfazer arraste da nave recupera apoio e fase inteira")
	var planeta: Vector2 = doc.posicao_no_inicio(1)
	clicar(painel.mapa, planeta, true)
	conferir(doc.selecao == 1, "Seleção também acompanha órbita anti-horária")
	mover_mouse(painel.mapa, planeta + Vector2(12, 8))
	clicar(painel.mapa, planeta + Vector2(12, 8), false)
	conferir(doc.posicao_no_inicio(1).is_equal_approx(planeta + Vector2(12, 8)), "Arraste respeita inversa da órbita anti-horária")

	doc.abrir(Documento.EXEMPLO)
	nave_inicial = doc.validar().nivel.obter_posicao_inicial()
	clicar(painel.mapa, nave_inicial, true)
	mover_mouse(painel.mapa, nave_inicial + Vector2(10, 5))
	clicar(painel.mapa, nave_inicial + Vector2(10, 5), false)
	conferir(doc.dados.bodies[0].position == [100.0, 255.0] and doc.validar().nivel.obter_posicao_inicial().is_equal_approx(nave_inicial + Vector2(10, 5)), "Arrastar nave em apoio estático move apoio pela mesma distância")
	doc.editar(["start"], {"position": [0, 0]})
	antes = doc.dados.duplicate(true)
	clicar(painel.mapa, Vector2.ZERO, true)
	conferir(doc.selecao == -2 and painel.mapa.arrastando, "Nave em início livre é arrastável com propriedades da fase selecionadas")
	mover_mouse(painel.mapa, Vector2(15, 10))
	mover_mouse(painel.mapa, Vector2(30, 20))
	clicar(painel.mapa, Vector2(30, 20), false)
	conferir(doc.dados.start.position == [30.0, 20.0] and doc.dados.bodies == antes.bodies, "Arraste de início livre altera somente posição inicial")
	conferir(doc.desfazer() and doc.dados == antes, "Arraste de início livre inteiro desfaz em um passo")
	conferir(doc.refazer() and doc.dados.start.position == [30.0, 20.0], "Refazer recupera início livre")
	await testar_mapa_renderizado(painel)
	painel.queue_free()
	await process_frame


func testar_mapa_renderizado(painel: Control) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var doc = painel.documento
	doc.abrir("res://Recursos/Fases/demo_rotacao.json")
	doc.editar(["start", "time_seconds"], 3.0)
	conferir(doc.validar().nivel != null, "Cena de renderização com tempo inicial é válida")
	var viewport := SubViewport.new()
	viewport.size = Vector2i(800, 600)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var mapa := Painel.Mapa.new()
	mapa.documento = doc
	mapa.size = Vector2(800, 600)
	mapa.centro = Vector2(80, 240)
	mapa.escala = 2
	for regiao in mapa.regioes:
		mapa.regioes[regiao] = false
	viewport.add_child(mapa)
	await process_frame
	await RenderingServer.frame_post_draw
	var imagem := viewport.get_texture().get_image()
	# Aos 3 s, origem está em (30, 310), com a faixa antes superior voltada à direita.
	var faixa := imagem.get_pixelv(Vector2i(mapa.tela(Vector2(53, 310))))
	conferir(faixa.g > 0.8 and faixa.r < 0.3 and faixa.b < 0.3, "Pixels da faixa confirmam posição orbital e giro no instante inicial")
	var antigo := imagem.get_pixelv(Vector2i(mapa.tela(Vector2(30, 287))))
	conferir(not (antigo.g > 0.8 and antigo.r < 0.3 and antigo.b < 0.3), "Faixa não permanece na orientação do tempo zero")
	viewport.queue_free()
	await process_frame
