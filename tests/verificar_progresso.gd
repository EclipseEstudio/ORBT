extends SceneTree

func _initialize() -> void:
	var progresso = load("res://src/Campanha/progresso_persistente.gd").new()
	progresso.caminho = OS.get_cmdline_user_args()[0]
	if progresso.carregar() and progresso.estado("teste_001") == "Concluída":
		print("PROGRESSO_REABERTO")
		quit()
	else:
		quit(1)
