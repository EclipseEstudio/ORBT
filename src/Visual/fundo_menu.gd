extends Control
## Cenário apenas visual. Nunca recebe eventos nem participa do mundo físico.
var mostrar_planeta := true

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(queue_redraw)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("070e21"))
	var rng := RandomNumberGenerator.new()
	rng.seed = 731
	for i in 65:
		var p := Vector2(rng.randf() * size.x, rng.randf() * size.y).floor()
		draw_rect(Rect2(p, Vector2.ONE), Color("516382") if i % 4 else Color("c7e9ff"))
	if not mostrar_planeta:
		return
	var centro := Vector2(size.x * 0.73, size.y * 0.43).floor()
	for y in range(-19, 20):
		for x in range(-19, 20):
			if x * x + y * y <= 19 * 19:
				var cor := Color("ff9c38") if x > -7 else Color("bc4854")
				if (y + 24) % 9 < 3 and x > -7:
					cor = Color("ffca57")
				draw_rect(Rect2(centro + Vector2(x, y), Vector2.ONE), cor)
	for i in 44:
		var angulo := TAU * i / 44.0
		var p := centro + Vector2(cos(angulo) * 36, sin(angulo) * 12).rotated(-0.4)
		draw_rect(Rect2(p.floor(), Vector2.ONE), Color("537593"))
