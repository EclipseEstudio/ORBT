extends SceneTree

const Area = preload("res://src/Visual/area_segura_menu.gd")

func _initialize() -> void:
	_capturar.call_deferred()

func salvar(nome: String) -> void:
	for i in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/configuracoes-pausa-" + nome + ".png")

func _capturar() -> void:
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	jogo.ativar_audio = false
	root.add_child(jogo)
	await process_frame
	jogo.iniciar_fase("teste_001")
	await process_frame
	var partida = jogo.mundo_atual.partida
	partida.set_physics_process(false)
	partida.pausar()
	var hud: CanvasLayer
	for filho in jogo.mundo_atual.get_children():
		if filho is CanvasLayer and filho.has_method("_abrir_configuracoes"):
			hud = filho
	for altura in [240, 390]:
		root.content_scale_size = Vector2i(180, altura)
		root.size = Vector2i(360, altura * 2)
		await process_frame
		var fisica: Rect2 = root.get_screen_transform() * Rect2(8, 16, 164, altura - 32)
		Area.aplicar(hud._raiz, 0, fisica)
		hud._abrir_configuracoes()
		var tela = hud.get_node("TelaConfiguracoes")
		Area.aplicar(tela._margem, 0, fisica)
		await salvar(str(altura))
		tela._margem.get_child(0).ensure_control_visible(tela.find_child("Voltar", true, false))
		await salvar(str(altura) + "-voltar")
		tela.free()
	paused = false
	quit()
