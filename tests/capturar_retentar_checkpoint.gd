extends SceneTree

const Cenarios = preload("res://tests/test_retentar_checkpoint.gd")
var base := "res://.godot/captura-retentar-checkpoint-%d" % OS.get_process_id()

func _initialize() -> void:
	_capturar.call_deferred()

func salvar(nome: String) -> void:
	for i in range(5):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/checkpoint-retentar-" + nome + ".png")

func _capturar() -> void:
	root.content_scale_size = Vector2i(180, 240)
	root.size = Vector2i(360, 480)
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.ativar_audio = false
	jogo.caminho_checkpoint = base
	jogo.caminho_progresso = base + "-progresso"
	jogo.caminho_preferencias = base + "-preferencias"
	jogo.checkpoint = Cenarios.FalhaTemporaria.new()
	root.add_child(jogo)
	await process_frame
	jogo.iniciar_fase("teste_001")
	await process_frame
	var partida = jogo.mundo_atual.partida
	partida.set_physics_process(false)
	partida.retomar()
	jogo.checkpoint.falhar = true
	var apoio: Dictionary = partida.nivel.obter_corpo("apoio")
	partida.nave.combustivel = 3
	partida.tempo_restante = 12.5
	partida.temporizador_ativo = true
	partida.nave.global_position = apoio.position + Vector2.LEFT * 30
	partida.resolver_contato({"kind": "body", "body": apoio})
	jogo.mostrar_menu()
	await process_frame
	var menu = jogo.interface_atual
	var coluna = menu.get_node("Margem/Rolagem/VBoxContainer")
	menu.get_node("Margem/Rolagem").ensure_control_visible(coluna.get_node("DescartarCheckpoint"))
	await salvar("pendente")
	jogo.checkpoint.falhar = false
	coluna.get_node("TentarSalvarCheckpoint").pressed.emit()
	await process_frame
	await process_frame
	menu = jogo.interface_atual
	coluna = menu.get_node("Margem/Rolagem/VBoxContainer")
	for i in range(5):
		await process_frame
	menu.get_node("Margem/Rolagem").ensure_control_visible(coluna.get_node("Continuar"))
	await salvar("salvo")
	coluna.get_node("Continuar").pressed.emit()
	await salvar("continuar")
	paused = false
	for prefixo in [base, base + "-progresso", base + "-preferencias"]:
		for sufixo in ["", ".bak", ".tmp", ".bak.tmp"]:
			if FileAccess.file_exists(prefixo + sufixo):
				DirAccess.remove_absolute(prefixo + sufixo)
	quit()
