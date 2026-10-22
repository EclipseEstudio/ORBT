@tool
extends Node2D

@export var tamanho := Vector2(180.0, 320.0)
@export var numero_de_estrelas := 50

func _draw() -> void:
	for i in range(numero_de_estrelas):		
		var pos = Vector2(randf_range(0, 180), randf_range(0, 320))
		draw_rect(Rect2(pos, Vector2(1, 1)), Color.WHITE)
