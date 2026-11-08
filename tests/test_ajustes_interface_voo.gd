extends SceneTree

const Carregador = preload("res://src/Nivel/carregador_fase.gd")
const Selecao = preload("res://src/Campanha/selecao_fases.gd")
const Sessao = preload("res://src/Campanha/progresso_sessao.gd")
const Cena = preload("res://src/Nivel/Nivel.tscn")
var verificacoes := 0
var falhas := 0

func conferir(ok: bool, mensagem: String) -> void:
	verificacoes += 1
	if not ok:
		falhas += 1
		push_error(mensagem)

func _initialize() -> void:
	executar.call_deferred()

func acomodar() -> void:
	for i in 5:
		await process_frame

func capturar(nome: String) -> void:
	if not OS.get_cmdline_user_args().has("--capturar"):
		return
	root.size = Vector2i(540, 720)
	await acomodar()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/ajustes-" + nome + ".png")

func clique(viewport: Viewport, ponto: Vector2, pressionado: bool, toque: bool) -> void:
	var evento: InputEvent
	if toque:
		evento = InputEventScreenTouch.new()
		evento.index = 0
	else:
		var movimento := InputEventMouseMotion.new()
		movimento.position = ponto
		viewport.push_input(movimento, true)
		evento = InputEventMouseButton.new()
		evento.button_index = MOUSE_BUTTON_LEFT
	evento.position = ponto
	evento.pressed = pressionado
	viewport.push_input(evento, true)

func executar() -> void:
	var viewport := root
	viewport.size = Vector2i(180, 240)
	viewport.content_scale_size = Vector2i(180, 240)
	var tela := Selecao.new()
	var itens: Array = []
	for i in 30:
		itens.append({"id": str(i), "ordem": i + 1, "nome": str(i), "estrelas": 3})
	tela.progresso = Sessao.new()
	tela.progresso.configurar(itens)
	for item in itens:
		tela.progresso.concluir_com_estrelas(item.id, itens, 3)
	tela.itens = itens
	viewport.add_child(tela)
	await acomodar()
	var escolhas: Array = []
	tela.fase_escolhida.connect(func(id): escolhas.append(id))
	for toque in [false, true]:
		tela.rolagem.scroll_vertical = 0
		await acomodar()
		var botao: Button = tela.obter_cartao(0).get_child(2)
		var inicio := botao.get_global_rect().get_center()
		clique(viewport, inicio, true, toque)
		var movimento: InputEvent
		if toque:
			movimento = InputEventScreenDrag.new()
			movimento.index = 0
		else:
			movimento = InputEventMouseMotion.new()
			movimento.button_mask = MOUSE_BUTTON_MASK_LEFT
		movimento.position = inicio - Vector2(0, 70)
		movimento.relative = Vector2(0, -70)
		viewport.push_input(movimento, true)
		clique(viewport, movimento.position, false, toque)
		await acomodar()
		conferir(tela.rolagem.scroll_vertical > 40 and escolhas.is_empty(), "Arrastar sobre fase rola sem abrir: toque=%s" % toque)
	conferir(tela.rolagem.get_v_scroll_bar().size.x <= 4, "Barra de rolagem tem até quatro pixels lógicos")
	await capturar("selecao")
	tela.rolagem.scroll_vertical = 0
	await acomodar()
	var ponto: Vector2 = tela.obter_cartao(0).get_child(2).get_global_rect().get_center()
	clique(viewport, ponto, true, false)
	clique(viewport, ponto, false, false)
	await acomodar()
	conferir(escolhas == ["0"], "Clique simples após arrastar continua abrindo a fase")
	tela.free()
	var mundo = Cena.instantiate()
	mundo.nivel_res = Carregador.carregar("res://Recursos/Fases/portal_invisivel.json").nivel
	mundo.preferencias = preload("res://src/Configuracoes/preferencias.gd").new()
	mundo.preferencias.dicas = false
	viewport.add_child(mundo)
	await acomodar()
	var partida = mundo.partida
	partida.set_physics_process(false)
	var nave = partida.nave
	var hud = mundo.find_child("DialogoPausa", true, false).get_parent()
	var terminou := [0]
	hud.get_node("TituloFase").terminou.connect(func(): terminou[0] += 1)
	clique(viewport, Vector2(80, 110), true, true)
	clique(viewport, Vector2(80, 110), false, true)
	await acomodar()
	conferir(not hud.has_node("TituloFase") and terminou[0] == 1 and not nave.tem_impulso_pendente(), "Toque dispensa título uma única vez sem lançar a nave")
	conferir(nave.get_node("Indicadores").layer > mundo.get_node("Nebulosa").layer, "Mira e força ficam acima da fumaça")
	for zoom in [0.3, 1.0, 3.0]:
		mundo.camera.zoom = Vector2.ONE * zoom
		mundo.camera.force_update_scroll()
		hud._bussola.atualizar()
		var origem: Vector2 = nave.get_global_transform_with_canvas().origin
		var centro: Vector2 = hud._bussola.get_global_transform_with_canvas() * hud._bussola.centro
		conferir(is_equal_approx(origem.distance_to(centro), 20), "Bússola segue nave na nebulosa com zoom %s" % zoom)
	var instrumentos = hud._raiz.get_node("InstrumentosNebulosa")
	conferir(hud._bussola.z_index > instrumentos.z_index, "Seta da Terra fica acima dos outros rumos")
	mundo.camera.set_process(false)
	mundo.camera.zoom = Vector2.ONE
	mundo.camera.global_position = nave.global_position
	mundo.camera.force_update_scroll()
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	nave.entrada.gesto.iniciar(0, Vector2(40, 130))
	nave.entrada.gesto.mover(0, Vector2(150, 220))
	await capturar("nebulosa")
	nave.entrada.cancelar()
	partida.pausar()
	hud._process(0)
	await acomodar()
	var dialogo = hud._dialogo_pausa
	conferir(dialogo._menu.global_position.x < dialogo._resetar.global_position.x and dialogo._resetar.global_position.x < dialogo._continuar.global_position.x and is_equal_approx(dialogo._menu.global_position.y, dialogo._resetar.global_position.y) and is_equal_approx(dialogo._resetar.global_position.y, dialogo._continuar.global_position.y), "Pausa alinha menu, resetar e continuar da esquerda para a direita")
	conferir(dialogo._continuar.get_global_rect().end.x <= 180, "Ações de pausa cabem na tela")
	await capturar("pausa")
	partida.retomar()
	partida.reiniciar()
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	var posicao: Vector2 = nave.posicao_relativa
	var oxigenio: float = partida.tempo_restante
	var combustivel: int = nave.combustivel
	for i in 60:
		partida.avancar(1.0 / 60)
	conferir(nave.posicao_relativa.is_equal_approx(posicao) and nave.combustivel == combustivel and partida.tempo_restante == oxigenio, "Estação permanece parada sem gastar combustível ou oxigênio")
	for corpo in mundo.nivel_res.corpos:
		if corpo.type in ["planet", "earth"]:
			conferir(not is_zero_approx(float(corpo.rotation.degrees_per_second)), "Corpo seguro tem rotação: " + corpo.id)
	var portais: Array = mundo.nivel_res.corpos.filter(func(c): return c.type == "portal")
	conferir(portais.size() == 2 and not portais[0]._portal_saida and portais[1]._portal_saida, "Par diferencia buraco negro de buraco branco")
	nave.corpos = []
	nave.velocidade = Vector2.ZERO
	nave.condicao = nave.Condicao.A_DERIVA
	nave.combustivel = 0
	partida.temporizador_ativo = true
	var limites: Rect2 = mundo.nivel_res.limites
	var centro_limites := limites.get_center()
	for ponto_fora in [Vector2(limites.position.x - 1, centro_limites.y), Vector2(limites.end.x + 1, centro_limites.y), Vector2(centro_limites.x, limites.position.y - 1), Vector2(centro_limites.x, limites.end.y + 1)]:
		nave.global_position = ponto_fora
		partida.tempo_restante = 10
		partida.avancar(0.25)
		conferir(is_equal_approx(partida.tempo_restante, 9.5), "Consumo dobra fora de cada lado do mapa: %s" % ponto_fora)
	for ponto_dentro in [centro_limites, limites.position, limites.end]:
		nave.global_position = ponto_dentro
		partida.tempo_restante = 10
		partida.avancar(0.25)
		conferir(is_equal_approx(partida.tempo_restante, 9.75), "Retornar ao mapa ou ficar na borda recupera consumo normal: %s" % ponto_dentro)
	nave.global_position = limites.end + Vector2(500, 500)
	partida.pausar()
	var saldo_pausado: float = partida.tempo_restante
	partida.avancar(1)
	conferir(partida.tempo_restante == saldo_pausado, "Pausa suspende também o consumo dobrado fora do mapa")
	partida.retomar()
	nave.velocidade = Vector2(100, 0)
	partida.tempo_restante = 0.1
	var fora: Vector2 = nave.global_position
	partida.avancar(0.025)
	conferir(partida.estado == partida.Estado.JOGANDO and nave.global_position.x > fora.x and is_equal_approx(partida.tempo_restante, 0.05), "Nave segue voando fora do mapa com consumo dobrado")
	partida.avancar(0.1)
	conferir(partida.estado == partida.Estado.PERDIDA and partida.motivo == "Oxigênio esgotado" and is_equal_approx(nave.global_position.x - fora.x, 5), "Oxigênio dobrado limita o voo ao tempo realmente disponível")
	mundo.free()
	if OS.get_cmdline_user_args().has("--capturar"):
		mundo = Cena.instantiate()
		mundo.nivel_res = Carregador.carregar("res://Recursos/Fases/demo_portais.json").nivel
		mundo.preferencias = preload("res://src/Configuracoes/preferencias.gd").new()
		mundo.preferencias.dicas = false
		viewport.add_child(mundo)
		mundo.partida.set_physics_process(false)
		await acomodar()
		mundo.find_child("TituloFase", true, false)._encerrar()
		mundo.camera.set_process(false)
		mundo.camera.zoom = Vector2.ONE * 0.8
		mundo.camera.global_position = Vector2(130, 0)
		mundo.camera.force_update_scroll()
		await capturar("portais")
		mundo.free()
	print("Ajustes de interface e voo: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas else 0)
