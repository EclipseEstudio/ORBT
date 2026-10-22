extends Node2D

var dados: Dictionary = {}
var proximo := false
var depuracao := false
const ESCURO = Color("0b1423")


func traco(a: Vector2, b: Vector2, cor := Color.WHITE) -> void:
	draw_line(a, b, ESCURO, 3)
	draw_line(a, b, cor, 1)


func _draw() -> void:
	if dados.is_empty():
		return
	var perigoso: bool = dados.type in ["sun", "asteroid"]
	var cor := Color("ffac78") if perigoso else Color("82f0d1")
	var raio: float = dados.danger_radius if perigoso else dados.collision_radius
	# Contorno contínuo: contato; tracejado: aviso de proximidade, não gravidade.
	draw_arc(Vector2.ZERO, raio, 0, TAU, 64, ESCURO, 3)
	draw_arc(Vector2.ZERO, raio, 0, TAU, 64, cor, 1)
	if perigoso:
		traco(Vector2(-3, -3), Vector2(3, 3))
		traco(Vector2(-3, 3), Vector2(3, -3))
	elif dados.type == "earth":
		traco(Vector2(-4, 0), Vector2(0, -4))
		traco(Vector2(0, -4), Vector2(4, 0))
		traco(Vector2(-3, 0), Vector2(-3, 4))
		traco(Vector2(3, 0), Vector2(3, 4))
		traco(Vector2(-3, 4), Vector2(3, 4))
		draw_string(ThemeDB.fallback_font, Vector2(-14, -dados.visual_radius - 5), "TERRA", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color.WHITE)
	else:
		traco(Vector2(-3, 0), Vector2(3, 0))
		traco(Vector2(0, -3), Vector2(0, 3))
	if proximo:
		for indice in range(16):
			var inicio := indice * TAU / 16
			draw_arc(Vector2.ZERO, dados.proximity_radius, inicio, inicio + TAU / 32, 4, cor, 1)
	if depuracao:
		draw_arc(Vector2.ZERO, dados.visual_radius, 0, TAU, 64, Color.GRAY, 1)
		draw_arc(Vector2.ZERO, dados.capture_radius, 0, TAU, 64, Color.CYAN, 1)
