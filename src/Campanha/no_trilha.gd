extends Container
## Posiciona o planeta sobre a trilha e deixa o restante livre para arraste.

const Arte = preload("res://src/Visual/arte_pixel.gd")
const DIAMETRO_PLANETA := 40
const MARGEM_LATERAL := 2
const ALTURA_TRECHO := 66.0

var lado := -1.0
var _borda := Color("739ecd")


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func estilizar_planeta(botao: Button, concluida: bool, destino_final: bool) -> void:
	var textura := Arte.textura("earth" if destino_final else "planet")
	var tom := Color("65819b") if destino_final else Color("77aadd")
	_borda = Color("ffd181") if destino_final or concluida else Color("739ecd")
	if botao.disabled:
		tom = Color("516477") if destino_final else Color("5b6880")
		_borda = Color("ad8952") if destino_final else Color("596a82")
	elif concluida and not destino_final:
		tom = Color("d9ab71")

	for estado in ["normal", "hover", "pressed", "disabled"]:
		var estilo := StyleBoxTexture.new()
		estilo.texture = textura
		estilo.modulate_color = tom
		if estado == "hover":
			estilo.modulate_color = tom.lightened(0.18)
		elif estado == "pressed":
			estilo.modulate_color = tom.darkened(0.18)
		estilo.content_margin_left = MARGEM_LATERAL
		estilo.content_margin_right = MARGEM_LATERAL
		estilo.content_margin_top = 8
		estilo.content_margin_bottom = 6
		botao.add_theme_stylebox_override(estado, estilo)

	var foco := StyleBoxFlat.new()
	foco.draw_center = false
	foco.border_color = Color("e3f3ff")
	foco.set_border_width_all(1)
	foco.set_corner_radius_all(DIAMETRO_PLANETA / 2)
	botao.add_theme_stylebox_override("focus", foco)
	botao.add_theme_font_size_override("font_size", mini(8, (DIAMETRO_PLANETA - 2 * MARGEM_LATERAL) / botao.text.length()))
	botao.add_theme_color_override("font_disabled_color", Color("c1c9d7"))
	botao.add_theme_color_override("icon_disabled_color", Color("b3becf"))


func _get_minimum_size() -> Vector2:
	if get_child_count() == 0:
		return Vector2.ZERO
	var cartao := get_child(0) as Control
	var minimo := cartao.get_combined_minimum_size()
	return Vector2(maxf(112.0, minimo.x + 16.0), maxf(ALTURA_TRECHO, minimo.y + 20.0))


func _centro_planeta(largura: float) -> Vector2:
	var amplitude := minf(45.0, (size.x - largura) * 0.5 - 8.0)
	return Vector2(roundf(size.x * 0.5 + lado * amplitude), size.y * 0.5)


func _notification(what: int) -> void:
	if what != NOTIFICATION_SORT_CHILDREN or get_child_count() == 0:
		return
	var cartao := get_child(0) as Control
	var minimo := cartao.get_combined_minimum_size()
	var largura := maxf(DIAMETRO_PLANETA, minimo.x)
	var centro := _centro_planeta(largura)
	fit_child_in_rect(cartao, Rect2(centro - Vector2(largura, DIAMETRO_PLANETA) * 0.5, Vector2(largura, minimo.y)))
	queue_redraw()


func _draw() -> void:
	if get_child_count() == 0:
		return
	var cartao := get_child(0) as Control
	var centro := _centro_planeta(cartao.size.x)
	draw_circle(centro, DIAMETRO_PLANETA * 0.5, Color("0d182b"), true, -1.0, true)
	draw_arc(centro, DIAMETRO_PLANETA * 0.5, 0, TAU, 48, _borda, 1.0, true)
