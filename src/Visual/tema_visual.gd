extends RefCounted

const FUNDO = Color("0b1423")
const TEXTO = Color("f4f8ff")
const DESTAQUE = Color("82f0d1")
const PERIGO = Color("ffac78")


static func criar() -> Theme:
	var tema := Theme.new()
	for estado in ["normal", "hover", "pressed", "disabled", "focus"]:
		var caixa := StyleBoxFlat.new()
		caixa.bg_color = Color("182a3b") if estado == "pressed" else FUNDO
		caixa.border_color = Color("63738a") if estado == "disabled" else (TEXTO if estado in ["hover", "focus"] else DESTAQUE)
		caixa.set_border_width_all(1)
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
