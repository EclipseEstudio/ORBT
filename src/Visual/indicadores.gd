extends Control
## Oxigênio do voo atual, ao longo de toda a largura útil do HUD.

var tempo := 0.0
var duracao := 1.0

func _ready() -> void:
	custom_minimum_size.y = 8
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	var restante := clampf(tempo / maxf(0.01, duracao), 0, 1)
	var barra := Rect2(Vector2.ZERO, size)
	draw_rect(barra, Color("070e21"))
	draw_rect(barra, Color("c4dbf4"), false, 1)
	draw_rect(Rect2(Vector2.ONE, Vector2(maxf(0, size.x - 2) * restante, maxf(0, size.y - 2))), Color("ff9c38") if restante < 0.2 else Color("42f5d1"))
