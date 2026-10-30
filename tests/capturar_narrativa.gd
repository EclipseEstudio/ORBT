extends SceneTree
func _initialize() -> void:
	_capturar.call_deferred()
func salvar(nome: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/narrativa-" + nome + ".png")
func _capturar() -> void:
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	jogo.ativar_audio = false
	root.add_child(jogo)
	await salvar("menu")
	jogo.iniciar_fase("teste_001")
	jogo.mundo_atual.partida.set_physics_process(false)
	jogo.mundo_atual.camera._process(2.0)
	jogo.mundo_atual.partida.finalizar(true, "Você chegou à Terra!")
	await salvar("chegada")
	var itens: Array = jogo.get_node("GerenciadorDeNivel").itens
	for item in itens:
		jogo.progresso.concluir(item.id, itens)
	await process_frame
	jogo.iniciar_fase(itens[-1].id)
	jogo.mundo_atual.partida.set_physics_process(false)
	jogo.mundo_atual.camera._process(2.0)
	jogo.mundo_atual.partida.finalizar(true, "Você chegou à Terra!")
	await salvar("final")
	jogo.free()
	quit()
