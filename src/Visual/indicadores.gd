extends Control
## Oxigênio do voo atual, ao longo de toda a largura útil do HUD.

var tempo := 0.0
var duracao := 1.0
const FONTE = preload("res://Recursos/Fontes/PressStart2P-Regular.ttf")
const COR_FUNDO = Color("070e21")

func _ready() -> void:
	custom_minimum_size.y = 8
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	var restante := clampf(tempo / maxf(0.01, duracao), 0, 1)
	var barra := Rect2(Vector2.ZERO, size)
	draw_rect(barra, COR_FUNDO)
	draw_rect(barra, Color("c4dbf4"), false, 1)
	draw_rect(Rect2(Vector2.ONE, Vector2(maxf(0, size.x - 2) * restante, maxf(0, size.y - 2))), Color("ff9c38") if restante < 0.2 else Color("87b6d9"))
	var posicao := Vector2(3, roundf((size.y + 4) / 2.0 - 1))
	var subscrito := posicao + Vector2(FONTE.get_string_size("O", HORIZONTAL_ALIGNMENT_LEFT, -1, 4).x, 1)
	draw_string(FONTE, posicao, "O", HORIZONTAL_ALIGNMENT_LEFT, -1, 4, COR_FUNDO)
	draw_string(FONTE, subscrito, "2", HORIZONTAL_ALIGNMENT_LEFT, -1, 3, COR_FUNDO)
