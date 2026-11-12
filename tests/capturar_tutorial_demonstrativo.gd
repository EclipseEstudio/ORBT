extends SceneTree


func _initialize() -> void:
	_capturar.call_deferred()


func _capturar() -> void:
	DirAccess.make_dir_recursive_absolute("res://.godot/tutorial-demonstrativo")
	var suporte := SubViewportContainer.new()
	root.add_child(suporte)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(180, 320)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	suporte.add_child(viewport)
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	jogo.ativar_audio = false
	viewport.add_child(jogo)
	await process_frame
	if jogo.interface_atual.has_node("Splash"):
		jogo.interface_atual.get_node("Splash").free()
	for tamanho in [Vector2i(180, 240), Vector2i(180, 320)]:
		viewport.size = tamanho
		for quadro in 8:
			await process_frame
		await RenderingServer.frame_post_draw
		viewport.get_texture().get_image().save_png("res://.godot/tutorial-demonstrativo/menu-%dx%d.png" % [tamanho.x, tamanho.y])
	jogo.iniciar_fase("teste_001")
	await process_frame
	for filho in jogo.mundo_atual.get_children():
		if filho.has_method("_criar_dica"):
			filho.get_node("TituloFase")._encerrar()
	var tutorial = jogo.mundo_atual.find_child("TutorialDemonstrativo", true, false)
	for tamanho in [Vector2i(180, 240), Vector2i(180, 320)]:
		viewport.size = tamanho
		for etapa in 2:
			tutorial._mostrar_etapa(etapa)
			for quadro in 8:
				await process_frame
			tutorial.area._tempo = 2.2
			tutorial.area.queue_redraw()
			await RenderingServer.frame_post_draw
			viewport.get_texture().get_image().save_png("res://.godot/tutorial-demonstrativo/dialogo-etapa-%d-%dx%d.png" % [etapa + 1, tamanho.x, tamanho.y])
	jogo.queue_free()
	await process_frame
	quit()
