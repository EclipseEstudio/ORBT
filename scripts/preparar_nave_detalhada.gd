extends SceneTree
## Redução do asset de arte para a resolução usada pelo jogo.

func _initialize() -> void:
	var fonte := Image.load_from_file("res://docs/arte/fontes/nave_detalhada.png")
	if fonte == null or fonte.is_empty():
		quit(1)
		return
	var recorte := fonte.get_region(fonte.get_used_rect())
	var lado := maxi(recorte.get_width(), recorte.get_height())
	var quadrado := Image.create(lado, lado, false, Image.FORMAT_RGBA8)
	quadrado.fill(Color.TRANSPARENT)
	quadrado.blit_rect(recorte, Rect2i(Vector2i.ZERO, recorte.get_size()), (Vector2i(lado, lado) - recorte.get_size()) / 2)
	quadrado.resize(64, 64, Image.INTERPOLATE_NEAREST)
	quit(0 if quadrado.save_png("res://Recursos/Sprites/Identidade/nave_detalhada.png") == OK else 1)
