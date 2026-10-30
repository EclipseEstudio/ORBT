extends RefCounted
## Ajusta o conteúdo, mantendo o fundo livre para preencher a tela.

static func logica(area_fisica: Rect2, transformacao: Transform2D, viewport: Rect2) -> Rect2:
	if not area_fisica.has_area() or is_zero_approx(transformacao.determinant()):
		return viewport
	var area := (transformacao.affine_inverse() * area_fisica).intersection(viewport)
	return area if area.has_area() else viewport

static func aplicar(controle: Control, margem := 0.0, area_fisica := Rect2()) -> void:
	var viewport := controle.get_viewport()
	var tela := viewport.get_visible_rect()
	var area := logica(area_fisica, viewport.get_screen_transform(), tela)
	controle.offset_left = area.position.x + margem
	controle.offset_top = area.position.y + margem
	controle.offset_right = area.end.x - tela.end.x - margem
	controle.offset_bottom = area.end.y - tela.end.y - margem

static func fisica() -> Rect2:
	return Rect2(DisplayServer.get_display_safe_area()) if OS.has_feature("android") else Rect2()
