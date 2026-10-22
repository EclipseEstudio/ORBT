extends Node2D
## Desenho não determina contato: a simulação usa os raios do JSON.

var dados: Dictionary = {}
var proximo := false:
	set(valor):
		proximo = valor
		queue_redraw()


func _ready() -> void:
	position = dados.position
	var textura: Texture2D
	if dados.type == "earth":
		textura = preload("res://Recursos/Sprites/Planetas/terra.png")
	elif dados.type in ["planet", "satellite"]:
		textura = preload("res://Recursos/Sprites/Planetas/marte.png")
	if textura != null:
		var sprite := Sprite2D.new()
		sprite.texture = textura
		sprite.scale = Vector2.ONE * dados.visual_radius * 2.0 / maxf(textura.get_width(), textura.get_height())
		add_child(sprite)
	queue_redraw()


func _draw() -> void:
	if dados.is_empty():
		return
	var cor := Color("8edacb")
	if dados.type in ["sun", "asteroid"]:
		cor = Color("ff9c7b")
		draw_circle(Vector2.ZERO, dados.visual_radius, Color("ed9d4c") if dados.type == "sun" else Color("787b91"))
		draw_line(Vector2(-4, -4), Vector2(4, 4), Color.WHITE, 2)
		draw_line(Vector2(-4, 4), Vector2(4, -4), Color.WHITE, 2)
		draw_arc(Vector2.ZERO, dados.danger_radius, 0, TAU, 48, cor, 1)
	elif dados.type == "earth":
		draw_arc(Vector2.ZERO, dados.capture_radius + 2, 0, TAU, 48, Color("80c9ff"), 1)
		draw_string(ThemeDB.fallback_font, Vector2(-14, -dados.visual_radius - 5), "TERRA", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color.WHITE)
	if proximo:
		draw_arc(Vector2.ZERO, dados.proximity_radius, 0, TAU, 64, Color(cor, 0.5), 1)
