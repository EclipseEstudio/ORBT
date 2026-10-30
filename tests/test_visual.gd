extends SceneTree

const Arte = preload("res://src/Visual/arte_pixel.gd")
const Carregador = preload("res://src/Nivel/carregador_fase.gd")
const Fabrica = preload("res://src/CorpoEstelar/gerenciador_corpos_estelares.gd")
const HUD = preload("res://src/Nivel/interface_partida.gd")
var verificacoes := 0
var falhas := 0


func _initialize() -> void:
	_executar.call_deferred()


func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)


func _executar() -> void:
	for tipo in Arte.TEXTURAS:
		var textura: Texture2D = Arte.textura(tipo)
		var imagem := textura.get_image()
		conferir(imagem.get_size() == Vector2i(32, 32) and imagem.detect_alpha() != Image.ALPHA_NONE, "%s: sprite 32x32 com transparência" % tipo)
	var resultado := Carregador.carregar("res://Recursos/Fases/teste_001.json")
	var nivel = resultado.nivel
	var autorais: Dictionary = nivel.dados_autorais.duplicate(true)
	for tipo in ["planet", "satellite", "sun", "asteroid", "earth"]:
		var dados: Dictionary = nivel.corpos[0].duplicate(true)
		dados.type = tipo
		dados.position = Vector2.ZERO
		var antes := dados.duplicate(true)
		var corpo := Fabrica.criar(dados)
		root.add_child(corpo)
		conferir(dados == antes and corpo.dados == antes, "%s: integração não altera dados físicos" % tipo)
		conferir(corpo.sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST and corpo.sprite.centered, "%s: pivô central e filtro nearest" % tipo)
		var imagem: Image = corpo.sprite.texture.get_image()
		var maximo := 0.0
		for y in range(32):
			for x in range(32):
				if imagem.get_pixel(x, y).a > 0:
					maximo = maxf(maximo, (Vector2(x, y) + Vector2.ONE * 0.5 - Vector2(16, 16)).length() * corpo.sprite.scale.x)
		conferir(maximo <= dados.visual_radius, "%s: pixels cabem no raio visual" % tipo)
		corpo.proximo = true
		corpo.marcas.depuracao = true
		corpo.marcas.queue_redraw()
		conferir(corpo.marcas.proximo and corpo.get_child_count() == 2, "%s: alerta reutiliza marca sem instâncias extras" % tipo)
		corpo.queue_free()
	conferir(Arte.APOIOS[0] != Arte.APOIOS[1], "Duas variações visuais de apoio disponíveis")
	var mundo = load("res://src/Nivel/Nivel.tscn").instantiate()
	mundo.nivel_res = nivel
	mundo.campanha_permitida = true
	root.add_child(mundo)
	await process_frame
	var nave = mundo.get_node("Nave")
	var partida = mundo.partida
	partida.set_physics_process(false)
	conferir(nave.raio == nivel.parametros_nave.radius and nave.massa == nivel.parametros_nave.mass and nave.get_node("Nave").texture == Arte.textura("ship"), "Nova nave usa os mesmos parâmetros físicos")
	var filhos: int = mundo.get_node("Estaticos").get_child_count()
	for indice in range(5):
		partida.reiniciar()
		conferir(mundo.get_node("Estaticos").get_child_count() == filhos and mundo.corpos_visuais.values().all(func(corpo: Node): return corpo.get_child_count() == 2), "Reinício não acumula sprites ou marcas")
	var hud: Node
	for filho in mundo.get_children():
		if filho is CanvasLayer:
			if filho.get("partida") != null:
				hud = filho
	var tela := Rect2(0, 0, 180, 390)
	var topo := Rect2(4, 3, 172, 75)
	conferir(HUD.direcao_alvo(Vector2(90, 35), tela, topo) == "↑", "Alvo encoberto pelo HUD tem indicação para cima")
	conferir(HUD.direcao_alvo(Vector2(90, 100), tela, topo) == "", "Alvo visível fora do HUD não recebe seta")
	conferir(HUD.direcao_alvo(Vector2(-10, -5), tela, topo) == "↑←", "Alvo fora da tela mantém indicação diagonal")
	conferir(HUD.direcao_alvo(Vector2(90, 400), tela, topo) == "↓", "Alvo abaixo da tela mantém indicação")
	conferir(hud._status.mouse_filter == Control.MOUSE_FILTER_IGNORE and hud._status.get_theme_stylebox("normal").bg_color.a == 1.0, "Fundo do status preserva contraste sem capturar gestos")
	for estado in ["jogando", "pausado", "concluida"]:
		partida.reiniciar()
		if estado == "pausado":
			partida.pausar()
		elif estado == "concluida":
			partida.finalizar(true, "Você chegou à Terra!")
		await process_frame
		await process_frame
		var botoes: Array = hud._raiz.find_children("*", "Button", true, false)
		conferir(botoes.all(func(botao: Button): return root.get_visible_rect().encloses(botao.get_global_rect())), "HUD mantém botões dentro da tela: " + estado)
	partida.reiniciar()
	mundo.camera._process(2)
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2(0, -80))
	for passo in range(180):
		partida.avancar(1.0 / 60)
	conferir(partida.estado == partida.Estado.CONCLUIDA and nave.combustivel == 4, "Rota de referência conserva vitória e consumo com nova arte")
	conferir(nivel.dados_autorais == autorais, "Cores e visuais não sobrescrevem dados autorais")
	mundo.queue_free()
	await process_frame
	print("Visual: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
