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
	conferir(hud._mensagem.text.contains("custa 1") and hud._mensagem.text.contains("não recarrega"), "pós-lançamento explica combustível e pouso")
	var apoio: Dictionary = nivel.nivel_res.obter_corpo("apoio")
	nave.global_position = apoio.position + Vector2.LEFT * 25
	partida.resolver_contato({"kind": "body", "body": apoio})
	hud._process(0)
	conferir(nave.combustivel == 4 and hud._mensagem.text.contains("não recarrega"), "pouso não reabastece e mantém explicação")
	partida.pausar()
	hud._process(0)
	conferir(hud._mensagem.text.contains("pausada"), "pausa tem prioridade sobre dica")
	partida.retomar()
	partida.reiniciar()
	nivel.camera._process(2.0)
	hud._process(0)
	conferir(hud._mensagem.text.contains("Toque") and nave.combustivel == 5, "reinício apresenta tutorial novamente")
	nivel.queue_free()
	print("Tutorial: ", verificacoes, " verificações, ", falhas, " falhas.")
	quit(1 if falhas else 0)
