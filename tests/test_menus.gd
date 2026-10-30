extends SceneTree

var verificacoes := 0
var falhas := 0

func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)

func _initialize() -> void:
	_executar.call_deferred()

func hud_de(jogo) -> CanvasLayer:
	for item in jogo.mundo_atual.get_children():
		if item is CanvasLayer and item.get_script() != null and item.get_script().resource_path == "res://src/Nivel/interface_partida.gd":
			return item
	return null

func _executar() -> void:
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	root.add_child(jogo)
	await process_frame
	var menu = jogo.interface_atual
	var coluna = menu.get_node("VBoxContainer")
	conferir(coluna.has_node("Configuracoes") and coluna.has_node("Creditos"), "menu oferece configurações e créditos")
	conferir(not coluna.get_children().any(func(item): return item is Button and item.text == "Continuar"), "menu sem checkpoint não oferece Continuar")
	coluna.get_node("Creditos").pressed.emit()
	conferir(menu.has_node("TelaCreditos"), "abre créditos")
	var creditos = menu.get_node("TelaCreditos")
	conferir(creditos.find_child("Texto", true, false).text.contains("Godot") and creditos.find_child("Texto", true, false).text.contains("ImageGen"), "créditos mostram origem e licença")
	creditos.find_child("Voltar", true, false).pressed.emit()
	await process_frame
	conferir(not menu.has_node("TelaCreditos"), "volta dos créditos ao menu")
	jogo.checkpoint.dados = {"fase": "teste_001", "content_version": -1}
	jogo.mostrar_menu()
	menu = jogo.interface_atual
	coluna = menu.get_node("VBoxContainer")
	conferir(not coluna.get_children().any(func(item): return item is Button and item.text == "Continuar") and coluna.has_node("AvisoCheckpoint") and coluna.has_node("DescartarCheckpoint"), "checkpoint incompatível mostra diagnóstico sem oferecer Continuar")
	jogo.checkpoint.dados = {}
	jogo.checkpoint.bloqueado = false
	jogo.checkpoint.aviso = ""
	conferir(jogo.iniciar_fase("teste_001"), "abre primeira fase")
	await process_frame
	var mundo = jogo.mundo_atual
	var partida = mundo.partida
	var hud = hud_de(jogo)
	partida.pausar()
	hud._process(0)
	conferir(hud._menu.visible and hud._configuracoes.visible and hud._pausa.text == "Retomar", "pausa oferece menu, configurações e retomada")
	hud._menu.pressed.emit()
	await process_frame
	conferir(not paused and jogo.interface_atual.has_node("VBoxContainer/Creditos") and jogo.mundo_atual != mundo, "retorno ao menu limpa mundo e pausa")
	conferir(not is_instance_valid(partida) or (not partida.is_inside_tree() and not partida.nave.simulacao_ativa), "simulação anterior não permanece ativa")
	conferir(jogo.iniciar_fase("teste_001"), "reabre fase")
	await process_frame
	partida = jogo.mundo_atual.partida
	hud = hud_de(jogo)
	partida.finalizar(false, "teste")
	hud._process(0)
	conferir(hud._checkpoint.visible and hud._reiniciar.text == "Reiniciar" and not hud._proxima.visible, "derrota oferece checkpoint e reinício")
	hud._checkpoint.pressed.emit()
	conferir(partida.estado == partida.Estado.JOGANDO, "botão restaura checkpoint")
	partida.finalizar(true, "vitória")
	hud._process(0)
	conferir(hud._proxima.visible and hud._reiniciar.text == "Repetir", "vitória oferece próxima fase e repetição")
	var anterior = jogo.mundo_atual
	hud._proxima.pressed.emit()
	await process_frame
	await process_frame
	conferir(jogo.mundo_atual != anterior and jogo.mundo_atual.nivel_res.id == "salto_curto", "próxima fase abre após vitória")
	conferir(jogo.progresso.estado("teste_001") == "Concluída" and (not is_instance_valid(anterior) or not anterior.is_inside_tree()), "progresso preservado e fase anterior removida")
	var itens: Array = jogo.get_node("GerenciadorDeNivel").itens
	for item in itens:
		jogo.progresso.concluir(item.id, itens)
	await process_frame
	conferir(jogo.iniciar_fase(itens[-1].id), "abre última fase")
	await process_frame
	partida = jogo.mundo_atual.partida
	hud = hud_de(jogo)
	partida.finalizar(true, "última")
	hud._process(0)
	conferir(not hud._proxima.visible and hud._reiniciar.text == "Repetir", "última fase não oferece próxima")
	hud._reiniciar.pressed.emit()
	conferir(partida.estado == partida.Estado.JOGANDO and partida.nave.combustivel == partida.nivel.combustivel_inicial, "repetir inicia nova tentativa")
	conferir(jogo.progresso.estado(itens[-1].id) == "Concluída", "repetição mantém conclusão")
	jogo.queue_free()
	print("Menus: ", verificacoes, " verificações, ", falhas, " falhas.")
	quit(1 if falhas else 0)
