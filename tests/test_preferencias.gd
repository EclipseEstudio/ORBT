extends SceneTree

const Preferencias = preload("res://src/Configuracoes/preferencias.gd")
var base := "res://.godot/preferencias-teste-%d" % OS.get_process_id()
var verificacoes := 0
var falhas := 0

func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)

func _initialize() -> void:
	_executar.call_deferred()

func _executar() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 1:
		var reaberto := Preferencias.new()
		reaberto.caminho = args[0]
		reaberto.carregar()
		conferir(is_equal_approx(reaberto.musica, 0.25) and is_equal_approx(reaberto.efeitos, 0.75), "preferências persistem em outro processo")
		conferir(is_equal_approx(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Musica")), linear_to_db(0.25)), "volume de música aplicado ao canal")
		conferir(is_equal_approx(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Efeitos")), linear_to_db(0.75)), "volume de efeitos aplicado ao canal")
		print("PREFERENCIAS_REABERTAS")
		quit(1 if falhas else 0)
		return
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.caminho_progresso = base + "-progresso"
	jogo.caminho_checkpoint = base + "-checkpoint"
	jogo.caminho_preferencias = base
	root.add_child(jogo)
	await process_frame
	conferir(jogo.preferencias.musica == 1.0 and jogo.preferencias.efeitos == 1.0, "ausência usa padrão")
	var menu = jogo.interface_atual
	var botao: Button = menu.get_node("VBoxContainer/Configuracoes")
	botao.pressed.emit()
	var tela = menu.get_node("TelaConfiguracoes")
	var coluna = tela.get_child(1).get_child(0)
	coluna.get_node("musica").value = 0.25
	coluna.get_node("efeitos").value = 0.75
	conferir(jogo.preferencias.musica == 0.25 and jogo.preferencias.efeitos == 0.75, "controles independentes do menu")
	conferir(not FileAccess.file_exists(jogo.caminho_progresso) and not FileAccess.file_exists(jogo.caminho_checkpoint), "preferências não gravam campanha nem checkpoint")
	coluna.get_node("Voltar").pressed.emit()
	conferir(jogo.iniciar_fase("teste_001"), "inicia fase")
	var checkpoint_antes := FileAccess.get_file_as_string(jogo.caminho_checkpoint)
	var progresso_existe := FileAccess.file_exists(jogo.caminho_progresso)
	var partida = jogo.mundo_atual.partida
	partida.pausar()
	var hud: CanvasLayer
	for item in jogo.mundo_atual.get_children():
		if item is CanvasLayer:
			hud = item
	hud._process(0)
	conferir(hud._configuracoes.visible and paused, "configurações disponíveis na pausa")
	hud._configuracoes.pressed.emit()
	var tela_pausa = hud._raiz.get_node("TelaConfiguracoes")
	var coluna_pausa = tela_pausa.get_child(1).get_child(0)
	coluna_pausa.get_node("musica").value = 0.0
	conferir(AudioServer.is_bus_mute(AudioServer.get_bus_index("Musica")) and not AudioServer.is_bus_mute(AudioServer.get_bus_index("Efeitos")), "silêncio de música não afeta efeitos")
	coluna_pausa.get_node("musica").value = 0.25
	conferir(FileAccess.get_file_as_string(jogo.caminho_checkpoint) == checkpoint_antes and FileAccess.file_exists(jogo.caminho_progresso) == progresso_existe, "ajuste na pausa preserva checkpoint e progresso")
	coluna_pausa.get_node("Voltar").pressed.emit()
	conferir(paused and partida.estado == partida.Estado.PAUSADO, "fechar configurações preserva pausa")
	paused = false
	jogo.queue_free()
	await process_frame
	var saida: Array = []
	var codigo := OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_preferencias.gd", "--log-file", ProjectSettings.globalize_path("res://.godot/preferencias-filho.log"), "--", base], saida, true)
	print("\n".join(saida))
	conferir(codigo == 0 and "PREFERENCIAS_REABERTAS" in "\n".join(saida), "novo processo carrega e aplica preferências")
	var arquivo := FileAccess.open(base, FileAccess.WRITE)
	arquivo.store_string("{invalido")
	arquivo.close()
	var invalido := Preferencias.new()
	invalido.caminho = base
	invalido.carregar()
	conferir(invalido.musica == 1.0 and invalido.efeitos == 1.0 and not invalido.aviso.is_empty(), "arquivo inválido usa padrão com aviso")
	conferir(not invalido.alterar("musica", NAN) and invalido.musica == 1.0, "volume não finito é rejeitado")
	var indisponivel := Preferencias.new()
	indisponivel.caminho = base + "/ausente/preferencias.json"
	indisponivel.carregar()
	conferir(not indisponivel.alterar("efeitos", 0.5) and indisponivel.efeitos == 0.5 and not indisponivel.aviso.is_empty(), "falha de gravação informa e mantém ajuste na sessão")
	for prefixo in [base, base + "-progresso", base + "-checkpoint"]:
		for sufixo in ["", ".bak", ".tmp", ".bak.tmp"]:
			if FileAccess.file_exists(prefixo + sufixo):
				DirAccess.remove_absolute(prefixo + sufixo)
	print("Preferências: ", verificacoes, " verificações, ", falhas, " falhas.")
	quit(1 if falhas else 0)
