extends SceneTree

const C = preload("res://src/Nivel/carregador_fase.gd")
const F = preload("res://src/Nave/simulacao_voo.gd")
const N = preload("res://src/Nave/Nave.tscn")
const P = preload("res://src/ControladorJogo/partida.gd")
const Catalogo = preload("res://src/Campanha/catalogo.gd")
var verificacoes := 0
var falhas := 0

func conferir(ok: bool, mensagem: String) -> void:
	verificacoes += 1
	if not ok:
		falhas += 1
		push_error(mensagem)

func _initialize() -> void:
	executar.call_deferred()

func executar() -> void:
	for item in Catalogo.carregar("res://Recursos/Niveis.json").itens:
		var recurso: NivelRes = C.carregar(item.arquivo).nivel
		var estacao := recurso.obter_corpo(recurso.inicio.body_id)
		conferir(is_zero_approx(float(estacao.get("rotation", {}).get("degrees_per_second", 0.0))), item.id + ": estação de partida sem giro automático")
	var giratoria: NivelRes = C.carregar("res://Recursos/Fases/demo_rotacao.json").nivel
	var apoio_giratorio := giratoria.obter_corpo(giratoria.inicio.body_id)
	var relativo: Vector2 = giratoria.obter_posicao_inicial() - apoio_giratorio.position
	var avancado: Vector2 = relativo.rotated(deg_to_rad(apoio_giratorio.rotation.degrees_per_second) * giratoria.ANTECIPACAO_ESTACAO)
	conferir(avancado.normalized().is_equal_approx(Vector2.UP), "Estação giratória começa a uma fração de segundo da direção de saída")
	var orbital: NivelRes = C.carregar("res://Recursos/Fases/janela_orbital.json").nivel
	conferir(orbital.obter_tempo_inicial() == 4.0 and orbital.obter_posicao_inicial().distance_to(F.posicao_corpo(orbital.obter_corpo("origem"), 4) + Vector2.UP * 30) < 0.001, "Janela orbital começa adiantada, sem esperar quatro segundos")
	var invalidos: Dictionary = orbital.dados_autorais.duplicate(true)
	invalidos.start.time_seconds = -1
	conferir(C.validar(invalidos).nivel == null, "Tempo inicial inválido é rejeitado")
	var nivel: NivelRes = C.carregar("res://Recursos/Fases/teste_001.json").nivel
	var planeta := {"id": "apoio_pesado", "type": "planet", "position": Vector2.ZERO, "mass": 1000000.0, "visual_radius": 20.0, "collision_radius": 20.0, "capture_radius": 40.0, "danger_radius": 0.0, "proximity_radius": 80.0}
	nivel.corpos = [planeta]
	nivel.inicio = {"body_id": planeta.id, "angle_degrees": -90.0}
	nivel.fisica = {"gravity_constant": 1.0, "softening": 8.0}
	nivel.parametros_nave.max_impulse = 100.0
	var nave = N.instantiate()
	root.add_child(nave)
	var p = P.new()
	root.add_child(p)
	p.set_physics_process(false)
	p.iniciar(nivel, nave)
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	var saldo: int = nave.combustivel
	conferir(nave.lancamento_bloqueado(Vector2.DOWN * 100), "Mira identifica lançamento para dentro do apoio")
	conferir(not nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2.DOWN * 100), "Soltar contra o apoio não agenda lançamento")
	p.avancar(1.0 / 60)
	conferir(nave.combustivel == saldo and nave.condicao == nave.Condicao.POUSADA and not p.temporizador_ativo, "Direção bloqueada preserva combustível, pouso e oxigênio")
	nave.entrada.gesto.iniciar(0, Vector2(90, 120))
	nave.entrada.gesto.mover(0, Vector2(90, 40))
	var guia: PackedVector2Array = nave.obter_guia_mira()
	conferir(nave.guia_obstruida and is_equal_approx(guia[0].distance_to(guia[1]), 8), "Guia bloqueada fica curta para desenhar a cruz vermelha")
	nave.entrada.cancelar()
	var rocha := {"id": "rocha", "type": "asteroid", "position": nave.global_position + Vector2.UP * 45, "mass": 0.0, "collision_radius": 5.0, "danger_radius": 5.0, "capture_radius": 0.0, "proximity_radius": 20.0}
	nave.corpos.append(rocha)
	nave.entrada.gesto.iniciar(0, Vector2(90, 120))
	nave.entrada.gesto.mover(0, Vector2(90, 200))
	guia = nave.obter_guia_mira()
	conferir(nave.guia_obstruida and is_equal_approx(guia[0].distance_to(guia[1]), 32), "Guia para no primeiro obstáculo considerando o tamanho da nave")
	nave.entrada.cancelar()
	nave.corpos.pop_back()
	var ponto: Vector2 = nave.global_position
	conferir(F.aceleracao(ponto, [planeta], nivel.fisica).length() > 100, "Cenário reproduz gravidade capaz de prender a nave")
	conferir(F.aceleracao(ponto, [planeta], nivel.fisica, planeta.id, 0, 0.5).is_zero_approx(), "Apoio não atrai durante a folga inicial")
	var retorno := F.aceleracao(ponto, [planeta], nivel.fisica, planeta.id, 0, 1.7)
	var normal := F.aceleracao(ponto, [planeta], nivel.fisica, planeta.id, 0, 3.0)
	conferir(retorno.length() > 0 and retorno.length() < normal.length() and normal.length() <= 12.001, "Gravidade do apoio retorna gradualmente e com força limitada")
	var outro := planeta.duplicate(true)
	outro.id = "outro"
	outro.position = Vector2(200, 0)
	conferir(F.aceleracao(ponto, [planeta, outro], nivel.fisica, planeta.id, 0, 0.5).is_equal_approx(F.aceleracao(ponto, [outro], nivel.fisica)), "Proteção não desliga a gravidade dos demais corpos")
	nave.entrada.gesto.iniciar(0, Vector2(90, 120))
	nave.entrada.gesto.mover(0, Vector2(90, 200))
	var previa: PackedVector2Array = nave.prever_trajetoria()
	nave.entrada.cancelar()
	conferir(nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2.UP * 100), "Lançamento máximo para fora é aceito")
	for i in 3:
		p.avancar(1.0 / 60)
	conferir(previa.size() > 1 and previa[1].distance_to(nave.global_position) < 0.001, "Prévia técnica e voo real compartilham a proteção de saída")
	var inicio_graca: float = nave.tempo_decolagem
	conferir(nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2.RIGHT * 5), "Correção em voo é aceita")
	p.avancar(0)
	conferir(nave.tempo_decolagem == inicio_graca, "Correção não reinicia a proteção da gravidade")
	for i in 177:
		p.avancar(1.0 / 60)
	conferir(p.estado == p.Estado.JOGANDO and nave.condicao == nave.Condicao.EM_VOO and nave.global_position.length() > 250 and nave.velocidade.length() > 70, "Nave escapa do planeta pesado com um lançamento, sem ficar grudada")
	p.reiniciar()
	conferir(nave.tempo_decolagem == -INF and nave.origem_decolagem.is_empty(), "Reinício limpa a proteção de saída")
	nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2.RIGHT * 100)
	p.avancar(1.0 / 60)
	conferir(nave.condicao == nave.Condicao.EM_VOO and nave.global_position.x > 0, "Saída tangencial não gruda na borda de captura")
	p.reiniciar()
	nave.corpos.append(rocha)
	nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2.UP * 100)
	for i in 60:
		p.avancar(1.0 / 60)
	conferir(p.estado == p.Estado.PERDIDA and p.motivo == "Colisão com perigo", "Folga da gravidade não permite atravessar obstáculos")
	p.free()
	nave.free()
	var mundo = load("res://src/Nivel/Nivel.tscn").instantiate()
	mundo.nivel_res = giratoria
	mundo.preferencias = load("res://src/Configuracoes/preferencias.gd").new()
	mundo.preferencias.dicas = false
	root.add_child(mundo)
	await process_frame
	var antes_intro: Vector2 = mundo.partida.nave.global_position
	var tempo_intro: float = mundo.partida.nave.tempo_simulacao
	mundo.partida._physics_process(2.5)
	conferir(mundo.partida.apresentando_fase and mundo.partida.nave.global_position == antes_intro and mundo.partida.nave.tempo_simulacao == tempo_intro, "Título não gasta a janela de saída da estação giratória")
	mundo.find_child("TituloFase", true, false)._encerrar()
	mundo.partida._physics_process(0.1)
	conferir(not mundo.partida.apresentando_fase and mundo.partida.nave.tempo_simulacao > tempo_intro, "Dispensar título libera o movimento da estação")
	mundo.free()
	print("Decolagem: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas else 0)
