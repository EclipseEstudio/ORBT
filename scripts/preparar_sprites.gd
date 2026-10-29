extends SceneTree
## Preparação reprodutível: recorte por alfa e redução nearest; fontes intactas.

func _initialize() -> void:
	for nome in ["nave", "planeta", "satelite", "terra", "sol", "asteroide"]:
		var fonte := Image.load_from_file("res://docs/auxiliar/arte/fontes/" + nome + ".png")
		if fonte == null or fonte.is_empty():
			quit(1)
			return
		var recorte := fonte.get_region(fonte.get_used_rect())
		var lado := maxi(recorte.get_width(), recorte.get_height())
		var quadrado := Image.create(lado, lado, false, Image.FORMAT_RGBA8)
		quadrado.fill(Color.TRANSPARENT)
		quadrado.blit_rect(recorte, Rect2i(Vector2i.ZERO, recorte.get_size()), (Vector2i(lado, lado) - recorte.get_size()) / 2)
		quadrado.resize(32, 32, Image.INTERPOLATE_NEAREST)
		if quadrado.save_png("res://Recursos/Sprites/Identidade/" + nome + ".png") != OK:
			quit(1)
			return
	print("Preparados 6 sprites RGBA 32x32 por nearest-neighbor.")
	quit()
