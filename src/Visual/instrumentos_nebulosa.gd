extends Control
## Rumos de rádio: revelam direção/distância, nunca a imagem dos obstáculos.
var partida: Node
const FONTE = preload("res://Recursos/Fontes/PressStart2P-Regular.ttf")
var leituras: Array[Dictionary] = []

func _ready() -> void:
	name = "InstrumentosNebulosa"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	offset_top = 52
	offset_left = 8

func _process(_delta: float) -> void:
	visible = partida.estado == partida.Estado.JOGANDO
	leituras.clear()
	var origem: Vector2 = partida.nave.global_position
	for tanque in partida.nivel.combustiveis:
		if not partida.combustiveis_coletados.has(tanque.id):
			leituras.append({"nome":"TANQUE +1","vetor":tanque.position - origem})
	var portais: Array[Dictionary] = []
	for corpo in partida.nave.corpos:
		if corpo.type == "portal" and corpo.position.distance_to(origem) > 40:
			portais.append({"nome":"PORTAL " + corpo.id,"vetor":corpo.position-origem})
	portais.sort_custom(func(a: Dictionary,b: Dictionary): return a.vetor.length_squared() < b.vetor.length_squared())
	leituras.append_array(portais.slice(0,2))
	queue_redraw()

func _draw() -> void:
	for i in leituras.size():
		var leitura: Dictionary = leituras[i]
		var direcao: Vector2 = leitura.vetor.normalized()
		var centro := Vector2(5, i * 15 + 5)
		var lateral := direcao.orthogonal()
		draw_rect(Rect2(Vector2(-2,i*15-2),Vector2(140,14)),Color("070e21e8"))
		draw_colored_polygon(PackedVector2Array([centro+direcao*4,centro-direcao*3+lateral*2,centro-direcao*3-lateral*2]),Color("87b6d9"))
		draw_string(FONTE,Vector2(14,i*15+7),"%s: %d" % [leitura.nome,roundi(leitura.vetor.length())],HORIZONTAL_ALIGNMENT_LEFT,-1,6,Color("d5edff"))
