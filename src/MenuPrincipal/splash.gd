extends Control
## Apresentação visual da sessão; toque/tecla permite antecipar o fechamento.

static var exibido := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var fundo := ColorRect.new()
	fundo.color = Color("070e21")
	fundo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fundo)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var centro := CenterContainer.new()
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centro)
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 10)
	centro.add_child(coluna)
	var marca := TextureRect.new()
	marca.texture = preload("res://Recursos/Sprites/eclipse-estudio.svg")
	marca.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	marca.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	marca.custom_minimum_size = Vector2(48, 48)
	coluna.add_child(marca)
	var estudio := Label.new()
	estudio.text = "ECLIPSE\nESTUDIO"
	estudio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	estudio.add_theme_font_size_override("font_size", 8)
	coluna.add_child(estudio)
	get_tree().create_timer(1.5).timeout.connect(queue_free)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		queue_free()
