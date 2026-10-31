extends SceneTree

func _initialize() -> void:
	_capturar.call_deferred()

func salvar(nome: String) -> void:
	for i in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/voltar-" + nome + ".png")

func _capturar() -> void:
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	jogo.ativar_audio = false
	root.add_child(jogo)
	await process_frame
	jogo.mostrar_selecao()
	await process_frame
	jogo.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	await salvar("menu")
	jogo.iniciar_fase("teste_001")
	await process_frame
	var nivel = jogo.mundo_atual
	nivel.partida.set_physics_process(false)
	nivel.partida.retomar()
	nivel.camera._process(2)
	jogo.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	await salvar("pausa")
	var hud: CanvasLayer
	for item in nivel.get_children():
		if item is CanvasLayer and item.has_method("_abrir_configuracoes"):
			hud = item
	hud._abrir_configuracoes()
	await salvar("configuracoes")
	jogo.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	await salvar("configuracoes-fechadas")
	paused = false
	quit()
