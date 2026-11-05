extends Node2D

@onready var nave = get_parent().get_parent()
var pontos := PackedVector2Array()

func pontos_forca() -> PackedVector2Array:
	var gesto = nave.entrada.gesto
	if gesto.contato_ativo == -1:
		return PackedVector2Array()
	return PackedVector2Array([gesto.origem, gesto.posicao])

func forca_saturada() -> bool:
	var gesto = nave.entrada.gesto
	return gesto.contato_ativo != -1 and gesto.origem.distance_to(gesto.posicao) >= gesto.arraste_maximo


func _ready() -> void:
	nave.get_node("Entrada").mira_encerrada.connect(limpar)
	nave.get_node("Entrada").impulso_solicitado.connect(func(_impulso: Vector2): limpar())


func limpar() -> void:
	pontos.clear()
	queue_redraw()


func _physics_process(_delta: float) -> void:
	if not nave.entrada.pode_controlar() or nave.entrada.gesto.contato_ativo == -1:
		limpar()
		return
	pontos = nave.obter_guia_mira()
	queue_redraw()


func _draw() -> void:
	var entrada = nave.get_node("Entrada")
	if not entrada.pode_controlar() or entrada.gesto.contato_ativo == -1:
		return
	var origem: Vector2 = entrada.gesto.origem
	var valido: bool = not entrada.gesto.obter_impulso().is_zero_approx()
	var cor := Color("82f0d1") if valido else Color("f5cc77")
	var linha := pontos_forca()
	var cor_forca := Color("ff9c38") if forca_saturada() else cor
	draw_line(linha[0], linha[1], Color("0b1423"), 3)
	draw_line(linha[0], linha[1], cor_forca, 1)
	draw_circle(linha[1], 3, Color("0b1423"))
	draw_circle(linha[1], 2, cor_forca)
	if forca_saturada():
		draw_arc(linha[1], 5, 0, TAU, 16, cor_forca, 1)
	draw_arc(origem, entrada.zona_morta, 0, TAU, 40, Color("0b1423"), 3)
	draw_arc(origem, entrada.zona_morta, 0, TAU, 40, cor, 1)
	if not valido:
		draw_line(origem - Vector2(3, 3), origem + Vector2(3, 3), cor, 1)
		draw_line(origem - Vector2(-3, 3), origem + Vector2(-3, 3), cor, 1)
	var transformacao: Transform2D = nave.get_canvas_transform()
	for indice in range(1, pontos.size()):
		if not pontos[indice-1].is_finite() or not pontos[indice].is_finite():
			continue
		draw_line(transformacao * pontos[indice - 1], transformacao * pontos[indice], Color("0b1423"), 3)
		draw_line(transformacao * pontos[indice - 1], transformacao * pontos[indice], Color("b8f5e2"), 1)
	if pontos.size() > 1:
		draw_circle(transformacao * pontos[-1], 2, cor, false, 1)
