extends SceneTree

const Carregador = preload("res://src/Nivel/carregador_fase.gd")
const CenaNivel = preload("res://src/Nivel/Nivel.tscn")
const ESTREIAS := ["teste_001", "primeiro_pouso", "segundo_impulso", "de_lua_em_lua", "rasante_solar", "lua_em_movimento", "pouso_de_precisao", "fenda_no_espaco", "nevoa_cega"]
var verificacoes := 0
var falhas := 0

func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)

func toque(indice: int, ponto: Vector2, pressionado: bool) -> void:
	var evento := InputEventScreenTouch.new()
	evento.index = indice
	evento.position = ponto
	evento.pressed = pressionado
	root.push_input(evento, true)

func arrastar(indice: int, ponto: Vector2) -> void:
	var evento := InputEventScreenDrag.new()
	evento.index = indice
	evento.position = ponto
	root.push_input(evento, true)

func _initialize() -> void:
	_executar.call_deferred()

func _executar() -> void:
	var nivel = CenaNivel.instantiate()
	nivel.nivel_res = Carregador.carregar("res://Recursos/Fases/teste_001.json").nivel
	root.add_child(nivel)
	await process_frame
	var partida = nivel.partida
	var nave = nivel.get_node("Nave")
	partida.set_physics_process(false)
	nivel.camera._process(2.0)
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	var hud: CanvasLayer
	for item in nivel.get_children():
		if item is CanvasLayer and item.get_script() != null and item.get_script().resource_path == "res://src/Nivel/interface_partida.gd":
			hud = item
	conferir(hud.has_node("TituloFase") and not hud.has_node("DialogoDica"), "Título precede a dica")
	await hud.get_node("TituloFase").terminou
	var dica := hud.get_node("DialogoDica")
	conferir(paused and dica.has_node("TutorialDemonstrativo") and dica.get_node("TutorialDemonstrativo").etapa == 0, "Primeira fase apresenta tutorial demonstrativo no diálogo antes da tentativa")
	conferir(dica.z_index > hud._bussola.z_index, "Diálogo da dica cobre a bússola para preservar a leitura")
	var saldo_inicial: int = nave.combustivel
	toque(8, Vector2(5, 5), true)
	toque(8, Vector2(5, 5), false)
	conferir(nave.entrada.gesto.contato_ativo == -1 and nave.combustivel == saldo_inicial, "Fundo da dica não inicia gesto")
	dica.find_children("*", "Button", true, false)[0].pressed.emit()
	await process_frame
	await process_frame
	conferir(not paused and not hud.has_node("DialogoDica"), "Fechar tutorial dispensa diálogo e libera a tentativa")
	conferir(not hud._mensagem.is_visible_in_tree(), "Primeira tentativa começa sem dica textual")
	toque(0, Vector2(90, 145), true)
	conferir(nave.entrada.gesto.contato_ativo == 0, "toque livre inicia mira")
	arrastar(0, Vector2(90, 190))
	arrastar(0, Vector2(90, 145))
	toque(0, Vector2(90, 145), false)
	partida.avancar(1.0 / 60)
	conferir(nave.combustivel == 5 and nave.condicao == nave.Condicao.POUSADA, "voltar ao círculo cancela sem gasto")
	toque(1, Vector2(90, 145), true)
	arrastar(1, Vector2(90, 225))
	toque(1, Vector2(90, 225), false)
	partida.avancar(1.0 / 60)
	conferir(nave.combustivel == 4 and nave.condicao == nave.Condicao.EM_VOO, "soltar lança uma vez e custa uma unidade")
	var apoio: Dictionary = nivel.nivel_res.obter_corpo("apoio")
	nave.global_position = apoio.position + Vector2.LEFT * 25
	partida.resolver_contato({"kind": "body", "body": apoio})
	conferir(nave.combustivel == 4, "pouso não reabastece")
	partida.reiniciar()
	await process_frame
	conferir(not hud.has_node("DialogoDica") and nave.combustivel == 5, "reinício repõe recursos sem repetir tutorial")
	conferir(not hud._mensagem.is_visible_in_tree(), "Reiniciar sem derrota não libera a dica textual")
	partida.finalizar(false, "Colisão com perigo")
	hud._process(1.0)
	conferir(not hud._mensagem.is_visible_in_tree() and hud._dialogo_derrota.visible, "Derrota mostra o resultado antes da dica")
	hud._dialogo_derrota._resetar.pressed.emit()
	hud._process(0)
	conferir(hud._mensagem.is_visible_in_tree() and hud._mensagem.text == nivel.nivel_res.dados_autorais.tutorial and not paused, "Repetir após perder exibe a dica autoral sem pausar")
	hud._process(10.0)
	conferir(hud._mensagem.is_visible_in_tree(), "Dica permanece até a confirmação")
	for quadro in 4:
		await process_frame
	var ok := hud.find_child("ConfirmarDicaTextual", true, false) as Button
	conferir(ok.text == "OK" and root.get_visible_rect().encloses(ok.get_global_rect()), "Botão OK fica acessível no rodapé")
	for pressionado in [true, false]:
		var evento := InputEventScreenTouch.new()
		evento.position = root.get_final_transform() * ok.get_global_rect().get_center()
		evento.pressed = pressionado
		Input.parse_input_event(evento)
		Input.flush_buffered_events()
	hud._process(0)
	conferir(not hud._mensagem.is_visible_in_tree() and nave.entrada.gesto.contato_ativo == -1 and nave.combustivel == saldo_inicial, "Tocar em OK fecha a dica sem acionar a nave")
	partida.finalizar(false, "Oxigênio esgotado")
	conferir(partida.restaurar_checkpoint(), "Último pouso pode ser restaurado após derrota")
	hud._process(0)
	conferir(hud._mensagem.is_visible_in_tree(), "Voltar ao último pouso também apresenta dica textual")
	nivel.queue_free()
	await process_frame
	await _conferir_dicas_campanha()
	print("Tutorial: ", verificacoes, " verificações, ", falhas, " falhas.")
	quit(1 if falhas else 0)


func _conferir_dicas_campanha() -> void:
	var catalogo: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://Recursos/Niveis.json"))
	for tamanho in [Vector2i(180, 240), Vector2i(180, 320)]:
		var suporte := SubViewportContainer.new()
		root.add_child(suporte)
		var viewport := SubViewport.new()
		viewport.size = tamanho
		suporte.add_child(viewport)
		for id_fase in catalogo:
			var nivel = CenaNivel.instantiate()
			nivel.nivel_res = Carregador.carregar(catalogo[id_fase]).nivel
			viewport.add_child(nivel)
			nivel.partida.set_physics_process(false)
			await process_frame
			var hud: CanvasLayer
			for item in nivel.get_children():
				if item.has_method("_criar_dica"):
					hud = item
			hud.get_node("TituloFase")._encerrar()
			var contexto := "%s em %s: " % [id_fase, tamanho]
			var tutorial = hud.get_node_or_null("DialogoDica/TutorialDemonstrativo")
			if id_fase in ESTREIAS:
				conferir(paused and tutorial != null, contexto + "estreia pausa a fase e abre demonstração")
				if tutorial != null:
					for quadro in 6:
						await process_frame
					var tela := Rect2(Vector2.ZERO, Vector2(tamanho))
					var painel: Rect2 = tutorial._painel.get_global_rect()
					conferir(tela.encloses(painel) and painel.encloses(tutorial._instrucao.get_global_rect()) and painel.encloses(tutorial.area.get_global_rect()) and painel.encloses(tutorial._avancar.get_global_rect()), contexto + "instrução, animação e botão cabem no painel")
					if id_fase == "teste_001":
						tutorial._avancar.pressed.emit()
					tutorial._avancar.pressed.emit()
					await process_frame
					await process_frame
					conferir(not paused and not hud.has_node("DialogoDica"), contexto + "Jogar retoma a fase")
			else:
				conferir(not paused and not hud.has_node("DialogoDica"), contexto + "fase sem novidade começa direto")
			nivel.queue_free()
			await process_frame
		suporte.queue_free()
		await process_frame
