extends Control

const Tema = preload("res://src/Visual/tema_visual.gd")


func _ready() -> void:
	theme = Tema.criar()


func _on_button_pressed() -> void:
	GLOBAL.controlador_jogo.mostrar_selecao.call_deferred()
