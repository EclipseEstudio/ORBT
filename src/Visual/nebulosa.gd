extends CanvasLayer
## Máscara opaca em tela. Explorar o mapa não muda a origem da visibilidade.

var partida: Node
var camera: Camera2D
var _material: ShaderMaterial

func _ready() -> void:
	name = "Nebulosa"
	layer = 7
	var mascara := ColorRect.new()
	mascara.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(mascara)
	mascara.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_material = ShaderMaterial.new()
	_material.shader = preload("res://src/Visual/nebulosa.gdshader")
	mascara.material = _material

func _process(_delta: float) -> void:
	var centro: Vector2 = partida.nave.get_global_transform_with_canvas().origin
	var raio: float = partida.nivel.dados_autorais.nebula.visibility_radius * camera.zoom.x
	_material.set_shader_parameter("centro", centro)
	_material.set_shader_parameter("raio", raio)
	_material.set_shader_parameter("tamanho", get_viewport().get_visible_rect().size)

static func pode_ver(posicao: Vector2, nave: Vector2, raio: float) -> bool:
	return posicao.distance_to(nave) < raio
