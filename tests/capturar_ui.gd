extends SceneTree
## Executar com renderizador real; salva evidências em .godot/ui-*.png.

func _initialize() -> void:
	_capturar.call_deferred()

func salvar(nome: String) -> void:
	for i in 5:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/ui-" + nome + ".png")

func _capturar() -> void:
	root.content_scale_size = Vector2i(180, 320)
	root.size = Vector2i(540, 960)
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	jogo.ativar_audio = false
	root.add_child(jogo)
	await salvar("splash")
	var splash: Node = jogo.interface_atual.get_node_or_null("Splash")
	if splash != null:
		splash.free()
	await salvar("menu")
	var itens: Array = jogo.get_node("GerenciadorDeNivel").itens
	jogo.progresso.concluir(itens[0].id, itens)
	jogo.progresso.concluir(itens[1].id, itens)
	jogo.mostrar_selecao()
	await salvar("fases")
	jogo.iniciar_fase("teste_001")
	await process_frame
	jogo.mundo_atual.partida.set_physics_process(false)
	jogo.mundo_atual.camera._process(2)
	jogo.mundo_atual.camera.force_update_scroll()
	await salvar("gameplay")
	jogo.mundo_atual.partida.pausar()
	await salvar("pausa")
	jogo.mundo_atual.partida.retomar()
	for filho in jogo.mundo_atual.get_children():
		if filho is CanvasLayer and filho.has_method("_alternar_pausa"):
			filho._process(6.1)
	await salvar("gameplay-livre")
	jogo.mundo_atual.partida.finalizar(true, "Chegada à Terra")
	await salvar("conclusao")
	jogo.checkpoint.dados = {"fase": "teste_001", "content_version": -1}
	jogo.mostrar_menu()
	await salvar("menu-checkpoint")
	jogo.mostrar_selecao()
	await salvar("fases-recuperacao")
	paused = false
	quit()
