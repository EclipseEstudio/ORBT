extends SceneTree

const Conquistas = preload("res://src/Conquistas/conquistas.gd")
const Sessao = preload("res://src/Campanha/progresso_sessao.gd")
const Disco = preload("res://src/Campanha/progresso_persistente.gd")
const Catalogo = preload("res://src/Campanha/catalogo.gd")
var verificacoes := 0
var falhas := 0
var base := "res://.godot/conquistas-save-%d" % OS.get_process_id()

class FalhaDisco:
	extends "res://src/Campanha/progresso_persistente.gd"
	var falhar := false
	func _gravar(arquivo: String, texto: String) -> bool:
		return false if falhar else super._gravar(arquivo, texto)

func _initialize() -> void:
	executar.call_deferred()

func conferir(ok: bool, mensagem: String) -> void:
	verificacoes += 1
	if not ok:
		falhas += 1
		push_error(mensagem)

func acomodar() -> void:
	for quadro in 6:
		await process_frame

func obter(progresso, itens: Array, id: String) -> Dictionary:
	return Conquistas.listar(progresso, itens).filter(func(c): return c.id == id)[0]

func executar() -> void:
	var itens: Array = []
	for i in 30:
		itens.append({"id": "fase_%d" % i, "estrelas": 3, "azuis": 1})
	var progresso := Sessao.new()
	progresso.configurar(itens)
	conferir(Conquistas.listar(progresso, itens).size() == 9 and Conquistas.listar(progresso, itens).all(func(c): return not c.desbloqueada), "Nove conquistas inicialmente bloqueadas")
	conferir(not progresso.concluir_com_coletas("fase_5", itens, 3, 1, 1), "Fase bloqueada não premia")
	conferir(not progresso.registrar_lancamentos("fase_0", 1), "Sem vitória não registra lançamento único")
	for i in 30:
		progresso.concluir_com_coletas(itens[i].id, itens, 3, 1, 1 if i < 10 else 2)
		if i in [8, 9, 18, 19, 28, 29]:
			for meta in [10, 20, 30]:
				conferir(obter(progresso, itens, "azuis_%d" % meta).desbloqueada == (i + 1 >= meta), "Marco azul %d no total %d" % [meta, i + 1])
		if i in [3, 4, 8, 9]:
			for meta in [5, 10]:
				conferir(obter(progresso, itens, "um_lancamento_%d" % meta).desbloqueada == (i + 1 >= meta), "Lançamento único em %d fases: marco %d" % [i + 1, meta])
		if i in [9, 19, 29]:
			conferir(obter(progresso, itens, "nivel_%d" % (i / 10 + 1)).desbloqueada, "Amarelas de cada nível desbloqueiam sua conquista")
		if i == 28:
			conferir(not obter(progresso, itens, "todas_azuis").desbloqueada, "Coleção completa bloqueada com 29 azuis")
	conferir(Conquistas.listar(progresso, itens).all(func(c): return c.desbloqueada), "Todas as regras atingidas desbloqueiam as nove conquistas")
	progresso.concluir_com_coletas(itens[0].id, itens, 1, 0, 4)
	conferir(progresso.fases_um_lancamento.size() == 10 and obter(progresso, itens, "azuis_30").atual == 30, "Replay pior preserva conquistas e não duplica estrelas/fases")
	progresso.concluir_com_coletas(itens[0].id, itens, 3, 1, 1)
	conferir(progresso.fases_um_lancamento.size() == 10, "Repetir a mesma fase não conta como nova fase distinta")
	progresso.resetar()
	progresso.concluidas["fora_catalogo"] = true
	progresso.melhores_azuis["fora_catalogo"] = 30
	progresso.fases_um_lancamento["fora_catalogo"] = true
	conferir(Conquistas.listar(progresso, itens).all(func(c): return not c.desbloqueada and c.atual == 0), "Reset limpa conquistas; IDs fora do catálogo não contam")
	var salvo := FalhaDisco.new()
	salvo.caminho = base
	salvo.configurar(itens)
	conferir(salvo.concluir_com_coletas(itens[0].id, itens, 3, 1, 1) and salvo.geracao == 1, "Vitória, duas cores e lançamento único são salvos em uma geração")
	var reaberto := Disco.new()
	reaberto.caminho = base
	conferir(reaberto.carregar() and reaberto.fases_um_lancamento.has(itens[0].id) and reaberto.melhor_azuis(itens[0].id) == 1, "Reabertura preserva registro de lançamento único e estrelas")
	salvo.falhar = true
	salvo.concluir_com_coletas(itens[1].id, itens, 3, 1, 1)
	conferir(salvo.salvamento_pendente() and salvo.fases_um_lancamento.size() == 2 and not salvo.carregar(), "Falha de escrita preserva conquista pendente em memória")
	salvo.falhar = false
	conferir(salvo.salvar() and reaberto.carregar() and reaberto.fases_um_lancamento.size() == 2, "Retentativa persiste registro pendente")
	var legado := {"schema_version": 3, "geracao": 1, "concluidas": [itens[0].id], "liberadas": [itens[0].id, itens[1].id], "melhores_estrelas": {itens[0].id: 3}, "melhores_azuis": {itens[0].id: 1}}
	legado.checksum = JSON.stringify(legado, "", true).sha256_text()
	var fluxo := FileAccess.open(base + "-legado", FileAccess.WRITE)
	fluxo.store_string(JSON.stringify(legado))
	fluxo.close()
	reaberto = Disco.new()
	reaberto.caminho = base + "-legado"
	conferir(reaberto.carregar() and reaberto.melhor_estrelas(itens[0].id) == 3 and reaberto.melhor_azuis(itens[0].id) == 1 and reaberto.fases_um_lancamento.is_empty(), "Migração do esquema 3 preserva estrelas sem inventar lançamentos")
	conferir(JSON.parse_string(FileAccess.get_file_as_string(reaberto.caminho)).schema_version == 4, "Save migrado usa esquema 4")
	var adulterado: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(base))
	adulterado.fases_um_lancamento.append("fase_inexistente")
	adulterado.erase("checksum")
	adulterado.checksum = JSON.stringify(adulterado, "", true).sha256_text()
	fluxo = FileAccess.open(base + "-invalido", FileAccess.WRITE)
	fluxo.store_string(JSON.stringify(adulterado))
	fluxo.close()
	reaberto = Disco.new()
	reaberto.caminho = base + "-invalido"
	conferir(not reaberto.carregar() and not reaberto.salvar(), "Registro fora das fases concluídas é rejeitado mesmo com checksum correto")
	await testar_interface()
	for prefixo in [base, base + "-legado", base + "-invalido", base + "-checkpoint"]:
		for sufixo in ["", ".bak", ".tmp", ".bak.tmp"]:
			if FileAccess.file_exists(prefixo + sufixo):
				DirAccess.remove_absolute(prefixo + sufixo)
	print("Conquistas: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas else 0)

func testar_interface() -> void:
	var suporte := SubViewportContainer.new()
	root.add_child(suporte)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(180, 320)
	suporte.add_child(viewport)
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	jogo.ativar_audio = false
	viewport.add_child(jogo)
	await acomodar()
	var menu = jogo.interface_atual
	if menu.has_node("Splash"):
		menu.get_node("Splash").free()
	var titulo: Button = menu.get_node("Margem/Rolagem/VBoxContainer/Titulo")
	titulo.pressed.emit()
	conferir(menu.has_node("TelaCreditos"), "Clique no título abre créditos")
	jogo.solicitar_voltar(true)
	await acomodar()
	var botao: Button = menu.get_node("Margem/Rolagem/VBoxContainer/Acoes/Conquistas")
	conferir(botao.icon == preload("res://src/Visual/icones_ui.gd").obter("medalha") and not menu.has_node("Margem/Rolagem/VBoxContainer/Acoes/Creditos"), "Medalha substitui o botão de créditos")
	botao.grab_focus()
	botao.pressed.emit()
	await acomodar()
	var tela = menu.get_node("TelaConquistas")
	conferir(tela.cartoes.get_child_count() == 9 and tela.find_child("Titulo", true, false).text == "Conquistas", "Tela apresenta título e nove cards")
	for tamanho in [Vector2i(180, 240), Vector2i(180, 320), Vector2i(240, 320)]:
		viewport.size = tamanho
		await acomodar()
		var area := Rect2(Vector2.ZERO, Vector2(tamanho))
		conferir(area.encloses(tela.find_child("Voltar", true, false).get_global_rect()) and not tela.rolagem.get_h_scroll_bar().visible, "Voltar acessível e sem rolagem horizontal em %s" % tamanho)
		for card in tela.cartoes.get_children():
			conferir(card.size.x <= tela.rolagem.size.x and card.find_child("Imagem", true, false).texture != null and card.find_child("Descricao", true, false).text != "" and card.find_child("Estado", true, false).texture == preload("res://src/Visual/icones_ui.gd").obter("cadeado"), "Card bloqueado contém imagem, descrição e cadeado sem exceder largura")
		tela.rolagem.scroll_vertical = int(tela.cartoes.size.y)
		await acomodar()
		conferir(tela.rolagem.get_global_rect().intersects(tela.cartoes.get_child(8).get_global_rect()), "Último card alcançável por rolagem")
	var catalogo: Array = jogo.get_node("GerenciadorDeNivel").itens
	conferir(catalogo.reduce(func(total, item): return total + item.azuis, 0) == 30, "Catálogo possui exatamente 30 estrelas azuis")
	for item in catalogo:
		jogo.progresso.concluir_com_coletas(item.id, catalogo, 3, 1, 1)
	await acomodar()
	conferir(tela._resumo.text == "9/9 desbloqueadas" and tela.cartoes.get_child(8).find_child("Estado", true, false).texture == preload("res://src/Visual/icones_ui.gd").obter("concluida"), "Tela atualiza conquistas obtidas e troca cadeado por confirmação")
	tela.find_child("Voltar", true, false).pressed.emit()
	await acomodar()
	conferir(not menu.has_node("TelaConquistas") and viewport.gui_get_focus_owner() == botao, "Voltar restaura menu e foco na medalha")
	botao.pressed.emit()
	jogo.solicitar_voltar(true)
	await acomodar()
	conferir(not menu.has_node("TelaConquistas") and jogo.interface_atual == menu, "Voltar nativo fecha apenas conquistas")
	jogo.preferencias.dicas = false
	jogo.iniciar_fase("teste_001")
	await acomodar()
	var partida = jogo.mundo_atual.partida
	partida.set_physics_process(false)
	var nave = partida.nave
	nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2.UP * 80)
	nave.cancelar_pedidos()
	partida.avancar(0)
	conferir(partida.lancamentos_aplicados == 0, "Pedido descartado antes da aplicação não conta")
	nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2.UP * 80)
	partida.avancar(0)
	conferir(partida.lancamentos_aplicados == 1, "Conta impulso efetivamente aplicado")
	partida._registrar_checkpoint()
	nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2.RIGHT * 10)
	partida.avancar(0)
	conferir(partida.lancamentos_aplicados == 2, "Correção em voo conta como segundo lançamento")
	partida.finalizar(false, "Teste")
	partida.restaurar_checkpoint()
	conferir(partida.lancamentos_aplicados == 1, "Último pouso restaura contagem do trecho válido")
	partida._checkpoint.erase("lancamentos")
	partida.finalizar(false, "Teste legado")
	partida.restaurar_checkpoint()
	nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2.UP * 10)
	partida.avancar(0)
	conferir(partida.lancamentos_aplicados == -1, "Checkpoint antigo não inventa lançamento único")
	partida.reiniciar()
	conferir(partida.lancamentos_aplicados == 0, "Reiniciar zera a contagem")
	var checkpoint := preload("res://src/Campanha/checkpoint_persistente.gd").new()
	checkpoint.caminho = base + "-checkpoint"
	conferir(checkpoint.salvar(partida._checkpoint, int(partida.nivel.dados_autorais.content_version)) and checkpoint.carregar() and checkpoint.validar(partida.nivel).lancamentos == 0, "Checkpoint serializa e valida a contagem")
	for invalido in [-2, 1.5, "1", INF]:
		checkpoint.dados.lancamentos = invalido
		conferir(checkpoint.validar(partida.nivel).is_empty(), "Contagem de checkpoint inválida é rejeitada")
	jogo.progresso.fases_um_lancamento.clear()
	partida.finalizar(false, "Derrota sem prêmio")
	conferir(jogo.progresso.fases_um_lancamento.is_empty(), "Derrota não registra fase para a conquista")
	partida.reiniciar()
	nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2.UP * 80)
	partida.avancar(0)
	partida.resolver_contato({"kind": "body", "body": {"type": "earth"}})
	conferir(jogo.progresso.fases_um_lancamento.has("teste_001"), "Contato com Terra confirma lançamento único pelo controlador real")
	jogo.queue_free()
	await acomodar()
	suporte.queue_free()
	await process_frame
