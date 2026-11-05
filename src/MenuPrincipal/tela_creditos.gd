extends Control

const Tema = preload("res://src/Visual/tema_visual.gd")
const AreaSegura = preload("res://src/Visual/area_segura_menu.gd")
const Icones = preload("res://src/Visual/icones_ui.gd")
var _margem: MarginContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	theme = Tema.criar()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var fundo := preload("res://src/Visual/fundo_menu.gd").new()
	fundo.mostrar_planeta = false
	add_child(fundo)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margem := MarginContainer.new()
	_margem = margem
	add_child(margem)
	margem.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for lado in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margem.add_theme_constant_override(lado, 8)
	var coluna := VBoxContainer.new()
	margem.add_child(coluna)
	var cabecalho := HBoxContainer.new()
	cabecalho.name = "Cabecalho"
	coluna.add_child(cabecalho)
	var voltar := Button.new()
	voltar.name = "Voltar"
	Icones.aplicar(voltar, "voltar", "Voltar")
	voltar.pressed.connect(fechar)
	cabecalho.add_child(voltar)
	var titulo := Label.new()
	titulo.text = "CRÉDITOS"
	titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titulo.add_theme_font_size_override("font_size", 8)
	cabecalho.add_child(titulo)
	var rolagem := ScrollContainer.new()
	rolagem.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rolagem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	coluna.add_child(rolagem)
	var texto := Label.new()
	texto.name = "Texto"
	texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.add_theme_font_size_override("font_size", 8)
	texto.text = "Miguel Alves Cordeiro Braz\n\nRubensAugustoMM"
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.size_flags_vertical = Control.SIZE_EXPAND_FILL
	texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	rolagem.add_child(texto)
	get_viewport().size_changed.connect(_area_segura)
	_area_segura()

func fechar() -> void:
	queue_free()

func _area_segura() -> void:
	AreaSegura.aplicar(_margem, 0, AreaSegura.fisica())

func _process(_delta: float) -> void:
	if OS.has_feature("android"):
		_area_segura()
