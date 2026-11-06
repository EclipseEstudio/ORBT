extends PanelContainer
## Cadeado compacto em torno da meta de estrelas.

func _ready() -> void:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("181b20")
	estilo.border_color = Color("777a80")
	estilo.set_border_width_all(2)
	estilo.corner_radius_top_left = 4
	estilo.corner_radius_top_right = 4
	estilo.corner_radius_bottom_left = 4
	estilo.corner_radius_bottom_right = 4
	estilo.content_margin_left = 5
	estilo.content_margin_right = 5
	estilo.content_margin_top = 6
	estilo.content_margin_bottom = 5
	add_theme_stylebox_override("panel", estilo)


func _draw() -> void:
	var centro := size.x / 2.0
	var cor := Color("777a80")
	draw_arc(Vector2(centro, 0), 12, PI, TAU, 24, cor, 2.0, true)
	draw_line(Vector2(centro - 12, 0), Vector2(centro - 12, 3), cor, 2.0)
	draw_line(Vector2(centro + 12, 0), Vector2(centro + 12, 3), cor, 2.0)
