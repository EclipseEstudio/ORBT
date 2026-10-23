@tool
extends Node2D

@export var tamanho := Vector2(180.0, 320.0)
@export var numero_de_estrelas := 50

func _draw() -> void:
	var sorteio := RandomNumberGenerator.new()
	sorteio.seed = 731
	for i in range(numero_de_estrelas):
		var pos := Vector2(sorteio.randf_range(0, tamanho.x), sorteio.randf_range(0, tamanho.y)).floor()
		draw_rect(Rect2(pos, Vector2.ONE), Color("394c65"))
