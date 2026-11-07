extends Control

signal terminou
const Tema = preload("res://src/Visual/tema_visual.gd")
const LEITURA := 1.8
const FADE := 0.7
var titulo := ""
var ordem := 1

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
	var tween := create_tween()
	tween.tween_interval(LEITURA)
	tween.tween_property(self, "modulate:a", 0.0, FADE).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func():
		terminou.emit()
		queue_free())
