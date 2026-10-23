extends SceneTree

const Arte = preload("res://src/Visual/arte_pixel.gd")
const Fabrica = preload("res://src/CorpoEstelar/gerenciador_corpos_estelares.gd")
const Carregador = preload("res://src/Nivel/carregador_fase.gd")


func _initialize() -> void:
	_capturar.call_deferred()


func rotulo(pai: Node, posicao: Vector2, texto: String, fonte := 10) -> void:
	var label := Label.new()
	label.position = posicao
	label.text = texto
	label.add_theme_font_size_override("font_size", fonte)
	pai.add_child(label)


func _capturar() -> void:
	root.size = Vector2i(960, 640)
	root.content_scale_size = Vector2i(480, 320)
	var painel := Control.new()
	root.add_child(painel)
	var fundo := ColorRect.new()
	fundo.color = Color("0b1423")
	fundo.size = Vector2(480, 320)
	painel.add_child(fundo)
	rotulo(painel, Vector2(16, 10), "ORBT / IDENTIDADE VISUAL", 16)
	rotulo(painel, Vector2(16, 34), "Pixel art 32 × 32 · contorno central · física independente")
	var cinza := Shader.new()
	cinza.code = "shader_type canvas_item; varying vec4 tinta; void vertex(){ tinta = COLOR; } void fragment(){ vec4 c = texture(TEXTURE, UV) * tinta; float l = dot(c.rgb, vec3(0.299, 0.587, 0.114)); COLOR = vec4(vec3(l), c.a); }"
	var material := ShaderMaterial.new()
	material.shader = cinza
	var base: Dictionary = Carregador.carregar("res://Recursos/Fases/teste_001.json").nivel.corpos[0]
	var tipos := ["planet", "satellite", "sun", "asteroid", "earth", "ship"]
	var nomes := ["Planeta +", "Satélite +", "Sol ×", "Asteroide ×", "Terra / lar", "Nave ↑"]
	for linha in range(2):
		for indice in range(tipos.size()):
			var posicao := Vector2(48 + indice * 76, 90 + linha * 95)
			if tipos[indice] == "ship":
				var sprite := Sprite2D.new()
				sprite.texture = Arte.textura("ship")
				Arte.ajustar(sprite, 20)
				sprite.position = posicao
				painel.add_child(sprite)
				if linha == 1:
					sprite.material = material
			else:
				var dados := base.duplicate(true)
				dados.type = tipos[indice]
				dados.position = posicao
				dados.visual_radius = 20
				dados.collision_radius = 20
				dados.danger_radius = 21 if tipos[indice] in ["sun", "asteroid"] else 0
				var corpo := Fabrica.criar(dados)
				painel.add_child(corpo)
				if linha == 1:
					corpo.sprite.material = material
					corpo.marcas.material = material
			rotulo(painel, posicao + Vector2(-29, 29), nomes[indice], 9)
	rotulo(painel, Vector2(16, 229), "Variações de apoio: mesma textura, cores independentes da física")
	for indice in range(2):
		var dados := base.duplicate(true)
		dados.position = Vector2(60 + 80 * indice, 275)
		var corpo := Fabrica.criar(dados)
		painel.add_child(corpo)
		corpo.sprite.modulate = Arte.APOIOS[indice]
	rotulo(painel, Vector2(195, 261), "+ Apoio seguro    × Contato fatal\nCasa + TERRA: destino\nTracejado: proximidade, sem limite de gravidade", 10)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/identidade-visual.png")
	painel.queue_free()
	await process_frame
	root.size = Vector2i(360, 640)
	root.content_scale_size = Vector2i(180, 320)
	var nivel = load("res://src/Nivel/Nivel.tscn").instantiate()
	var autorais: Dictionary = Carregador.carregar("res://Recursos/Fases/teste_001.json").nivel.dados_autorais.duplicate(true)
	var sol: Dictionary = autorais.bodies[2]
	sol.id = "sol_teste"
	sol.type = "sun"
	sol.mass = 1000
	sol.position = [90, 150]
	sol.visual_radius = 18
	sol.collision_radius = 18
	sol.danger_radius = 22
	sol.proximity_radius = 50
	nivel.nivel_res = Carregador.validar(autorais).nivel
	root.add_child(nivel)
	var partida = nivel.partida
	partida.set_physics_process(false)
	var nave = nivel.get_node("Nave")
	nave.condicao = nave.Condicao.EM_VOO
	nave.global_position = Vector2(90, 200)
	partida.avancar(0)
	nivel.camera._process(2)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/identidade-alerta.png")
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2(0, -80))
	for passo in range(120):
		partida.avancar(1.0 / 60)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/identidade-derrota.png")
	nivel.queue_free()
	await process_frame
	quit()
