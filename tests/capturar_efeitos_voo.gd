extends SceneTree
## Capturas reais dos efeitos, sem modificar os dados autorais da fase.

func _initialize() -> void:
	_capturar.call_deferred()


func salvar(nome: String) -> void:
	for i in 6:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/efeitos-" + nome + ".png")


func _capturar() -> void:
	root.content_scale_size = Vector2i(180, 320)
	root.size = Vector2i(540, 960)
	var mundo = load("res://src/Nivel/Nivel.tscn").instantiate()
	mundo.nivel_res = preload("res://src/Nivel/carregador_fase.gd").carregar("res://Recursos/Fases/teste_001.json").nivel
	mundo.preferencias = preload("res://src/Configuracoes/preferencias.gd").new()
	mundo.preferencias.persistir = false
	mundo.preferencias.dicas = false
	root.add_child(mundo)
	await process_frame
	var partida = mundo.partida
	var nave = partida.nave
	var camera = mundo.camera
	var rastro = mundo.get_node("RastroNave")
	partida.set_physics_process(false)
	camera.set_process(false)
	rastro.set_physics_process(false)
	camera._process(2)
	camera._process(1)
	partida.retomar()
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	for exemplo in [["fraca", Vector2(15, 15)], ["media", Vector2(28, 35)], ["maxima", Vector2(60, 80)]]:
		nave.entrada.gesto.iniciar(0, Vector2(60, 125))
		nave.entrada.gesto.mover(0, Vector2(60, 125) + exemplo[1])
		camera.force_update_scroll()
		await salvar("mira-" + exemplo[0])
		nave.entrada.cancelar()
	nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2(0, -80))
	for i in 70:
		partida.avancar(1.0 / 60)
		camera._process(1.0 / 60)
		rastro._physics_process(1.0 / 60)
	camera.force_update_scroll()
	await salvar("rastro-voo")
	partida.alternar_exploracao()
	camera.aplicar_zoom(0.8)
	camera.force_update_scroll()
	await salvar("exploracao")
	partida.alternar_exploracao()
	partida.pausar()
	await salvar("pausa")
	paused = false
	quit()
