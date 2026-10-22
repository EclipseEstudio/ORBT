extends Control
## Barras redundantes: os valores completos permanecem no texto do HUD.

var combustivel := 0
var capacidade := 1
var tempo := 0.0
var duracao := 1.0


func _ready() -> void:
	custom_minimum_size.y = 9
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var largura := minf(size.x / 2 - 4, 65)
	var altura := 5.0
	var saldo := clampf(float(combustivel) / maxf(1, capacidade), 0, 1)
	var restante := clampf(tempo / maxf(0.01, duracao), 0, 1)
	for indice in range(5):
		var celula := Rect2(Vector2(indice * largura / 5, 1), Vector2(largura / 5 - 2, altura))
		draw_rect(celula, Color("09101b"))
		draw_rect(celula, Color("82f0d1"), false, 1)
		if saldo >= float(indice + 1) / 5:
			draw_rect(celula.grow(-1), Color("82f0d1"))
	var relogio := Rect2(Vector2(largura + 8, 1), Vector2(largura, altura))
	draw_rect(relogio, Color("09101b"))
	draw_rect(relogio, Color.WHITE, false, 1)
	draw_rect(Rect2(relogio.position + Vector2.ONE, Vector2((largura - 2) * restante, altura - 2)), Color("ffac78") if restante < 0.2 else Color("c4dbf4"))
