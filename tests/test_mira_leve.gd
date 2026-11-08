extends SceneTree

var verificacoes := 0
var falhas := 0

func conferir(ok: bool, mensagem: String) -> void:
	verificacoes += 1
	if not ok:
		falhas += 1
		push_error(mensagem)

func _initialize() -> void:
	_executar.call_deferred()

func _executar() -> void:
	var nave = load("res://src/Nave/Nave.tscn").instantiate()
	nave.simulacao_automatica = false
	root.add_child(nave)
	await process_frame
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	nave.condicao = nave.Condicao.POUSADA
	nave.posicao_relativa = Vector2.UP * 30
	nave.global_position = Vector2(90, 200)
	conferir(nave.obter_guia_mira().is_empty(), "Sem gesto não há guia")
	for arraste in [Vector2(20, 0), Vector2(80, 0), Vector2(0, -80), Vector2(-50, 50)]:
		nave.entrada.gesto.iniciar(0, Vector2(90, 100))
		nave.entrada.gesto.mover(0, Vector2(90, 100) - arraste)
		var guia: PackedVector2Array = nave.obter_guia_mira()
		var tela: Transform2D = nave.get_canvas_transform()
		conferir(guia.size() == 2 and guia[0] == nave.global_position, "Guia contém apenas origem e destino")
		var bloqueado: bool = nave.lancamento_bloqueado(arraste)
		conferir(is_equal_approx((tela * guia[0]).distance_to(tela * guia[1]), 8 if bloqueado else 60), "Guia curta indica bloqueio; direção livre mantém 60 pixels")
		nave._atualizar_orientacao(0)
		conferir(Vector2.UP.rotated(nave.global_rotation).is_equal_approx(arraste.normalized()), "Nave pousada aponta imediatamente na direção da mira")
		nave.entrada.cancelar()
	nave._atualizar_orientacao(0)
	conferir(Vector2.UP.rotated(nave.global_rotation).is_equal_approx(Vector2.UP), "Cancelar recupera orientação do pouso")
	root.canvas_transform = Transform2D(0, Vector2(0.5, 0.5), 0, Vector2.ZERO)
	nave.entrada.gesto.iniciar(0, Vector2(90, 100))
	nave.entrada.gesto.mover(0, Vector2(10, 100))
	var guia_zoom: PackedVector2Array = nave.obter_guia_mira()
	var tela_zoom: Transform2D = nave.get_canvas_transform()
	conferir(is_equal_approx((tela_zoom * guia_zoom[0]).distance_to(tela_zoom * guia_zoom[1]), 60), "Zoom não altera comprimento aparente da guia")
	# Objetos incompletos do editor são ignorados; a guia não integra trajetórias.
	nave.corpos = [{}]
	var inicio := Time.get_ticks_usec()
	for i in 10000:
		nave.obter_guia_mira()
	print("Guia: 10.000 atualizações em %d microssegundos" % (Time.get_ticks_usec() - inicio))
	conferir(nave.combustivel == 5 and nave.global_position == Vector2(90, 200), "Guia não muda posição nem combustível")
	nave.entrada.cancelar()
	nave.condicao = nave.Condicao.EM_VOO
	for velocidade in [Vector2.RIGHT, Vector2.DOWN, Vector2(-2, -3)]:
		nave.velocidade = velocidade
		nave._atualizar_orientacao(0)
		conferir(Vector2.UP.rotated(nave.global_rotation).is_equal_approx(velocidade.normalized()), "Durante o voo nave aponta na direção da velocidade")
	nave.velocidade = Vector2.ZERO
	var orientacao: float = nave.global_rotation
	nave._atualizar_orientacao(0)
	conferir(nave.global_rotation == orientacao, "Vetor nulo preserva orientação")
	nave.entrada.habilitada = false
	conferir(nave.obter_guia_mira().is_empty(), "Entrada bloqueada não exibe guia")
	nave.queue_free()
	await process_frame
	print("Mira leve: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas else 0)
