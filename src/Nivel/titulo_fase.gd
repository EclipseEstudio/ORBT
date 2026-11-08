extends Control

signal terminou
const Tema = preload("res://src/Visual/tema_visual.gd")
const LEITURA := 1.8
const FADE := 0.7
var titulo := ""
var ordem := 1
var _tween: Tween
var _encerrado := false

func _ready() -> void:
	name = "TituloFase"
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var centro := CenterContainer.new()
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(centro)
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margem := MarginContainer.new()
	margem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for lado in ["left", "right"]:
		margem.add_theme_constant_override("margin_" + lado, 12)
	centro.add_child(margem)
	var rotulo := Label.new()
	rotulo.theme = Tema.criar()
	rotulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rotulo.custom_minimum_size.x = 130
	rotulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rotulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rotulo.text = titulo
	margem.add_child(rotulo)
	_tween = create_tween()
	_tween.tween_interval(LEITURA)
	_tween.tween_property(self, "modulate:a", 0.0, FADE).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_callback(_encerrar)

func _input(evento: InputEvent) -> void:
	if (evento is InputEventScreenTouch and evento.pressed) or (evento is InputEventMouseButton and evento.pressed and evento.button_index == MOUSE_BUTTON_LEFT):
		get_viewport().set_input_as_handled()
		_encerrar.call_deferred()

func _encerrar() -> void:
	if _encerrado:
		return
	_encerrado = true
	if _tween != null:
		_tween.kill()
	hide()
	# O toque que dispensa o título não deve acionar a dica nem lançar a nave.
	terminou.emit()
	queue_free()
