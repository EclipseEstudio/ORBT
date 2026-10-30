extends Node2D
## Seis quadros desenhados para ORBT, sem texturas ou amostras externas.
## Coordenadas locais: o bico da nave aponta para cima; o escape fica abaixo.

const QUADROS = [
	[" ooo ", " o*o ", " o*o ", "  o  "],
	[" ooo ", "o***o", " o*o ", " o*o ", "  o  ", "  o  "],
	[" ooo ", "o***o", "o***o", " o*o ", " o*o ", "  o  ", "  o  "],
	[" ooo ", "o***o", " o*o ", " o*o ", "  o  ", "  o  "],
	[" ooo ", " o*o ", " o*o ", "  o  ", "  o  "],
	[" ooo ", " o*o ", "  o  "],
]
const BORDA = Color("ffac78")
const NUCLEO = Color("f4f8ff")

@export_range(-1, 5) var quadro := -1:
	set(valor):
		quadro = clampi(valor, -1, 5)
		queue_redraw()


func _draw() -> void:
	if quadro < 0:
		return
	var linhas: Array = QUADROS[quadro]
	for y in range(linhas.size()):
		for x in range(linhas[y].length()):
			var pixel: String = linhas[y][x]
			if pixel != " ":
				draw_rect(Rect2(x, y, 1, 1), NUCLEO if pixel == "*" else BORDA)
