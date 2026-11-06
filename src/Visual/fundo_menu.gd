extends Control
## Cenário apenas visual. Nunca recebe eventos nem participa do mundo físico.
var mostrar_planeta := true
var apenas_estrelas := false
var textura: Texture2D
const CAMINHO_TEXTURA := "res://Recursos/ModelosVisuais/fundo_menu.png"
var _tempo := 0.0
var _deslocamento := Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if not apenas_estrelas and textura == null and ResourceLoader.exists(CAMINHO_TEXTURA):
		textura = load(CAMINHO_TEXTURA)
	resized.connect(queue_redraw)
	var estrelas := preload("res://src/Visual/ceu_parallax.gd").new()
	estrelas.name = "EstrelasParallax"
	estrelas.animar = true
	add_child(estrelas)

func _process(delta: float) -> void:
	_tempo += delta
	var alvo := Vector2(sin(_tempo * 0.09), cos(_tempo * 0.07)) * 3.0
	if not OS.has_feature("android"):
		alvo += (get_local_mouse_position() / size.max(Vector2.ONE) - Vector2(0.5, 0.5)).limit_length(0.7) * 3.0
	_deslocamento = _deslocamento.lerp(alvo, 1.0 - exp(-delta * 2.0))
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("070e21"))
	if apenas_estrelas:
		return
	if textura != null:
		var escala := maxf((size.x + 20) / textura.get_width(), (size.y + 20) / textura.get_height())
		var dimensoes := Vector2(textura.get_size()) * escala
		draw_texture_rect(textura, Rect2((size - dimensoes) / 2 + _deslocamento, dimensoes), false)
		return
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
	# Composição do wireframe: nave abaixo do planeta, com rastro curvo.
	var nave := Vector2(size.x * 0.48, size.y * 0.64).floor()
	var escala := minf(size.x / 180.0, size.y / 240.0)
	var casco := PackedVector2Array([Vector2(-22, 7), Vector2(-8, -4), Vector2(20, 4), Vector2(-4, 6), Vector2(-24, 16), Vector2(-16, 6)])
	for i in casco.size():
		casco[i] = nave + casco[i] * escala
	draw_colored_polygon(casco, Color("426682"))
	draw_polyline(PackedVector2Array([casco[0], casco[1], casco[2], casco[3], casco[4], casco[5], casco[0]]), Color("91d7e5"), 1)
	draw_line(nave + Vector2(1, -1) * escala, nave + Vector2(7, 1) * escala, Color("42f5d1"), 2)
	draw_line(nave + Vector2(-21, 3) * escala, nave + Vector2(-30, 1) * escala, Color("ffca57"), 2)
	draw_arc(nave + Vector2(-1, -27) * escala, 40 * escala, 1.6, 3.9, 24, Color("24405b"), 1)
