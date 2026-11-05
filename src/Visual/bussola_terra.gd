extends Control
## Overlay em pixels lógicos: a câmera transforma a direção, nunca o tamanho.

const DISTANCIA := 20.0
var partida: Node
var direcao := Vector2.ZERO
var centro := Vector2.ZERO

static func calcular_direcao(nave_tela: Vector2, terra_tela: Vector2) -> Vector2:
	return (terra_tela - nave_tela).normalized()

func _ready() -> void:
	name = "BussolaTerra"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func atualizar() -> void:
	visible = is_instance_valid(partida) and partida.estado == partida.Estado.JOGANDO
	if not visible:
		return
	var nave: Node2D = partida.nave
	var tela := nave.get_global_transform_with_canvas().origin
	var terra := Vector2.ZERO
	var encontrou := false
	for corpo in nave.corpos:
		if corpo.type == "earth":
			terra = nave.get_canvas_transform() * Vector2(corpo.position)
			encontrou = true
			break
	direcao = calcular_direcao(tela, terra) if encontrou else Vector2.ZERO
	centro = get_global_transform_with_canvas().affine_inverse() * (tela + direcao * DISTANCIA)
	queue_redraw()

func _draw() -> void:
	if direcao.is_zero_approx():
		return
	var lateral := direcao.orthogonal()
	var triangulo := PackedVector2Array([centro + direcao * 7, centro - direcao * 4 + lateral * 3, centro - direcao * 4 - lateral * 3])
	draw_colored_polygon(triangulo, Color("42f5d1"))
	triangulo.append(triangulo[0])
	draw_polyline(triangulo, Color("070e21"), 1)
