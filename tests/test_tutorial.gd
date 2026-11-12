extends SceneTree

const Carregador = preload("res://src/Nivel/carregador_fase.gd")
const CenaNivel = preload("res://src/Nivel/Nivel.tscn")
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
	hud._process(0)
	conferir(hud._mensagem.text.contains("Toque") and hud._mensagem.text.contains("Arraste para baixo"), "instrução inicial mostra toque e dica autoral")
	conferir(hud._mensagem.mouse_filter == Control.MOUSE_FILTER_IGNORE, "texto não intercepta entrada")
	toque(0, Vector2(90, 145), true)
	hud._process(0)
	conferir(nave.entrada.gesto.contato_ativo == 0 and hud._mensagem.text.contains("Arraste") and hud._mensagem.text.contains("cancelar"), "toque livre inicia mira e ensina cancelamento")
	arrastar(0, Vector2(90, 190))
	hud._process(0)
	conferir(hud._mensagem.text.contains("Solte") and hud._mensagem.text.contains("custa 1") and hud._mensagem.text.contains("cancelar"), "arraste mostra soltura, custo e cancelamento")
	arrastar(0, Vector2(90, 145))
	toque(0, Vector2(90, 145), false)
	partida.avancar(1.0 / 60)
	conferir(nave.combustivel == 5 and nave.condicao == nave.Condicao.POUSADA, "voltar ao círculo cancela sem gasto")
	toque(1, Vector2(90, 145), true)
	arrastar(1, Vector2(90, 225))
	toque(1, Vector2(90, 225), false)
	partida.avancar(1.0 / 60)
	hud._process(0)
	conferir(nave.combustivel == 4 and nave.condicao == nave.Condicao.EM_VOO, "soltar lança uma vez e custa uma unidade")
	partida.alternar_exploracao()
	hud._process(0)
	conferir(hud._mensagem.text.contains("continua diminuindo"), "explorar em voo informa que oxigênio continua sendo consumido")
	partida.alternar_exploracao()
	hud._process(0)
	conferir(hud._mensagem.text.contains("custa 1") and hud._mensagem.text.contains("não recarrega"), "pós-lançamento explica combustível e pouso")
	var apoio: Dictionary = nivel.nivel_res.obter_corpo("apoio")
	nave.global_position = apoio.position + Vector2.LEFT * 25
	partida.resolver_contato({"kind": "body", "body": apoio})
	hud._process(0)
	conferir(nave.combustivel == 4 and hud._mensagem.text.contains("não recarrega"), "pouso não reabastece e mantém explicação")
	partida.alternar_exploracao()
	hud._process(0)
	conferir(hud._mensagem.text.contains("interrompe") and not hud._mensagem.text.contains("continua diminuindo"), "explorar pousado informa que oxigênio não é consumido")
	partida.alternar_exploracao()
	partida.pausar()
	hud._process(0)
	conferir(hud._mensagem.text.contains("pausada"), "pausa tem prioridade sobre dica")
	partida.retomar()
	partida.reiniciar()
	nivel.camera._process(2.0)
	hud._process(0)
	conferir(hud._mensagem.text.contains("Toque") and nave.combustivel == 5, "reinício apresenta tutorial novamente")
	nivel.queue_free()
	await process_frame
	await _conferir_dicas_campanha()
	print("Tutorial: ", verificacoes, " verificações, ", falhas, " falhas.")
	quit(1 if falhas else 0)


func _conferir_dicas_campanha() -> void:
	var catalogo: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://Recursos/Niveis.json"))
	for tamanho in [Vector2i(180, 240), Vector2i(180, 320)]:
		var viewport := SubViewport.new()
		viewport.size = tamanho
		root.add_child(viewport)
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
			for quadro in 6:
				await process_frame
			var dialogo := hud.get_node("DialogoDica")
			var rotulo: Label = dialogo.find_children("*", "Label", true, false)[0]
			var botao: Button = dialogo.find_children("*", "Button", true, false)[0]
			var painel: PanelContainer = dialogo.find_children("*", "PanelContainer", true, false)[0]
			var tela := Rect2(Vector2.ZERO, Vector2(tamanho))
			var contexto := "%s em %s: " % [id_fase, tamanho]
			var primeira_fase: bool = nivel.nivel_res.id == "teste_001"
			conferir(paused and (dialogo.has_node("TutorialDemonstrativo") if primeira_fase else rotulo.text == nivel.nivel_res.dados_autorais.tutorial), contexto + "exibe tutorial integrado na primeira fase e dica autoral nas demais")
			conferir(tela.encloses(painel.get_global_rect()) and painel.get_global_rect().encloses(rotulo.get_global_rect()), contexto + "painel e texto cabem na tela")
			conferir(tela.encloses(botao.get_global_rect()) and botao.size.x >= (32 if primeira_fase else 64) and botao.size.y >= (28 if primeira_fase else 32), contexto + "ação de saída permanece visível e alcançável")
			botao.pressed.emit()
			await process_frame
			await process_frame
			conferir(not paused and not hud.has_node("DialogoDica"), contexto + "confirmar retoma a tentativa")
			nivel.queue_free()
			await process_frame
		viewport.queue_free()
		await process_frame
