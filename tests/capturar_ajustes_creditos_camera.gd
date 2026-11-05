extends SceneTree

func _initialize() -> void:
	_capturar.call_deferred()


func salvar(nome: String) -> void:
	for i in 6:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/ajustes-" + nome + ".png")


func _capturar() -> void:
	var argumentos := OS.get_cmdline_user_args()
	var altura := int(argumentos[0]) if not argumentos.is_empty() else 320
	root.content_scale_size = Vector2i(180, altura)
	root.size = Vector2i(540, altura * 3)
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	jogo.ativar_audio = false
	root.add_child(jogo)
	await process_frame
	var splash = jogo.interface_atual.get_node_or_null("Splash")
	if splash != null:
		splash.free()
	jogo.interface_atual.get_node("Margem/Rolagem/VBoxContainer/Acoes/Creditos").pressed.emit()
	await salvar("creditos-%d" % altura)
	if altura != 320 or (argumentos.size() > 1 and argumentos[1] == "creditos"):
		quit()
		return
	jogo.interface_atual.get_node("TelaCreditos").free()
	jogo.iniciar_fase("teste_001")
	await process_frame
	var mundo = jogo.mundo_atual
	mundo.partida.set_physics_process(false)
	mundo.camera.set_process(false)
	mundo.camera.force_update_scroll()
	var entrada = mundo.partida.nave.entrada
	entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	await salvar("camera-proxima")
	entrada.gesto.iniciar(0, Vector2(60, 125))
	for exemplo in [["meio", Vector2(0, 45)], ["maximo", Vector2(0, 100)]]:
		entrada.gesto.mover(0, Vector2(60, 125) + exemplo[1])
		mundo.camera._process(2)
		mundo.camera.force_update_scroll()
		await salvar("camera-arraste-" + exemplo[0])
	entrada.cancelar()
	mundo.camera._process(2)
	mundo.camera.force_update_scroll()
	await salvar("camera-retorno")
	mundo.partida.finalizar(true, "Chegada à Terra")
	await salvar("repetir")
	quit()
