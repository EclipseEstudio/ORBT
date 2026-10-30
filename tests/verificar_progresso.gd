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


func _executar() -> void:
	var argumentos := OS.get_cmdline_user_args()
	if argumentos.size() != 2:
		push_error("Informe os caminhos isolados de progresso e catálogo para a reabertura.")
		quit(1)
		return
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.caminho_progresso = argumentos[0]
	jogo.caminho_checkpoint = argumentos[0] + "-checkpoint-filho"
	jogo.get_node("GerenciadorDeNivel").caminho = argumentos[1]
	root.add_child(jogo)
	await process_frame
	jogo.mostrar_selecao()
	conferir(jogo.progresso.estado("a") == "Concluída" and jogo.progresso.estado("b") == "Disponível", "Controlador reaberto restaura conclusão e acesso à segunda fase")
	var cartoes: VBoxContainer = jogo.interface_atual.cartoes
	conferir(cartoes.get_child_count() == 2 and cartoes.get_child(0).get_child(2).text == "Repetir" and not cartoes.get_child(0).get_child(2).disabled and not cartoes.get_child(1).get_child(2).disabled, "Seleção reaberta oferece repetição e próxima fase liberada")
	var abriu_ultima: bool = jogo.iniciar_fase("b")
	conferir(abriu_ultima, "Segunda fase desbloqueada abre após encerrar o processo anterior")
	if abriu_ultima:
		jogo.mundo_atual.partida.set_physics_process(false)
		jogo.mundo_atual.partida.finalizar(true, "Última chegada")
		conferir(jogo.progresso.estado("b") == "Concluída" and jogo.progresso.concluidas.size() == 2 and jogo.progresso.liberadas.size() == 2, "Última vitória conclui a campanha sem criar outro ID")
		jogo.mostrar_selecao()
		await process_frame
		cartoes = jogo.interface_atual.cartoes
		conferir(cartoes.get_child_count() == 2 and cartoes.get_child(0).get_child(2).text == "Repetir" and cartoes.get_child(1).get_child(2).text == "Repetir" and not cartoes.get_child(1).get_child(2).disabled, "Conclusão da última fase mantém campanha navegável")
		var salvo := FileAccess.get_file_as_string(argumentos[0])
		var abriu_repeticao: bool = jogo.iniciar_fase("a")
		conferir(abriu_repeticao, "Primeira fase concluída continua acessível após a última vitória")
		if abriu_repeticao:
			jogo.mundo_atual.partida.set_physics_process(false)
			conferir(jogo.mundo_atual.get_node("Nave").combustivel == 3 and jogo.mundo_atual.partida.tempo_restante == 30 and jogo.mundo_atual.partida.proximos.is_empty(), "Repetição restaura combustível, tempo e contatos iniciais")
		conferir(FileAccess.get_file_as_string(argumentos[0]) == salvo, "Abrir repetição não altera o progresso salvo")
		var restaurado = jogo.progresso.get_script().new()
		restaurado.caminho = argumentos[0]
		conferir(restaurado.carregar() and restaurado.estado("a") == "Concluída" and restaurado.estado("b") == "Concluída" and restaurado.liberadas.size() == 2, "Conclusão da última fase também fica persistida")
	jogo.queue_free()
	await process_frame
	print("Reabertura: %d verificações, %d falhas." % [verificacoes, falhas])
	if falhas == 0:
		print("PROGRESSO_REABERTO")
	quit(0 if falhas == 0 else 1)
