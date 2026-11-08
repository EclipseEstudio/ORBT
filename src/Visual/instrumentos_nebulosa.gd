extends Control
## Rumos ao redor da nave, em pixels lógicos independentes do zoom.
var partida: Node
const COR_TANQUE = Color("ffc845")
const COR_ENTRADA = Color("c28aff")
const COR_SAIDA = Color("f4f8ff")
var leituras: Array[Dictionary] = []

func _ready() -> void:
	name = "InstrumentosNebulosa"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _process(_delta: float) -> void:
	visible = partida.estado == partida.Estado.JOGANDO
	leituras.clear()
	var origem: Vector2 = partida.nave.global_position
	for tanque in partida.nivel.combustiveis:
		if not partida.combustiveis_coletados.has(tanque.id):
			leituras.append({"alvo": tanque.position, "cor": COR_TANQUE, "raio": 28.0})
	var portais: Array[Dictionary] = []
	for corpo in partida.nave.corpos:
		if corpo.type == "portal" and corpo.position.distance_to(origem) > 40:
			portais.append({"alvo": corpo.position, "cor": COR_SAIDA if corpo.get("_portal_saida", false) else COR_ENTRADA, "raio": 35.0})
	portais.sort_custom(func(a: Dictionary, b: Dictionary): return a.alvo.distance_squared_to(origem) < b.alvo.distance_squared_to(origem))
	leituras.append_array(portais.slice(0, 2))
	queue_redraw()

func _draw() -> void:
	var inversa := get_global_transform_with_canvas().affine_inverse()
	var tela_nave: Vector2 = partida.nave.get_global_transform_with_canvas().origin
	for leitura in leituras:
		var tela_alvo: Vector2 = partida.nave.get_canvas_transform() * Vector2(leitura.alvo)
		var direcao := (tela_alvo - tela_nave).normalized()
		var centro := inversa * (tela_nave + direcao * float(leitura.raio))
		var lateral := direcao.orthogonal()
		var triangulo := PackedVector2Array([centro + direcao * 5, centro - direcao * 3 + lateral * 2, centro - direcao * 3 - lateral * 2])
		draw_colored_polygon(triangulo, leitura.cor)
		triangulo.append(triangulo[0])
		draw_polyline(triangulo, Color("070e21"), 1)
