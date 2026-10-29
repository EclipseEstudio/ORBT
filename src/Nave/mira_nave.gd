extends Node2D

@onready var nave = get_parent().get_parent()
var pontos := PackedVector2Array()
var _acumulado := 1.0


func _ready() -> void:
	nave.get_node("Entrada").mira_encerrada.connect(limpar)
	nave.get_node("Entrada").impulso_solicitado.connect(func(_impulso: Vector2): limpar())


func limpar() -> void:
	pontos.clear()
	_acumulado = 1.0
	queue_redraw()


func _process(delta: float) -> void:
	if not nave.entrada.pode_controlar() or nave.entrada.gesto.contato_ativo == -1:
		limpar()
		return
	_acumulado += delta
	if _acumulado >= 1.0 / 15.0:
		pontos = nave.prever_trajetoria()
		_acumulado = 0.0
	queue_redraw()


func _draw() -> void:
	var entrada = nave.get_node("Entrada")
	if not entrada.pode_controlar() or entrada.gesto.contato_ativo == -1:
		return
	var origem: Vector2 = entrada.gesto.origem
	var valido: bool = not entrada.gesto.obter_impulso().is_zero_approx()
	var cor := Color("82f0d1") if valido else Color("f5cc77")
	draw_arc(origem, entrada.zona_morta, 0, TAU, 40, Color("0b1423"), 3)
	draw_arc(origem, entrada.zona_morta, 0, TAU, 40, cor, 1)
	if not valido:
		draw_line(origem - Vector2(3, 3), origem + Vector2(3, 3), cor, 1)
		draw_line(origem - Vector2(-3, 3), origem + Vector2(-3, 3), cor, 1)
	var transformacao: Transform2D = nave.get_canvas_transform()
	for indice in range(1, pontos.size()):
		draw_line(transformacao * pontos[indice - 1], transformacao * pontos[indice], Color("0b1423"), 3)
		draw_line(transformacao * pontos[indice - 1], transformacao * pontos[indice], Color("b8f5e2"), 1)
	if pontos.size() > 1:
		draw_circle(transformacao * pontos[-1], 2, cor, false, 1)
