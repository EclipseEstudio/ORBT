extends SceneTree
## Captura reprodutível com renderizador real; saídas em .godot/propulsao-*.png.

func _initialize() -> void:
	_capturar.call_deferred()

func _capturar() -> void:
	var nivel = load("res://src/Nivel/Nivel.tscn").instantiate()
	nivel.nivel_res = load("res://src/Nivel/carregador_fase.gd").carregar("res://Recursos/Fases/teste_001.json").nivel
	root.add_child(nivel)
	await process_frame
	nivel.partida.set_physics_process(false)
	nivel.camera._process(2)
	var nave = nivel.get_node("Nave")
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	nave.solicitar_impulso(1, Vector2(0, -80))
	nivel.partida.avancar(1.0 / 60.0)
	nave.animation_player.pause()
	nave.animation_player.seek(0.17, true)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/propulsao-lancamento.png")
	nivel.free()
	var fundo := ColorRect.new()
	fundo.color = Color("0b1423")
	fundo.size = Vector2(180, 320)
	root.add_child(fundo)
	var titulo := Label.new()
	titulo.text = "Propulsão — seis quadros"
	titulo.position = Vector2(8, 10)
	titulo.add_theme_font_size_override("font_size", 11)
	root.add_child(titulo)
	for indice in range(6):
		var conjunto := Node2D.new()
		conjunto.position = Vector2(45 + (indice % 2) * 90, 65 + (indice / 2) * 80)
		conjunto.scale = Vector2(3, 3)
		root.add_child(conjunto)
		var casco := Sprite2D.new()
		casco.texture = load("res://src/Visual/arte_pixel.gd").textura("ship")
		load("res://src/Visual/arte_pixel.gd").ajustar(casco, 6)
		conjunto.add_child(casco)
		var fogo = load("res://src/Visual/propulsao_pixel.gd").new()
		fogo.position = Vector2(-2, 5)
		fogo.quadro = indice
		conjunto.add_child(fogo)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/propulsao-quadros.png")
	quit()
