extends SceneTree
## Capturas de produção; progresso e preferências reais não são usados.


func _initialize() -> void:
	_capturar.call_deferred()


func salvar(nome: String) -> void:
	for i in 8:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/estrelas-" + nome + ".png")


func _capturar() -> void:
	root.content_scale_size = Vector2i(180, 320)
	root.size = Vector2i(540, 960)
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	jogo.ativar_audio = false
	root.add_child(jogo)
	await process_frame
	var itens: Array = jogo.get_node("GerenciadorDeNivel").itens
	for indice in range(7):
		jogo.progresso.concluir_com_estrelas(itens[indice].id, itens, 2 if indice % 3 == 0 else 3)
	jogo.mostrar_selecao()
	await salvar("campanha")
	jogo.iniciar_fase("teste_001")
	await process_frame
	var mundo = jogo.mundo_atual
	mundo.partida.set_physics_process(false)
	mundo.camera._process(2)
	mundo.camera.force_update_scroll()
	await salvar("fase")
	mundo.partida.retomar()
	var nave = mundo.partida.nave
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2.UP * 80)
	for i in 300:
		mundo.partida.avancar(1.0 / 60)
	await salvar("resultado")
	jogo.queue_free()
	await process_frame
	quit()
