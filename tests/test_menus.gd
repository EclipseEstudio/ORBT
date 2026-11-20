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
	jogo.ativar_audio = false
	root.add_child(jogo)
	await process_frame
	var menu = jogo.interface_atual
	var coluna = menu.get_node("Margem/Rolagem/VBoxContainer")
	conferir(coluna.has_node("Acoes/Configuracoes") and coluna.has_node("Acoes/Conquistas") and coluna.get_node("Titulo") is Button, "menu oferece configurações, conquistas e créditos pelo título")
	conferir(not coluna.get_children().any(func(item): return item is Button and item.text == "Continuar"), "menu sem checkpoint não oferece Continuar")
	coluna.get_node("Titulo").pressed.emit()
	conferir(menu.has_node("TelaCreditos"), "abre créditos")
	var creditos = menu.get_node("TelaCreditos")
	conferir(creditos.find_child("Texto", true, false).text == "Miguel Alves\nRubens Augusto\nGustavo Costa\nCesar Caus", "Créditos mostram os quatro nomes solicitados")
	var logos = creditos.find_child("Logos", true, false)
	conferir(logos.find_child("WMDG", true, false).texture != null and logos.find_child("Godot", true, false).texture != null, "Créditos incluem as duas logos lado a lado")
	creditos.find_child("Voltar", true, false).pressed.emit()
	await process_frame
	conferir(not menu.has_node("TelaCreditos"), "volta dos créditos ao menu")
	jogo.checkpoint.dados = {"fase": "teste_001", "content_version": -1}
	jogo.mostrar_menu()
	menu = jogo.interface_atual
	coluna = menu.get_node("Margem/Rolagem/VBoxContainer")
	conferir(menu.find_children("*", "Button", true, false).size() == 4 and not menu.has_node("Margem/Rolagem/VBoxContainer/ComoJogar"), "menu mantém três ações e título clicável, sem tutorial ou ação de checkpoint incompatível")
	jogo.preferencias.dicas = false
	jogo.mostrar_selecao()
	conferir(jogo.interface_atual.find_child("DicaEstrelas", true, false) == null and jogo.preferencias.dicas_vistas.is_empty(), "Desativar dicas preserva a primeira apresentação")
	jogo.preferencias.dicas = true
	jogo.mostrar_selecao()
	var dica_estrelas = jogo.interface_atual.find_child("DicaEstrelas", true, false)
	conferir(dica_estrelas != null and dica_estrelas.find_children("*", "Label", true, false).any(func(rotulo): return rotulo.text.contains("liberar o próximo")), "Primeira visita explica como usar estrelas douradas para liberar níveis")
	conferir(not paused and jogo.interface_atual.quantidade_cartoes() == 31, "Dica de estrelas não bloqueia a seleção de fases")
	jogo.mostrar_selecao()
	dica_estrelas = jogo.interface_atual.find_child("DicaEstrelas", true, false)
	var ok: Button = dica_estrelas.find_child("DispensarDica", true, false)
	conferir(ok.text == "OK" and jogo.preferencias.dicas_vistas.is_empty(), "Dica de estrelas aguarda confirmação pelo OK")
	ok.pressed.emit()
	conferir(jogo.interface_atual.find_child("Checkpoint", true, false) == null, "Seleção não contém controles de checkpoint")
	conferir(not jogo.checkpoint_disponivel() and jogo.checkpoint.bloqueado, "API interna preserva diagnóstico de versão")
	await process_frame
	await process_frame
	conferir(jogo.interface_atual.find_child("DicaEstrelas", true, false) == null, "Dica pode ser dispensada na primeira visita")
	conferir(jogo.checkpoint.dados == {"fase": "teste_001", "content_version": -1} and jogo.interface_atual.get_script() == preload("res://src/Campanha/selecao_fases.gd"), "Exibir o aviso preserva os dados e mantém a seleção navegável")
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
	conferir(hud._dialogo_pausa.visible and not hud._raiz.visible and hud._dialogo_pausa.find_children("*", "Button", true, false).size() == 3, "pausa mostra diálogo modal com três ações")
	hud._dialogo_pausa._menu.pressed.emit()
	await process_frame
	conferir(not paused and jogo.interface_atual.get("cartoes") != null and jogo.mundo_atual != mundo, "retorno à seleção limpa mundo e pausa")
	conferir(jogo.interface_atual.find_child("DicaEstrelas", true, false) == null, "Dica de estrelas não se repete na seleção")
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
	conferir(hud._dialogo_conclusao.visible and not hud._raiz.visible, "vitória abre diálogo semelhante à pausa")
	hud._dialogo_conclusao._continuar.pressed.emit()
	await process_frame
	await process_frame
	conferir(jogo.mundo_atual != anterior and jogo.mundo_atual.nivel_res.id == jogo.get_node("GerenciadorDeNivel").itens[1].id, "próxima fase abre após vitória seguindo a ordem da campanha")
	conferir(jogo.progresso.estado("teste_001") == "Concluída" and (not is_instance_valid(anterior) or not anterior.is_inside_tree()), "progresso preservado e fase anterior removida")
	hud = hud_de(jogo)
	hud.get_node("TituloFase")._encerrar()
	hud._process(0)
	conferir(not hud._mensagem.is_visible_in_tree(), "Derrota em uma fase não libera dicas na próxima")
	jogo.mostrar_selecao()
	conferir(jogo.iniciar_fase("teste_001"), "Reabre fase que teve derrota")
	await process_frame
	hud = hud_de(jogo)
	hud.get_node("TituloFase")._encerrar()
	hud._process(0)
	conferir(hud._mensagem.is_visible_in_tree(), "Dica de nova tentativa aparece ao voltar à fase após derrota")
	var itens: Array = jogo.get_node("GerenciadorDeNivel").itens
	for item in itens:
		jogo.progresso.concluir_com_estrelas(item.id, itens, 3)
	await process_frame
	conferir(jogo.iniciar_fase(itens[-1].id), "abre última fase")
	await process_frame
	partida = jogo.mundo_atual.partida
	hud = hud_de(jogo)
	partida.finalizar(true, "última")
	hud._process(0)
	conferir(not hud._proxima.visible and hud._reiniciar.text == "Repetir", "última fase não oferece próxima")
	conferir(not hud._dialogo_conclusao._continuar.visible, "última fase não oferece próxima no diálogo")
	conferir(hud._dialogo_conclusao._resetar.visible and hud._dialogo_conclusao._menu.visible, "última fase oferece repetir e voltar às fases")
	conferir(jogo.progresso.estado(itens[-1].id) == "Concluída", "conclusão mantém progresso")
	jogo.queue_free()
	await process_frame
	print("Menus: ", verificacoes, " verificações, ", falhas, " falhas.")
	quit(1 if falhas else 0)
