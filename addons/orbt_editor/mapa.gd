@tool
extends Control
## Desenho autoral; não instancia corpos, nave nem controladores de partida.

var documento: RefCounted
var centro := Vector2.ZERO
var escala := 1.0
var arrastando := false
var navegando := false
var _deslocamento := Vector2.ZERO
var regioes := {"visual_radius": true, "collision_radius": true, "capture_radius": true, "proximity_radius": true, "danger_radius": true}
const CORES = {"visual_radius": Color.SKY_BLUE, "collision_radius": Color.WHITE, "capture_radius": Color.LIME_GREEN, "proximity_radius": Color.SLATE_BLUE, "danger_radius": Color.ORANGE_RED}
const Carregador = preload("res://src/Nivel/carregador_fase.gd")


func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(queue_redraw)


func enquadrar() -> void:
	var limites: Dictionary = documento.dados.bounds
	centro = Vector2(limites.position[0], limites.position[1]) + Vector2(limites["size"][0], limites["size"][1]) / 2
	escala = clampf(minf(size.x / maxf(1, absf(limites["size"][0])), size.y / maxf(1, absf(limites["size"][1]))) * 0.85, 0.05, 8)
	queue_redraw()


func tela(mundo: Vector2) -> Vector2:
	return (mundo - centro) * escala + size / 2


func mundo(ponto: Vector2) -> Vector2:
	return (ponto - size / 2) / escala + centro


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("111824"))
	if documento == null or documento.dados.is_empty():
		return
	var dados: Dictionary = documento.dados
	var limites: Dictionary = dados.bounds
	draw_rect(Rect2(tela(Vector2(limites.position[0], limites.position[1])), Vector2(limites["size"][0], limites["size"][1]) * escala), Color.GRAY, false, 2)
	var corpos: Array = dados.bodies.duplicate()
	corpos.append(dados.goal)
	for i in range(corpos.size()):
		var corpo: Dictionary = corpos[i]
		var indice := i if i < dados.bodies.size() else -1
		var posicao := tela(Vector2(corpo.position[0], corpo.position[1]))
		if corpo.get("orbit") is Dictionary and Carregador.vetor(corpo.orbit.get("center")):
			var centro_orbita := tela(Vector2(corpo.orbit.center[0], corpo.orbit.center[1]))
			draw_arc(centro_orbita, centro_orbita.distance_to(posicao), 0, TAU, 96, Color(0.4, 0.8, 1.0, 0.5), 1.0, true)
		if corpo.get("landing_zone") is Dictionary and Carregador.numero(corpo.landing_zone.get("center_degrees"), -360, 360) and Carregador.numero(corpo.landing_zone.get("half_width_degrees"), 0.01, 180):
			var giro := 0.0
			if corpo.get("rotation") is Dictionary and Carregador.numero(corpo.rotation.get("initial_degrees", 0), -360, 360):
				giro = float(corpo.rotation.get("initial_degrees", 0))
			var setor: Dictionary = corpo.landing_zone
			draw_arc(posicao, (corpo.collision_radius + 3) * escala, deg_to_rad(setor.center_degrees + giro - setor.half_width_degrees), deg_to_rad(setor.center_degrees + giro + setor.half_width_degrees), 48, Color.LIME_GREEN, 3, true)
		for campo in regioes:
			if regioes[campo] and corpo[campo] > 0:
				draw_arc(posicao, maxf(1, corpo[campo] * escala), 0, TAU, 64, CORES[campo], 1.5, true)
		if corpo.get("type") == "portal" and Carregador.numero(corpo.get("exit_degrees"), -360, 360):
			draw_line(posicao, posicao + Vector2.RIGHT.rotated(deg_to_rad(corpo.exit_degrees)) * maxf(12, corpo.collision_radius * escala), Color.CYAN, 2, true)
		var nome: String = ("Terra · " if indice == -1 else "") + corpo.id
		draw_string(ThemeDB.fallback_font, posicao + Vector2(12, -12), nome, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
		if documento.selecao == indice:
			draw_rect(Rect2(posicao - Vector2.ONE * 7, Vector2.ONE * 14), Color.YELLOW, false, 2)
	var validacao := Carregador.validar(dados)
	if validacao.nivel != null:
		var inicio := tela(validacao.nivel.obter_posicao_inicial())
		var normal := Vector2.RIGHT if dados.start.has("position") else Vector2.RIGHT.rotated(deg_to_rad(dados.start.angle_degrees))
		draw_colored_polygon(PackedVector2Array([inicio + normal * 8, inicio + normal.rotated(2.4) * 7, inicio + normal.rotated(-2.4) * 7]), Color.YELLOW)
		draw_string(ThemeDB.fallback_font, inicio + Vector2(10, 16), "Nave inicial", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.YELLOW)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN] and event.pressed:
			var antes := mundo(event.position)
			escala = clampf(escala * (1.15 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 1.15), 0.05, 8)
			centro += antes - mundo(event.position)
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			navegando = event.pressed
		elif event.button_index == MOUSE_BUTTON_LEFT:
			arrastando = false
			if event.pressed:
				var escolhido := -2
				var distancia := INF
				for indice in range(-1, documento.dados.bodies.size()):
					var corpo: Dictionary = documento.objeto(indice)
					var posicao := Vector2(corpo.position[0], corpo.position[1])
					var d := tela(posicao).distance_to(event.position)
					if d <= maxf(12, corpo.visual_radius * escala) and d < distancia:
						escolhido = indice
						distancia = d
						_deslocamento = posicao - mundo(event.position)
				documento.selecionar(escolhido)
				arrastando = escolhido != -2
		accept_event()
	elif event is InputEventMouseMotion:
		if navegando:
			centro -= event.relative / escala
		elif arrastando:
			documento.mover(documento.selecao, mundo(event.position) + _deslocamento)
	queue_redraw()


func _notification(what: int) -> void:
	if what in [NOTIFICATION_VISIBILITY_CHANGED, NOTIFICATION_WM_WINDOW_FOCUS_OUT]:
		arrastando = false
		navegando = false
