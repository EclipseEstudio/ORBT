class_name ControladorJogo extends Node

@onready var mundo: Node = $Mundo
@onready var interface: Control = $Interface
var mundo_atual: Node2D
var interface_atual: Control


func _ready() -> void:
	GLOBAL.controlador_jogo = self
	if interface.get_child_count() > 0:
		interface_atual = interface.get_child(0)
	if mundo.get_child_count() > 0:
		mundo_atual = mundo.get_child(0)
	if OS.has_feature("android"):
		iniciar_fase("teste_001")


func iniciar_fase(id_nivel: String) -> bool:
	var instancia := GLOBAL.gerendiador_de_nivel.obter_nivel_instancia(id_nivel)
	if instancia == null:
		return false
	get_tree().paused = false
	alterar_mundo_nodo(instancia)
	var vazio := Control.new()
	vazio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	alterar_interface_nodo(vazio)
	return true


func alterar_interface(caminho: String, deletar := true, manter_rodando := false) -> void:
	var cena = load(caminho)
	if cena is PackedScene:
		var instancia = cena.instantiate()
		if instancia is Control:
			alterar_interface_nodo(instancia, deletar, manter_rodando)
		else:
			instancia.free()


func alterar_interface_nodo(nova: Control, _deletar := true, manter_rodando := false) -> void:
	if is_instance_valid(interface_atual):
		if manter_rodando:
			interface_atual.hide()
		else:
			interface.remove_child(interface_atual)
			interface_atual.queue_free()
	interface_atual = nova
	interface.add_child(nova)


func alterar_mundo(caminho: String, deletar := true, manter_rodando := false) -> void:
	var cena = load(caminho)
	if cena is PackedScene:
		var instancia = cena.instantiate()
		if instancia is Node2D:
			alterar_mundo_nodo(instancia, deletar, manter_rodando)
		else:
			instancia.free()


func alterar_mundo_nodo(novo: Node2D, _deletar := true, manter_rodando := false) -> void:
	if is_instance_valid(mundo_atual):
		if manter_rodando:
			mundo_atual.hide()
		else:
			mundo.remove_child(mundo_atual)
			mundo_atual.queue_free()
	mundo_atual = novo
	mundo.add_child(novo)
