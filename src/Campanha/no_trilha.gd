extends Container
## Cada trecho da trilha posiciona um cartão e deixa o restante livre para arraste.

const Icones = preload("res://src/Visual/icones_ui.gd")
const LARGURA_CARTAO := 40.0
const MARGEM_VERTICAL := 7.0
const RAIO_MARCADOR := 9.0

var lado := -1
var inicio := false
var fim := false
var destino_final := false
var bloqueado := false
var concluido := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _get_minimum_size() -> Vector2:
	if get_child_count() == 0:
		return Vector2.ZERO
	var cartao := get_child(0) as Control
	var minimo := cartao.get_combined_minimum_size()
	return Vector2(2.0 * (maxf(LARGURA_CARTAO, minimo.x) + 25.0), minimo.y + 2.0 * MARGEM_VERTICAL)


func _notification(what: int) -> void:
	if what != NOTIFICATION_SORT_CHILDREN or get_child_count() == 0:
		return
	var cartao := get_child(0) as Control
	var minimo := cartao.get_combined_minimum_size()
	var largura := maxf(LARGURA_CARTAO, minimo.x)
	var alcance := minf(58.0, (size.x - largura) * 0.5 - 3.0)
	var x := roundf(size.x * 0.5 + lado * alcance - largura * 0.5)
	fit_child_in_rect(cartao, Rect2(x, MARGEM_VERTICAL, largura, minimo.y))
	queue_redraw()


func _draw() -> void:
	if get_child_count() == 0:
		return
	var cartao := get_child(0) as Control
	var botao := cartao.get_child(2) as Button
	var eixo := roundf(size.x * 0.5)
	var altura := roundf(cartao.position.y + botao.position.y + botao.size.y * 0.5)
	var ponto := Vector2(eixo + lado * 21.0, altura)
	var ponta := cartao.position.x if lado > 0 else cartao.get_rect().end.x
	var cor := Color("ffc845") if destino_final else Color("87b6d9")
	if bloqueado:
		cor = cor.darkened(0.35) if destino_final else Color("606c80")
	elif concluido:
		cor = Color("ffc845")
	var topo := altura if inicio else 0.0
	var base := altura if fim else size.y
	if base > topo:
		draw_dashed_line(Vector2(eixo, topo), Vector2(eixo, base), Color("526e8b"), 1.0, 3.0)
	draw_line(Vector2(eixo, altura), Vector2(ponta, altura), cor.darkened(0.35), 1.0)
	draw_circle(ponto, RAIO_MARCADOR, cor)
	draw_circle(ponto, RAIO_MARCADOR - 1.0, Color("142239"))
	draw_texture(Icones.obter("casa" if destino_final else "posto"), ponto - Vector2(6, 6), cor)
