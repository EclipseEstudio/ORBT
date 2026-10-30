extends SceneTree

const Area = preload("res://src/Visual/area_segura_menu.gd")

func _initialize() -> void:
	_capturar.call_deferred()

func salvar(nome: String) -> void:
	for i in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/menu-" + nome + ".png")

func _capturar() -> void:
	root.content_scale_size = Vector2i(180, 240)
	root.size = Vector2i(360, 480)
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	jogo.ativar_audio = false
	root.add_child(jogo)
	await process_frame
	var menu = jogo.interface_atual
	var fisica: Rect2 = root.get_screen_transform() * Rect2(8, 16, 164, 208)
	Area.aplicar(menu.get_node("Margem"), 8, fisica)
	menu._exibir_aviso("O checkpoint pertence a uma versão anterior desta fase. Reinicie a fase para continuar. Seu progresso da campanha foi preservado.")
	await salvar("diagnostico")
	menu.get_node("Margem/Rolagem").ensure_control_visible(menu.get_node("Margem/Rolagem/VBoxContainer/DescartarCheckpoint"))
	await salvar("reiniciar")
	menu.get_node("Margem/Rolagem/VBoxContainer/Configuracoes").pressed.emit()
	var configuracoes = menu.get_node("TelaConfiguracoes")
	Area.aplicar(configuracoes._margem, 0, fisica)
	await salvar("configuracoes")
	configuracoes._margem.get_child(0).ensure_control_visible(configuracoes.find_child("Voltar", true, false))
	await salvar("configuracoes-voltar")
	configuracoes.free()
	menu.get_node("Margem/Rolagem/VBoxContainer/Creditos").pressed.emit()
	Area.aplicar(menu.get_node("TelaCreditos")._margem, 0, fisica)
	await salvar("creditos")
	quit()
