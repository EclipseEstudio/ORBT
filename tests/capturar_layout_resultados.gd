extends SceneTree

const Area = preload("res://src/Visual/area_segura_menu.gd")

func _initialize() -> void:
	_capturar.call_deferred()

func esperar() -> void:
	for i in range(6):
		await process_frame

func salvar(nome: String) -> void:
	await esperar()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/resultados-" + nome + ".png")

func _capturar() -> void:
	root.content_scale_size = Vector2i(180, 240)
	root.size = Vector2i(360, 480)
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	jogo.ativar_audio = false
	root.add_child(jogo)
	await esperar()
	var itens: Array = jogo.get_node("GerenciadorDeNivel").itens
	for item in itens.slice(0, itens.size() - 1):
		jogo.progresso.concluir(item.id, itens)
	jogo.iniciar_fase(itens[-1].id)
	await esperar()
	var partida = jogo.mundo_atual.partida
	partida.set_physics_process(false)
	var hud: CanvasLayer
	for filho in jogo.mundo_atual.get_children():
		if filho is CanvasLayer and filho.has_method("_abrir_configuracoes"):
			hud = filho
	Area.aplicar(hud._raiz, 0, root.get_screen_transform() * Rect2(8, 16, 164, 208))
	partida.reiniciar()
	partida.pausar()
	await esperar()
	hud._rolagem_rodape.ensure_control_visible(hud._menu)
	await salvar("pausa-acoes")
	partida.reiniciar()
	partida.finalizar(true, "Chegada à Terra")
	await esperar()
	hud._rolagem_rodape.scroll_vertical = 0
	await salvar("desfecho")
	var botoes: Array = hud._conteudo_rodape.find_children("*", "Button", true, false).filter(func(item): return item.is_visible_in_tree())
	hud._rolagem_rodape.ensure_control_visible(botoes.back())
	await salvar("desfecho-acoes")
	paused = false
	quit()
