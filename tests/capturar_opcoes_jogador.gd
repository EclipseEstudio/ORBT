extends SceneTree

func _initialize() -> void:
	_capturar.call_deferred()

func salvar(nome: String) -> void:
	for i in 6:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/opcoes-" + nome + ".png")

func _capturar() -> void:
	var argumentos := OS.get_cmdline_user_args()
	var altura := int(argumentos[0]) if not argumentos.is_empty() else 320
	root.content_scale_size = Vector2i(180, altura)
	root.size = Vector2i(540, altura * 3)
	var preferencias := preload("res://src/Configuracoes/preferencias.gd").new()
	preferencias.persistir = false
	var tela := preload("res://src/Configuracoes/tela_configuracoes.gd").new()
	tela.preferencias = preferencias
	root.add_child(tela)
	await salvar("ativadas-%d" % altura)
	tela.find_child("vibracao", true, false).button_pressed = false
	tela.find_child("dicas", true, false).button_pressed = false
	tela.rolagem.ensure_control_visible(tela.find_child("dicas", true, false))
	await salvar("desativadas-%d" % altura)
	quit()
