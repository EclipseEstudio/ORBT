extends SceneTree
## Capturas de regressão visual; executar com renderizador real (sem --headless).

func _initialize() -> void:
	_capturar.call_deferred()


func _capturar() -> void:
	var main = load("res://src/ControladorJogo/main.tscn").instantiate()
	main.persistir_progresso = false
	main.ativar_audio = false
	root.add_child(main)
	await process_frame
	main.iniciar_fase("teste_001")
	var nivel = main.mundo_atual
	nivel.partida.set_physics_process(false)
	nivel.partida.retomar()
	nivel.camera._process(2.0)
	nivel.get_node("Nave/Entrada").notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/fase-inicial.png")
	var entrada = nivel.get_node("Nave/Entrada")
	entrada.gesto.iniciar(0, Vector2(100, 150))
	entrada.gesto.mover(0, Vector2(100, 230))
	nivel.get_node("Nave/Indicadores/Mira")._process(1)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/fase-mira.png")
	nivel.partida.pausar()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/fase-pausada.png")
	nivel.partida.retomar()
	nivel.get_node("Nave").solicitar_impulso(1, Vector2(0, -80))
	for passo in range(180):
		nivel.partida.avancar(1.0 / 60)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/fase-vitoria.png")
	print("Capturas salvas em .godot/fase-*.png")
	quit()
