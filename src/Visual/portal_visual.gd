extends Node2D
## Disco de acreção e partículas em espiral: entrada absorve, saída expele.
var dados: Dictionary = {}
var proximo := false
var _tempo := 0.0

func _process(delta: float) -> void:
	_tempo = fposmod(_tempo + delta, 120.0)
	queue_redraw()

func _draw() -> void:
	if dados.is_empty():
		return
	var saida: bool = dados.get("_portal_saida", false)
	var raio: float = dados.visual_radius
	var cor := Color("d5edff") if saida else Color("ad78ef")
	for camada in range(4, 0, -1):
		draw_circle(Vector2.ZERO, raio * (1.0 + camada * 0.15), Color(cor, 0.045 * (5 - camada)))
	# Arcos elípticos sugerem um disco inclinado.
	for anel in range(3):
		var pontos := PackedVector2Array()
		for i in range(49):
			var angulo := i * TAU / 48.0
			var r := raio * (1.0 + anel * 0.18)
			pontos.append(Vector2(cos(angulo) * r, sin(angulo) * r * 0.42).rotated(-0.35))
		draw_polyline(pontos, Color(cor, 0.35 + anel * 0.15), 1)
	draw_circle(Vector2.ZERO, raio * 0.78, Color("f4f8ff") if saida else Color("03030b"))
	draw_arc(Vector2.ZERO, raio * 0.8, 0, TAU, 48, cor, 2)
	if saida:
		draw_circle(Vector2.ZERO, raio * 0.48, Color.WHITE)
	for i in range(28):
		var ciclo := fposmod(_tempo * 0.65 + i * 0.618034, 1.0)
		var progresso := ciclo if saida else 1.0 - ciclo
		var distancia := raio * lerpf(0.85, 2.5, progresso)
		var angulo := i * 2.39996 + _tempo * (1.2 if saida else -1.2) + progresso * 2.2
		var ponto := Vector2.RIGHT.rotated(angulo) * distancia
		var anterior := Vector2.RIGHT.rotated(angulo - 0.09) * (distancia + (-1.5 if saida else 1.5))
		var alfa := sin(ciclo * PI)
		draw_line(anterior.round(), ponto.round(), Color(cor, alfa), 1)
		draw_rect(Rect2(ponto.round(), Vector2.ONE * (2 if i % 6 == 0 else 1)), Color(Color.WHITE if saida else cor.lightened(0.3), alfa))
