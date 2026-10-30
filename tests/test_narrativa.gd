extends SceneTree

const Narrativa = preload("res://src/Narrativa/narrativa.gd")
var verificacoes := 0
var falhas := 0

func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)

func _initialize() -> void:
	_executar.call_deferred()

func obter_hud(jogo) -> CanvasLayer:
	for item in jogo.mundo_atual.get_children():
		if item is CanvasLayer and item.get_script() != null and item.get_script().resource_path == "res://src/Nivel/interface_partida.gd":
			return item
	return null

func _executar() -> void:
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	jogo.ativar_audio = false
	root.add_child(jogo)
	await process_frame
	await process_frame
	var menu = jogo.interface_atual
	var intro: Label = menu.get_node("VBoxContainer/Narrativa")
	conferir(intro.text == Narrativa.INTRODUCAO and intro.text.contains("veterana") and intro.text.contains("Terra"), "menu apresenta piloto e retorno")
	conferir(intro.mouse_filter == Control.MOUSE_FILTER_IGNORE, "introdução não intercepta toques")
	conferir(root.get_visible_rect().encloses(intro.get_global_rect()) and not intro.get_global_rect().intersects(menu.get_node("VBoxContainer/Button").get_global_rect()), "introdução e botão cabem sem sobreposição")
	jogo.checkpoint.dados = {"fase": "teste_001", "content_version": 2, "corpo": "origem", "posicao": [90, 222], "posicao_relativa": [0, -28], "orientacao": 0, "combustivel": 5, "tempo": 30, "temporizador_ativo": false}
	jogo.mostrar_menu()
	await process_frame
	await process_frame
	menu = jogo.interface_atual
	var coluna = menu.get_node("VBoxContainer")
	conferir(coluna.has_node("Continuar") and coluna.get_children().all(func(item): return not item is Control or not item.visible or root.get_visible_rect().encloses(item.get_global_rect())), "menu com checkpoint válido cabe na tela")
	menu._exibir_aviso("Checkpoint inválido. Reinicie a fase para continuar.")
	await process_frame
	await process_frame
	conferir(not coluna.get_node("Narrativa").visible and not coluna.get_node("Continuar").visible and coluna.get_children().all(func(item): return not item is Control or not item.visible or root.get_visible_rect().encloses(item.get_global_rect())), "diagnóstico mantém ações acessíveis na tela")
	jogo.checkpoint.dados = {}
	conferir(jogo.iniciar_fase("teste_001"), "primeira fase abre")
	await process_frame
	var partida = jogo.mundo_atual.partida
	partida.set_physics_process(false)
	var hud = obter_hud(jogo)
	hud._process(0)
	conferir(hud._mensagem.text.contains("Toque"), "tutorial permanece visível no início")
	partida.finalizar(false, "Colisão com perigo")
	hud._process(0)
	conferir(hud._mensagem.text.contains("Colisão") and not hud._mensagem.text.contains("Lia"), "derrota mantém sua causa")
	partida.reiniciar()
	partida.finalizar(true, "Você chegou à Terra!")
	hud._process(0)
	conferir(hud._mensagem.text == Narrativa.CHEGADA and hud._proxima.visible, "vitória intermediária mostra chegada e próxima fase")
	conferir(jogo.progresso.estado("teste_001") == "Concluída", "narrativa não impede a progressão")
	var itens: Array = jogo.get_node("GerenciadorDeNivel").itens
	for item in itens:
		jogo.progresso.concluir(item.id, itens)
	await process_frame
	conferir(jogo.iniciar_fase(itens[-1].id), "última fase abre")
	await process_frame
	partida = jogo.mundo_atual.partida
	partida.set_physics_process(false)
	hud = obter_hud(jogo)
	partida.finalizar(true, "Você chegou à Terra!")
	hud._process(0)
	conferir(hud._mensagem.text == Narrativa.DESFECHO and not hud._proxima.visible, "última vitória apresenta desfecho e não oferece avanço")
	conferir(jogo.progresso.estado(itens[-1].id) == "Concluída", "desfecho preserva conclusão")
	hud._reiniciar.pressed.emit()
	conferir(partida.estado == partida.Estado.JOGANDO and jogo.progresso.estado(itens[-1].id) == "Concluída", "repetição não apaga progresso")
	jogo.queue_free()
	await process_frame
	print("Narrativa: ", verificacoes, " verificações, ", falhas, " falhas.")
	quit(1 if falhas else 0)
