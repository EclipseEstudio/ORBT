extends SceneTree


func _initialize() -> void:
	_capturar.call_deferred()


func esperar() -> void:
	for i in range(6):
		await process_frame


func _capturar() -> void:
	root.content_scale_size = Vector2i(180, 390)
	root.size = Vector2i(540, 1170)
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	jogo.ativar_audio = false
	root.add_child(jogo)
	await esperar()
	jogo.iniciar_fase("teste_001")
	await esperar()
	var nivel = jogo.mundo_atual
	nivel.partida.set_physics_process(false)
	nivel.camera._process(2)
	nivel.camera.set_process(false)
	var hud: CanvasLayer
	for filho in nivel.get_children():
		if filho is CanvasLayer and filho.has_method("_abrir_configuracoes"):
			hud = filho
	var alvo: Vector2 = nivel.nivel_res.corpos[-1].position
	for estado in ["controle-superior", "painel-pausa"]:
		if estado == "painel-pausa":
			nivel.partida.pausar()
		await esperar()
		var controle: Control = hud._pausa if estado == "controle-superior" else hud._reiniciar
		var ponto := controle.get_global_rect().get_center()
		nivel.camera.global_position = alvo - (ponto - Vector2(90, 195)) / nivel.camera.zoom
		nivel.camera.force_update_scroll()
		await esperar()
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/indicador-terra-" + estado + ".png")
	paused = false
	quit()
