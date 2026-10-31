extends SceneTree

var base := "res://.godot/captura-retentar-%d" % OS.get_process_id()

func _initialize() -> void:
	_capturar.call_deferred()

func salvar(nome: String) -> void:
	for i in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/preferencias-" + nome + ".png")

func _capturar() -> void:
	root.content_scale_size = Vector2i(180, 240)
	root.size = Vector2i(360, 480)
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	jogo.ativar_audio = false
	root.add_child(jogo)
	await process_frame
	jogo.preferencias.persistir = true
	jogo.preferencias.caminho = base + "/ausente/preferencias.json"
	jogo.iniciar_fase("teste_001")
	await process_frame
	jogo.mundo_atual.partida.set_physics_process(false)
	jogo.mundo_atual.partida.pausar()
	var hud: CanvasLayer
	for filho in jogo.mundo_atual.get_children():
		if filho is CanvasLayer and filho.has_method("_abrir_configuracoes"):
			hud = filho
	hud._abrir_configuracoes()
	var tela = hud.get_node("TelaConfiguracoes")
	tela.find_child("musica", true, false).value = 0.25
	tela.find_child("efeitos", true, false).value = 0.75
	await process_frame
	tela._margem.get_child(0).ensure_control_visible(tela.find_child("Voltar", true, false))
	await salvar("falha-retentativa")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(base + "/ausente"))
	tela._tentar_salvar.pressed.emit()
	await salvar("retentativa-salva")
	paused = false
	for arquivo in [jogo.preferencias.caminho, jogo.preferencias.caminho + ".tmp"]:
		if FileAccess.file_exists(arquivo):
			DirAccess.remove_absolute(arquivo)
	DirAccess.remove_absolute(base + "/ausente")
	DirAccess.remove_absolute(base)
	quit()
