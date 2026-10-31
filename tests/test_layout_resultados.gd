extends SceneTree

const Area = preload("res://src/Visual/area_segura_menu.gd")
var verificacoes := 0
var falhas := 0

func _initialize() -> void:
	_executar.call_deferred()

func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)

func acomodar() -> void:
	for i in range(6):
		await process_frame

func _executar() -> void:
	var suporte := SubViewportContainer.new()
	root.add_child(suporte)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(180, 240)
	suporte.add_child(viewport)
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	jogo.ativar_audio = false
	viewport.add_child(jogo)
	await acomodar()
	var itens: Array = jogo.get_node("GerenciadorDeNivel").itens
	for item in itens.slice(0, itens.size() - 1):
		jogo.progresso.concluir(item.id, itens)
	conferir(jogo.iniciar_fase(itens[-1].id), "Abre última fase para verificar desfecho longo")
	await acomodar()
	var nivel = jogo.mundo_atual
	var partida = nivel.partida
	var nave = nivel.get_node("Nave")
	partida.set_physics_process(false)
	var hud: CanvasLayer
	for filho in nivel.get_children():
		if filho is CanvasLayer and filho.has_method("_abrir_configuracoes"):
			hud = filho
	for altura in [240, 390]:
		viewport.size = Vector2i(180, altura)
		await acomodar()
		var segura := Rect2(8, 16, 164, altura - 32)
		Area.aplicar(hud._raiz, 0, viewport.get_screen_transform() * segura)
		for estado in ["pausa", "derrota", "final"]:
			partida.reiniciar()
			if estado == "pausa":
				partida.pausar()
			elif estado == "derrota":
				partida.finalizar(false, "Colisão com perigo. ".repeat(12))
			else:
				partida.finalizar(true, "Chegada à Terra")
			await acomodar()
			var rolagem: ScrollContainer = hud._rolagem_rodape
			var contexto := "%s em 180×%d" % [estado, altura]
			conferir(segura.encloses(rolagem.get_global_rect()), contexto + ": rodapé dentro da área segura")
			conferir(not rolagem.get_h_scroll_bar().visible, contexto + ": sem rolagem horizontal")
			conferir(not rolagem.get_global_rect().intersects(hud._topo.get_global_rect()), contexto + ": ações não cobrem o status")
			var tempo: float = partida.tempo_restante
			var saldo: int = nave.combustivel
			var botoes: Array = hud._conteudo_rodape.find_children("*", "Button", true, false).filter(func(botao): return botao.is_visible_in_tree())
			for botao in botoes:
				rolagem.ensure_control_visible(botao)
				await acomodar()
				# Transformações de viewport podem introduzir erro inferior a 0,01 unidade.
				conferir(rolagem.get_global_rect().grow(0.01).encloses(botao.get_global_rect()), contexto + ": alcança " + botao.text)
			conferir(partida.tempo_restante == tempo and nave.combustivel == saldo, contexto + ": rolagem não altera tentativa")
			if estado == "pausa":
				conferir(paused and partida.estado == partida.Estado.PAUSADO, "Rolagem da pausa não retoma a simulação")
	partida.reiniciar()
	nivel.camera._process(2)
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	await acomodar()
	var toque := InputEventScreenTouch.new()
	toque.index = 7
	toque.pressed = true
	toque.position = hud._mensagem.get_global_rect().get_center()
	viewport.push_input(toque, true)
	conferir(nave.entrada.gesto.contato_ativo == 7, "Tutorial durante jogo continua permitindo iniciar gesto sobre o texto")
	toque = InputEventScreenTouch.new()
	toque.index = 7
	toque.canceled = true
	viewport.push_input(toque, true)
	conferir(nave.entrada.gesto.contato_ativo == -1 and nave.combustivel == nivel.nivel_res.combustivel_inicial, "Cancelamento após toque no texto não consome combustível")
	paused = false
	suporte.queue_free()
	await process_frame
	print("Layout dos resultados: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas else 0)
