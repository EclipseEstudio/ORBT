extends Control

const Tema = preload("res://src/Visual/tema_visual.gd")
signal fechada
var preferencias: RefCounted
var _aviso: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	theme = Tema.criar()
	var fundo := ColorRect.new()
	fundo.color = Color("0b1423")
	add_child(fundo)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margem := MarginContainer.new()
	add_child(margem)
	margem.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for lado in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margem.add_theme_constant_override(lado, 12)
	var coluna := VBoxContainer.new()
	coluna.alignment = BoxContainer.ALIGNMENT_CENTER
	coluna.add_theme_constant_override("separation", 8)
	margem.add_child(coluna)
	var titulo := Label.new()
	titulo.text = "Configurações"
	titulo.add_theme_font_size_override("font_size", 14)
	coluna.add_child(titulo)
	_criar_volume(coluna, "Música", "musica", preferencias.musica)
	_criar_volume(coluna, "Efeitos", "efeitos", preferencias.efeitos)
	_aviso = Label.new()
	_aviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_aviso.add_theme_font_size_override("font_size", 9)
	_aviso.text = preferencias.aviso
	coluna.add_child(_aviso)
	var voltar := Button.new()
	voltar.name = "Voltar"
	voltar.text = "Voltar"
	voltar.custom_minimum_size.y = 36
	voltar.add_theme_font_size_override("font_size", 10)
	coluna.add_child(voltar)
	voltar.pressed.connect(func(): fechada.emit(); queue_free())

func _criar_volume(coluna: VBoxContainer, titulo: String, campo: String, valor: float) -> void:
	var rotulo := Label.new()
	rotulo.add_theme_font_size_override("font_size", 10)
	coluna.add_child(rotulo)
	var seletor := HSlider.new()
	seletor.name = campo
	seletor.min_value = 0
	seletor.max_value = 1
	seletor.step = 0.05
	seletor.custom_minimum_size.y = 30
	seletor.value = valor
	coluna.add_child(seletor)
	rotulo.text = "%s: %d%%" % [titulo, roundi(valor * 100)]
	seletor.value_changed.connect(func(novo: float):
		preferencias.alterar(campo, novo)
		rotulo.text = "%s: %d%%" % [titulo, roundi(novo * 100)]
		_aviso.text = preferencias.aviso)
