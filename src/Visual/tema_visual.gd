extends RefCounted

const FUNDO = Color("070e21")
const TEXTO = Color("f4f8ff")
const DESTAQUE = Color("42f5d1")
const PERIGO = Color("ff9c38")


static func criar() -> Theme:
	var tema := Theme.new()
	for estado in ["normal", "hover", "pressed", "disabled", "focus"]:
		var caixa := StyleBoxFlat.new()
		caixa.bg_color = Color("237c89") if estado == "pressed" else (Color("173954") if estado == "hover" else FUNDO)
		caixa.border_color = Color("63738a") if estado == "disabled" else (TEXTO if estado in ["hover", "focus"] else DESTAQUE)
		caixa.set_border_width_all(2 if estado == "focus" else 1)
		caixa.content_margin_left = 5
		caixa.content_margin_right = 5
		caixa.content_margin_top = 3
		caixa.content_margin_bottom = 3
		if estado == "focus":
			caixa.bg_color = Color.TRANSPARENT
		tema.set_stylebox(estado, "Button", caixa)
	tema.set_color("font_color", "Button", TEXTO)
	tema.set_color("font_hover_color", "Button", TEXTO)
	tema.set_color("font_pressed_color", "Button", DESTAQUE)
	tema.set_color("font_disabled_color", "Button", Color("9baabd"))
	tema.set_color("font_color", "Label", TEXTO)
	tema.set_color("font_shadow_color", "Label", FUNDO)
	tema.set_constant("shadow_offset_x", "Label", 1)
	tema.set_constant("shadow_offset_y", "Label", 1)
	return tema

static func destacar(botao: Button, cor := DESTAQUE) -> void:
	for estado in ["normal", "hover", "pressed"]:
		var caixa := StyleBoxFlat.new()
		caixa.bg_color = cor.darkened(0.3) if estado == "pressed" else (cor.lightened(0.2) if estado == "hover" else cor)
		caixa.border_color = TEXTO if estado == "hover" else cor.lightened(0.3)
		caixa.set_border_width_all(1)
		caixa.set_content_margin_all(4)
		caixa.shadow_color = Color("17435a")
		caixa.shadow_size = 2
		caixa.shadow_offset = Vector2(1, 2)
		botao.add_theme_stylebox_override(estado, caixa)
	for propriedade in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "icon_normal_color", "icon_hover_color", "icon_pressed_color", "icon_focus_color"]:
		botao.add_theme_color_override(propriedade, FUNDO)
