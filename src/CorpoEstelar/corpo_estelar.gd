extends Node2D
## Desenho não determina contato: a simulação usa os raios do JSON.

const Arte = preload("res://src/Visual/arte_pixel.gd")
const Marcas = preload("res://src/Visual/marcas_corpo.gd")
var sprite: Sprite2D
var marcas: Node2D

var dados: Dictionary = {}
var proximo := false:
	set(valor):
		proximo = valor
		if is_instance_valid(marcas):
			marcas.proximo = valor
			marcas.queue_redraw()


func _ready() -> void:
	position = dados.position
	sprite = Sprite2D.new()
	sprite.name = "Sprite"
	sprite.texture = Arte.textura("earth" if dados.type == "portal" else dados.type)
	sprite.visible = dados.type != "portal"
	Arte.ajustar(sprite, dados.visual_radius)
	if dados.type == "planet":
		sprite.modulate = Arte.cor_apoio(dados.id)
	add_child(sprite)
	marcas = Marcas.new()
	marcas.dados = dados
	marcas.proximo = proximo
	add_child(marcas)
