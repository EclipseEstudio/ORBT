extends SceneTree

var verificacoes := 0
var falhas := 0
var viewport: SubViewport


func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)


func _initialize() -> void:
	_executar.call_deferred()


func acomodar() -> void:
	for i in 6:
		await process_frame


func demonstrar_gesto(ponto: Vector2, mouse: bool) -> void:
	if mouse:
		var inicio := InputEventMouseButton.new()
		inicio.button_index = MOUSE_BUTTON_LEFT
		inicio.position = ponto
		inicio.pressed = true
		viewport.push_input(inicio, true)
		var movimento := InputEventMouseMotion.new()
		movimento.position = ponto + Vector2(0, 24)
		movimento.button_mask = MOUSE_BUTTON_MASK_LEFT
		viewport.push_input(movimento, true)
		var fim := InputEventMouseButton.new()
		fim.button_index = MOUSE_BUTTON_LEFT
		fim.position = movimento.position
		viewport.push_input(fim, true)
	else:
		var inicio := InputEventScreenTouch.new()
		inicio.position = ponto
		inicio.pressed = true
		viewport.push_input(inicio, true)
		var movimento := InputEventScreenDrag.new()
		movimento.position = ponto + Vector2(0, 24)
		viewport.push_input(movimento, true)
		var fim := InputEventScreenTouch.new()
		fim.position = movimento.position
		viewport.push_input(fim, true)


func _executar() -> void:
	viewport = SubViewport.new()
	viewport.size = Vector2i(180, 320)
	var suporte := SubViewportContainer.new()
	root.add_child(suporte)
	suporte.add_child(viewport)
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	jogo.ativar_audio = false
	viewport.add_child(jogo)
	await acomodar()
	var menu: Control = jogo.interface_atual
	conferir(menu.find_child("ComoJogar", true, false) == null and not menu.has_node("TutorialDemonstrativo"), "Menu não oferece tutorial")
	jogo.iniciar_fase("teste_001")
	await acomodar()
	var nivel = jogo.mundo_atual
	var partida = nivel.partida
	var hud: CanvasLayer
	for filho in nivel.get_children():
		if filho.has_method("_criar_dica"):
			hud = filho
	hud.get_node("TituloFase")._encerrar()
	await acomodar()
	var tutorial = hud.get_node("DialogoDica/TutorialDemonstrativo")
	conferir(paused and tutorial.etapa == 0, "Primeira fase apresenta demonstração no diálogo automaticamente")
	conferir(tutorial.TITULOS.size() == 2, "Tutorial contém somente demonstrações de impulso e cancelamento")
	var saldo: int = partida.nave.combustivel
	var oxigenio: float = partida.tempo_restante
	var posicao: Vector2 = partida.nave.position
	var checkpoint: Dictionary = partida._checkpoint.duplicate(true)
	var tempo: float = tutorial.area._tempo
	tutorial.area._process(0.3)
	conferir(tutorial.area._tempo > tempo, "Demonstração anima enquanto a fase está pausada")
	for tamanho in [Vector2i(180, 240), Vector2i(180, 320), Vector2i(240, 320)]:
		viewport.size = tamanho
		await acomodar()
		var tela := Rect2(Vector2.ZERO, Vector2(tamanho))
		for etapa in 2:
			tutorial._mostrar_etapa(etapa)
			await acomodar()
			conferir(tela.encloses(tutorial._painel.get_global_rect()), "Painel cabe na etapa %d em %s" % [etapa, tamanho])
			conferir(tutorial._painel.get_global_rect().encloses(tutorial._avancar.get_global_rect()) and tutorial._painel.get_global_rect().encloses(tutorial.area.get_global_rect()) and tutorial.area.size.y >= 64, "Animação e navegação cabem no diálogo na etapa %d em %s" % [etapa, tamanho])
			conferir(tutorial._instrucao.get_global_rect().end.y <= tutorial.area.global_position.y and tutorial.area.get_global_rect().end.y <= tutorial._retorno.global_position.y, "Texto não cobre animação na etapa %d em %s" % [etapa, tamanho])
			for mouse in [false, true]:
				demonstrar_gesto(tutorial.area.global_position + Vector2(45, 24), mouse)
				await acomodar()
				conferir(tutorial.etapa == etapa and not tutorial._avancar.disabled, "Toque/mouse não altera demonstração nem condiciona o avanço")
	conferir(partida.nave.combustivel == saldo and partida.tempo_restante == oxigenio and partida.nave.position == posicao and partida._checkpoint == checkpoint, "Demonstração preserva recursos, posição e checkpoint")
	conferir(jogo.progresso.estado("teste_001") != "Concluída" and partida.nave.entrada.gesto.contato_ativo == -1, "Arrastar na demonstração não controla a nave real nem conclui a fase")
	tutorial._mostrar_etapa(0)
	conferir(tutorial._anterior.disabled and tutorial._avancar.text == "Próximo", "Demonstração inicial oferece Próximo sem exigir prática")
	tutorial._avancar.pressed.emit()
	conferir(tutorial.etapa == 1 and tutorial._avancar.text == "Jogar", "Próximo vai direto à demonstração de cancelamento")
	tutorial._anterior.pressed.emit()
	conferir(tutorial.etapa == 0, "Voltar permite rever o impulso")
	tutorial._avancar.pressed.emit()
	tutorial._avancar.pressed.emit()
	await acomodar()
	conferir(not paused and not hud.has_node("DialogoDica") and partida.nave.combustivel == saldo, "Jogar dispensa o diálogo e libera a fase sem gasto")
	hud._criar_dica()
	jogo.solicitar_voltar(true)
	await acomodar()
	conferir(not paused and not hud.has_node("DialogoDica") and partida.estado == partida.Estado.JOGANDO, "Voltar nativo dispensa demonstração sem abrir pausa")
	hud._criar_dica()
	var voltar := InputEventKey.new()
	voltar.keycode = KEY_ESCAPE
	voltar.pressed = true
	viewport.push_input(voltar, true)
	await acomodar()
	conferir(not paused and not hud.has_node("DialogoDica"), "Escape fecha o diálogo")
	jogo.preferencias.dicas = false
	hud._criar_dica()
	conferir(not hud.has_node("DialogoDica"), "Dicas desativadas ocultam demonstração automática")
	jogo.mostrar_menu()
	await acomodar()
	conferir(jogo.interface_atual.find_child("ComoJogar", true, false) == null, "Retorno ao menu mantém apenas as ações principais")
	jogo.queue_free()
	await acomodar()
	suporte.queue_free()
	await process_frame
	print("Tutorial demonstrativo: ", verificacoes, " verificações, ", falhas, " falhas.")
	quit(1 if falhas else 0)
