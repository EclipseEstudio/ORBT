extends SceneTree

var verificacoes := 0
var falhas := 0

func _initialize() -> void:
	_executar.call_deferred()

func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)

func acomodar() -> void:
	for i in range(4):
		await process_frame

func escape(repeticao := false) -> void:
	var evento := InputEventKey.new()
	evento.keycode = KEY_ESCAPE
	evento.pressed = true
	evento.echo = repeticao
	Input.parse_input_event(evento)

func _executar() -> void:
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	jogo.ativar_audio = false
	root.add_child(jogo)
	await acomodar()
	if "--saida-menu" in OS.get_cmdline_user_args():
		print("VOLTA_MENU_SAIDA")
		create_timer(1.0).timeout.connect(func(): quit(1))
		jogo.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
		return
	conferir(not quit_on_go_back, "Saída automática por Voltar desativada no projeto")
	var menu = jogo.interface_atual
	var coluna = menu.get_node("Margem/Rolagem/VBoxContainer")
	coluna.get_node("Creditos").pressed.emit()
	escape(true)
	await acomodar()
	conferir(menu.has_node("TelaCreditos"), "Repetição de Escape não atravessa telas")
	jogo.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	jogo.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	await acomodar()
	conferir(not menu.has_node("TelaCreditos") and jogo.interface_atual == menu, "Voltar nativo repetido fecha apenas créditos")
	coluna.get_node("Configuracoes").pressed.emit()
	var tela = menu.get_node("TelaConfiguracoes")
	tela.find_child("musica", true, false).value = 0.25
	var fechamentos: Array = []
	tela.fechada.connect(func(): fechamentos.append(true))
	escape()
	await acomodar()
	conferir(not menu.has_node("TelaConfiguracoes") and fechamentos.size() == 1, "Escape fecha configurações pelo mesmo fluxo de Voltar")
	conferir(jogo.preferencias.musica == 0.25, "Fechar por Escape preserva volume escolhido")
	jogo.mostrar_selecao()
	await acomodar()
	jogo.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	await acomodar()
	conferir(jogo.interface_atual.has_node("Margem/Rolagem/VBoxContainer/Button"), "Voltar da campanha abre menu principal")
	conferir(jogo.iniciar_fase("teste_001"), "Abre fase para testar Voltar")
	await acomodar()
	var nivel = jogo.mundo_atual
	var partida = nivel.partida
	var nave = nivel.get_node("Nave")
	partida.set_physics_process(false)
	nivel.camera._process(2)
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2(0, -80))
	partida.avancar(1.0 / 60.0)
	nave.animation_player.seek(0.2, true)
	var tempo_animacao: float = nave.animation_player.current_animation_position
	nave.entrada.gesto.iniciar(7, Vector2(90, 140))
	nave.entrada.gesto.mover(7, Vector2(90, 200))
	nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2(0, -40))
	var saldo: int = nave.combustivel
	var tempo: float = partida.tempo_restante
	var posicao: Vector2 = nave.global_position
	jogo.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	await acomodar()
	conferir(paused and partida.estado == partida.Estado.PAUSADO, "Voltar nativo pausa a fase")
	conferir(nave.entrada.gesto.contato_ativo == -1 and nave._pedidos.is_empty() and nave.combustivel == saldo, "Voltar cancela gesto e lançamento pendente sem custo")
	conferir(nave.global_position == posicao and partida.tempo_restante == tempo, "Fase pausada preserva posição e tempo")
	conferir(is_equal_approx(nave.animation_player.current_animation_position, tempo_animacao), "Nave e propulsão não herdam processamento durante pausa")
	var hud: CanvasLayer
	for item in nivel.get_children():
		if item is CanvasLayer and item.has_method("_abrir_configuracoes"):
			hud = item
	hud._abrir_configuracoes()
	jogo.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	await acomodar()
	conferir(not hud.has_node("TelaConfiguracoes") and paused and partida.estado == partida.Estado.PAUSADO, "Voltar fecha configurações sem retomar partida")
	escape()
	await acomodar()
	conferir(paused and partida.estado == partida.Estado.PAUSADO, "Escape na pausa mantém retomada explícita")
	partida.retomar()
	conferir(not paused and nave.combustivel == saldo, "Retomar explícito continua sem cobrar impulso cancelado")
	partida.finalizar(false, "Teste de derrota")
	jogo.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	await acomodar()
	conferir(jogo.interface_atual.get("cartoes") != null and not is_instance_valid(nivel), "Voltar do resultado abre campanha e remove mundo anterior")
	jogo.iniciar_fase("teste_001")
	await acomodar()
	jogo.mundo_atual.partida.retomar()
	jogo.mundo_atual.partida.finalizar(true, "Teste de vitória")
	jogo.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	await acomodar()
	conferir(jogo.interface_atual.get("cartoes") != null and jogo.progresso.estado("teste_001") == "Concluída", "Voltar da vitória preserva progresso")
	jogo.mostrar_menu()
	await acomodar()
	menu = jogo.interface_atual
	escape()
	await acomodar()
	conferir(jogo.interface_atual == menu, "Escape no menu principal não fecha aplicativo desktop")
	jogo.queue_free()
	await process_frame
	if "--sem-subprocesso" not in OS.get_cmdline_user_args():
		var saida: Array = []
		var codigo := OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_voltar.gd", "--log-file", ProjectSettings.globalize_path("res://.godot/voltar-filho.log"), "--", "--saida-menu"], saida, true)
		conferir(codigo == 0 and "VOLTA_MENU_SAIDA" in "\n".join(saida), "Voltar nativo no menu encerra processo separado")
	print("Voltar: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas else 0)
