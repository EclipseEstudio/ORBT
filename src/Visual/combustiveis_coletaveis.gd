extends Node2D
const Icones = preload("res://src/Visual/icones_ui.gd")
var partida: Node
var _tempo := 0.0

func _process(delta: float) -> void:
	if partida.estado == partida.Estado.JOGANDO:
		_tempo += delta
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(partida):
		return
	for tanque in partida.nivel.combustiveis:
		if partida.combustiveis_coletados.has(tanque.id):
			continue
		var pulso := 0.5 + 0.5 * sin(_tempo * 3.0)
		draw_circle(tanque.position, tanque.radius + 2.0, Color(0.3, 1.0, 0.65, 0.08 + pulso * 0.1))
		draw_texture_rect(Icones.obter("combustivel"), Rect2(tanque.position - Vector2(6, 6), Vector2(12, 12)), false, Color("6af0b4"))
