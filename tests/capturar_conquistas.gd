extends SceneTree

func _initialize() -> void:
	capturar.call_deferred()

func salvar(viewport: SubViewport, nome: String) -> void:
	for quadro in 8:
		await process_frame
	await RenderingServer.frame_post_draw
	viewport.get_texture().get_image().save_png("res://.godot/conquistas-" + nome + ".png")

func capturar() -> void:
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
	await salvar(viewport, "menu")
	jogo.interface_atual.get_node("Margem/Rolagem/VBoxContainer/Titulo").grab_focus()
	jogo.interface_atual.get_node("Margem/Rolagem/VBoxContainer/Titulo").pressed.emit()
	await salvar(viewport, "creditos")
	jogo.interface_atual.get_node("TelaCreditos").fechar()
	await process_frame
	await salvar(viewport, "menu-retorno-creditos")
	jogo.interface_atual.get_node("Margem/Rolagem/VBoxContainer/Acoes/Conquistas").pressed.emit()
	var tela = jogo.interface_atual.get_node("TelaConquistas")
	for altura in [240, 320, 390]:
		viewport.size.y = altura
		tela.rolagem.scroll_vertical = 0
		await salvar(viewport, "bloqueadas-%d" % altura)
		tela.rolagem.scroll_vertical = 10000
		await salvar(viewport, "fim-%d" % altura)
	var itens: Array = jogo.get_node("GerenciadorDeNivel").itens
	for item in itens:
		jogo.progresso.concluir_com_coletas(item.id, itens, 3, 1, 1)
	viewport.size.y = 320
	tela.rolagem.scroll_vertical = 0
	await salvar(viewport, "obtidas")
	tela.rolagem.scroll_vertical = 10000
	await salvar(viewport, "obtidas-fim")
	jogo.queue_free()
	await process_frame
	quit()
