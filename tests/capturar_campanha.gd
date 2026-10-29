extends SceneTree

func _initialize() -> void:
	_capturar.call_deferred()


func _capturar() -> void:
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	root.add_child(jogo)
	await process_frame
	jogo.mostrar_selecao()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/campanha.png")
	var itens: Array = []
	for indice in range(10):
		itens.append({"id": "visual_%d" % indice, "nome": "Uma viagem de volta para casa com nome longo" if indice == 0 else "Etapa %d" % (indice + 1), "ordem": indice + 1, "arquivo": ""})
	var progresso = jogo.progresso
	progresso.configurar(itens)
	progresso.concluir("visual_0", itens)
	jogo.interface_atual.atualizar(itens, [])
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/campanha-dez-fases.png")
	jogo.mostrar_menu()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/menu-campanha.png")
	jogo.queue_free()
	await process_frame
	quit()
