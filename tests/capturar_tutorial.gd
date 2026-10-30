extends SceneTree
func _initialize() -> void:
	_capturar.call_deferred()
func tocar(posicao: Vector2, pressionado: bool) -> void:
	var evento := InputEventScreenTouch.new()
	evento.index = 0
	evento.position = posicao
	evento.pressed = pressionado
	root.push_input(evento, true)
func mover(posicao: Vector2) -> void:
	var evento := InputEventScreenDrag.new()
	evento.index = 0
	evento.position = posicao
	root.push_input(evento, true)
func salvar(nome: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/tutorial-" + nome + ".png")
func _capturar() -> void:
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	jogo.ativar_audio = false
	root.add_child(jogo)
	await process_frame
	jogo.iniciar_fase("teste_001")
	var nivel = jogo.mundo_atual
	nivel.partida.set_physics_process(false)
	nivel.camera._process(2)
	nivel.get_node("Nave/Entrada").notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	await salvar("inicio")
	tocar(Vector2(90, 145), true)
	await salvar("toque")
	mover(Vector2(90, 215))
	await salvar("arraste")
	tocar(Vector2(90, 215), false)
	nivel.partida.avancar(1.0 / 60.0)
	await salvar("combustivel")
	quit()
