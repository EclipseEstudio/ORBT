extends SceneTree
## Executar: godot --headless --path . --script tests/test_controles.gd

const Gesto = preload("res://src/Nave/gesto_mira.gd")
const CenaNave = preload("res://src/Nave/Nave.tscn")
const HUD = preload("res://src/Nivel/interface_partida.gd")

class InterfaceConsomeSoltura extends Control:
	func _gui_input(event: InputEvent) -> void:
		if event is InputEventScreenTouch and not event.pressed:
			accept_event()

var verificacoes := 0
var falhas := 0
var impulsos: Array[Vector2] = []


func _initialize() -> void:
	_executar.call_deferred()


func conferir(condicao: bool, descricao: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(descricao)


func toque(indice: int, ponto: Vector2, pressionado: bool, cancelado := false) -> void:
	var evento := InputEventScreenTouch.new()
	evento.index = indice
	evento.position = ponto
	evento.pressed = pressionado
	evento.canceled = cancelado
	root.push_input(evento, true)


func arrastar(indice: int, ponto: Vector2) -> void:
	var evento := InputEventScreenDrag.new()
	evento.index = indice
	evento.position = ponto
	root.push_input(evento, true)


func mouse(ponto: Vector2, pressionado: bool) -> void:
	var evento := InputEventMouseButton.new()
	evento.button_index = MOUSE_BUTTON_LEFT
	evento.button_mask = MOUSE_BUTTON_MASK_LEFT if pressionado else 0
	evento.position = root.get_final_transform() * ponto
	evento.global_position = evento.position
	evento.pressed = pressionado
	Input.parse_input_event(evento)
	Input.flush_buffered_events()


func mover_mouse(ponto: Vector2) -> void:
	var evento := InputEventMouseMotion.new()
	evento.position = root.get_final_transform() * ponto
	evento.global_position = evento.position
	evento.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(evento)
	Input.flush_buffered_events()


func testar_calculo_e_ciclo() -> void:
	var gesto := Gesto.new()
	conferir(gesto.iniciar(2, Vector2(30, 40)), "Primeiro contato deve iniciar")
	conferir(not gesto.iniciar(3, Vector2.ZERO), "Segundo contato deve ser ignorado")
	gesto.mover(3, Vector2(200, 300))
	conferir(gesto.obter_impulso() == Vector2.ZERO, "Outro dedo não muda a mira")
	conferir(gesto.soltar(3, Vector2.ZERO) == Vector2.ZERO, "Outro dedo não solta a mira")
	conferir(gesto.contato_ativo == 2, "Contato inicial permanece dono do gesto")
	conferir(gesto.soltar(2, Vector2(30, 40)) == Vector2.ZERO, "Toque parado não lança")
	conferir(gesto.contato_ativo == -1 and gesto.origem == Vector2.ZERO, "Soltar limpa ID e origem")
	gesto.iniciar(0, Vector2.ZERO)
	gesto.mover(0, Vector2(10, 0))
	conferir(gesto.obter_impulso() == Vector2.ZERO, "Borda da zona morta não lança")
	gesto.mover(0, Vector2(45, 0))
	conferir(gesto.obter_impulso().is_equal_approx(Vector2(-40, 0)), "Meio da faixa produz meio impulso")
	gesto.mover(0, Vector2(5, 0))
	conferir(gesto.contato_ativo == -1, "Retorno ao círculo cancela imediatamente")
	gesto.mover(0, Vector2(100, 0))
	conferir(gesto.soltar(0, Vector2(100, 0)) == Vector2.ZERO, "Sair novamente exige novo toque")
	gesto.iniciar(0, Vector2.ZERO)
	conferir(gesto.soltar(0, Vector2(80, 0)).is_equal_approx(Vector2(-80, 0)), "Soltura usa posição final mesmo sem drag")
	conferir(gesto.soltar(0, Vector2(80, 0)) == Vector2.ZERO, "Soltura duplicada não lança")
	for direcao in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2(1, 1).normalized()]:
		var impulso := Gesto.calcular_impulso(Vector2.ZERO, direcao * 800.0, 10, 80, 80)
		conferir(impulso.is_equal_approx(-direcao * 80.0), "Saturação e direção: %s" % direcao)
	var deslocado := Gesto.calcular_impulso(Vector2(500, -300), Vector2(545, -300), 10, 80, 80)
	conferir(deslocado.is_equal_approx(Vector2(-40, 0)), "Posição da origem não altera intenção")
	conferir(Gesto.calcular_impulso(Vector2.ZERO, Vector2.INF, 10, 80, 80) == Vector2.ZERO, "Coordenada infinita é rejeitada")
	conferir(Gesto.calcular_impulso(Vector2.ZERO, Vector2(80, 0), 10, 10, 80) == Vector2.ZERO, "Faixa inválida não divide por zero")
	conferir(Gesto.calcular_impulso(Vector2.ZERO, Vector2(80, 0), 10, 80, NAN) == Vector2.ZERO, "Parâmetro não finito é rejeitado")
	gesto.iniciar(0, Vector2.ZERO)
	gesto.mover(0, Vector2.INF)
	conferir(gesto.contato_ativo == -1, "Arraste inválido limpa o gesto")


func _executar() -> void:
	testar_calculo_e_ciclo()
	var viewport := Rect2(0, 0, 180, 320)
	var escala := Transform2D(Vector2(4, 0), Vector2(0, 4), Vector2.ZERO)
	conferir(HUD.area_segura_logica(Rect2(0, 80, 720, 1160), escala, viewport) == Rect2(0, 20, 180, 290), "HUD respeita recorte superior e navegação inferior na escala do celular")
	escala.origin = Vector2(20, 40)
	conferir(HUD.area_segura_logica(Rect2(20, 40, 720, 1280), escala, viewport) == viewport, "Janela já afastada das barras não recebe margem duplicada")
	conferir(HUD.area_segura_logica(Rect2(), escala, viewport) == viewport, "Área segura indisponível mantém HUD visível")
	conferir(HUD.area_segura_logica(Rect2(-100, -100, 2000, 2000), escala, viewport) == viewport, "Área segura maior é limitada ao viewport")
	var nave = CenaNave.instantiate()
	nave.simulacao_automatica = false
	root.add_child(nave)
	var entrada = nave.get_node("Entrada")
	entrada.impulso_solicitado.connect(func(impulso: Vector2): impulsos.append(impulso))
	await process_frame
	toque(0, Vector2(90, 200), true)
	arrastar(1, Vector2(170, 300))
	toque(1, Vector2(170, 300), false)
	conferir(entrada.gesto.contato_ativo == 0, "Multitoque integrado preserva contato inicial")
	arrastar(0, Vector2(90, 245))
	toque(0, Vector2(90, 245), false)
	toque(0, Vector2(90, 245), false)
	conferir(impulsos.size() == 1 and impulsos[0].is_equal_approx(Vector2(0, -40)), "Gesto integrado emite uma intenção")
	toque(0, Vector2(120, 200), true)
	arrastar(0, Vector2(120, 245))
	arrastar(0, Vector2(120, 205))
	toque(0, Vector2(120, 205), false)
	conferir(nave._pedidos.size() == 1, "Cancelar outro gesto no mesmo passo preserva lançamento já solicitado")
	entrada.cancelar()
	conferir(nave._pedidos.is_empty(), "Cancelamento limpa aplicação pendente")

	for notificacao in [Node.NOTIFICATION_APPLICATION_FOCUS_OUT, Node.NOTIFICATION_APPLICATION_PAUSED, Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT]:
		toque(0, Vector2(90, 200), true)
		arrastar(0, Vector2(90, 245))
		entrada.notification(notificacao)
		entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
		toque(0, Vector2(90, 245), false)
		conferir(impulsos.size() == 1, "Suspensão/foco cancela gesto: %s" % notificacao)
	toque(0, Vector2(90, 200), true)
	arrastar(0, Vector2(90, 245))
	toque(0, Vector2(90, 245), false, true)
	conferir(impulsos.size() == 1, "Cancelamento do sistema não lança")
	toque(0, Vector2(90, 200), true)
	arrastar(0, Vector2(90, 245))
	paused = true
	paused = false
	toque(0, Vector2(90, 245), false)
	conferir(impulsos.size() == 1, "Pausa da árvore cancela gesto")
	toque(0, Vector2(90, 200), true)
	toque(0, Vector2(90, 245), false)
	paused = true
	conferir(nave._pedidos.is_empty(), "Pausa antes da física limpa impulso pendente")
	paused = false
	impulsos.clear()
	entrada.habilitada = false
	toque(0, Vector2(90, 200), true)
	arrastar(0, Vector2(90, 245))
	entrada.habilitada = true
	toque(0, Vector2(90, 245), false)
	conferir(impulsos.is_empty(), "Exploração/bloqueio não deixa gesto pendente")

	var botao := Button.new()
	botao.position = Vector2(20, 20)
	botao.size = Vector2(60, 50)
	botao.text = "UI"
	root.add_child(botao)
	await process_frame
	toque(0, Vector2(40, 40), true)
	arrastar(0, Vector2(40, 130))
	toque(0, Vector2(40, 130), false)
	conferir(impulsos.is_empty(), "Toque iniciado no botão não lança")
	toque(0, Vector2(40, 150), true)
	arrastar(0, Vector2(40, 100))
	toque(0, Vector2(40, 40), false)
	await process_frame
	conferir(entrada.gesto.contato_ativo == -1, "Soltura iniciada no jogo não prende o contato sobre interface")
	entrada.cancelar()
	impulsos.clear()
	mouse(Vector2(90, 200), true)
	mover_mouse(Vector2(90, 245))
	mouse(Vector2(90, 245), false)
	conferir(impulsos.size() == 1 and impulsos[0].is_equal_approx(Vector2(0, -40)), "Mouse emulado usa a mesma intenção uma vez")
	entrada.cancelar()
	impulsos.clear()
	mouse(Vector2(40, 40), true)
	mover_mouse(Vector2(40, 130))
	mouse(Vector2(40, 130), false)
	conferir(impulsos.is_empty(), "Mouse iniciado no botão não lança")
	entrada.cancelar()
	impulsos.clear()
	mouse(Vector2(90, 200), true)
	mover_mouse(Vector2(90, 245))
	mover_mouse(Vector2(90, 205))
	mover_mouse(Vector2(90, 270))
	mouse(Vector2(90, 270), false)
	conferir(impulsos.is_empty(), "Mouse exige novo clique após retornar ao círculo")
	botao.queue_free()
	await process_frame
	var interface_consumidora := InterfaceConsomeSoltura.new()
	interface_consumidora.mouse_filter = Control.MOUSE_FILTER_PASS
	interface_consumidora.position = Vector2(100, 20)
	interface_consumidora.size = Vector2(70, 130)
	root.add_child(interface_consumidora)
	await process_frame
	toque(0, Vector2(120, 100), true)
	conferir(entrada.gesto.contato_ativo == 0, "Interface PASS permite início na área de jogo")
	arrastar(0, Vector2(120, 50))
	toque(0, Vector2(120, 50), false)
	await process_frame
	conferir(impulsos.is_empty() and entrada.gesto.contato_ativo == -1, "Soltura consumida pela GUI cancela sem disparo pendente")
	interface_consumidora.queue_free()
	await process_frame
	for tamanho in [Vector2i(360, 640), Vector2i(720, 1280)]:
		root.size = tamanho
		await process_frame
		mouse(Vector2(90, 200), true)
		mover_mouse(Vector2(90, 245))
		mouse(Vector2(90, 245), false)
		conferir(impulsos.size() == 1 and impulsos[0].is_equal_approx(Vector2(0, -40)), "Escala lógica preservada em %s" % tamanho)
		entrada.cancelar()
		impulsos.clear()

	var camera := Camera2D.new()
	root.add_child(camera)
	toque(0, Vector2(90, 200), true)
	camera.position = Vector2(1500, -700)
	nave.position = Vector2(700, 300)
	camera.force_update_scroll()
	toque(0, Vector2(90, 245), false)
	conferir(impulsos.size() == 1 and impulsos[0].is_equal_approx(Vector2(0, -40)), "Mover câmera/nave durante mira não altera impulso")
	entrada.cancelar()
	impulsos.clear()
	toque(0, Vector2(90, 200), true)
	arrastar(0, Vector2(90, 245))
	root.size_changed.emit()
	toque(0, Vector2(90, 245), false)
	conferir(impulsos.is_empty(), "Redimensionamento cancela coordenadas antigas")
	camera.queue_free()
	nave.simulacao_automatica = true
	nave.velocidade = Vector2(10, 0)
	toque(0, Vector2(90, 200), true)
	toque(0, Vector2(90, 245), false)
	for passo in range(4):
		await physics_frame
	conferir(nave.velocidade.is_equal_approx(Vector2(10, -40)), "Impulso soma à velocidade exatamente uma vez")
	for passo in range(4):
		await physics_frame
	conferir(nave.velocidade.is_equal_approx(Vector2(10, -40)), "Passos seguintes não reaplicam impulso")
	nave.queue_free()
	await process_frame
	await testar_cena_principal()
	print("Controles: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)


func testar_cena_principal() -> void:
	var cena = load("res://src/ControladorJogo/main.tscn").instantiate()
	root.add_child(cena)
	await process_frame
	var nave_menu = cena.get_node("Mundo/Nivel/Nave")
	nave_menu.simulacao_automatica = false
	var entrada_menu = nave_menu.get_node("Entrada")
	entrada_menu.impulso_solicitado.connect(func(impulso: Vector2): impulsos.append(impulso))
	impulsos.clear()
	var botao: Button = cena.get_node("Interface/MenuPrincipal/VBoxContainer/Button")
	var centro := botao.get_global_rect().get_center()
	mouse(centro, true)
	mouse(centro, false)
	await process_frame
	conferir(impulsos.is_empty(), "Start não lança a nave do menu")
	conferir(cena.interface_atual.cartoes.get_child_count() == 1, "Menu abre seleção por catálogo")
	cena.interface_atual.escolher("teste_001")
	await process_frame
	await process_frame
	conferir(cena.mundo_atual.nivel_res != null, "Escolha carrega nível JSON")
	var nave_jogo = cena.mundo_atual.get_node("Nave")
	cena.mundo_atual.partida.set_physics_process(false)
	cena.mundo_atual.camera._process(2.0)
	conferir(nave_jogo.get_node("Entrada").gesto.contato_ativo == -1, "Start não transfere gesto à nova nave")
	nave_jogo.get_node("Entrada").impulso_solicitado.connect(func(impulso: Vector2): impulsos.append(impulso))
	mouse(Vector2(90, 150), true)
	mover_mouse(Vector2(90, 195))
	mouse(Vector2(90, 195), false)
	conferir(impulsos.size() == 1, "Fundo decorativo e interface vazia permitem gesto no nível")
	var partida = cena.mundo_atual.partida
	var camera = cena.mundo_atual.camera
	partida.avancar(0)
	var saldo: int = nave_jogo.combustivel
	partida.alternar_exploracao()
	var camera_antes: Vector2 = camera.global_position
	toque(0, Vector2(90, 140), true)
	arrastar(0, Vector2(120, 170))
	toque(0, Vector2(120, 170), false)
	partida.avancar(0)
	conferir(camera.global_position != camera_antes and nave_jogo.combustivel == saldo, "Arraste de exploração move câmera sem lançar")
	var interface_consumidora := InterfaceConsomeSoltura.new()
	interface_consumidora.mouse_filter = Control.MOUSE_FILTER_PASS
	interface_consumidora.position = Vector2(50, 100)
	interface_consumidora.size = Vector2(80, 100)
	var camada := CanvasLayer.new()
	camada.layer = 20
	root.add_child(camada)
	camada.add_child(interface_consumidora)
	await process_frame
	toque(0, Vector2(90, 140), true)
	arrastar(0, Vector2(120, 170))
	toque(0, Vector2(120, 170), false)
	await process_frame
	conferir(camera._contato == -1, "Soltura consumida pela GUI libera contato da câmera")
	toque(1, Vector2(90, 140), true)
	conferir(camera._contato == 1, "Novo dedo pode explorar após soltura consumida")
	arrastar(2, Vector2(120, 170))
	toque(2, Vector2(120, 170), false, true)
	conferir(camera._contato == 1, "Outro dedo não encerra exploração ativa")
	root.size_changed.emit()
	conferir(camera._contato == -1 and camera._ultima_posicao == Vector2.ZERO, "Redimensionar limpa arraste e coordenadas da câmera")
	toque(1, Vector2(90, 140), true)
	camera.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	conferir(camera._contato == -1, "Perda de foco encerra exploração")
	toque(1, Vector2(90, 140), true)
	toque(1, Vector2(90, 140), false, true)
	conferir(camera._contato == -1, "Cancelamento do sistema encerra exploração")
	conferir(nave_jogo.combustivel == saldo and nave_jogo._pedidos.is_empty(), "Cancelamentos da câmera não cobram combustível")
	camada.queue_free()
	await process_frame
	partida.alternar_exploracao()
	camera._process(0)
	conferir(camera.global_position == nave_jogo.global_position and nave_jogo.entrada.gesto.contato_ativo == -1, "Voltar à nave recentraliza sem gesto pendente")
	var mundo_anterior: Node = cena.mundo_atual
	conferir(cena.iniciar_fase("teste_001"), "Segunda abertura carrega nova tentativa")
	await process_frame
	conferir(not is_instance_valid(mundo_anterior) and cena.get_node("Mundo").get_child_count() == 1, "Troca de fase libera mundo anterior")
	conferir(cena.mundo_atual.get_node("Nave").combustivel == 5, "Nova fase não herda combustível")
	cena.queue_free()
	conferir(not is_instance_valid(nave_menu), "Troca libera a nave anterior")
	await process_frame
