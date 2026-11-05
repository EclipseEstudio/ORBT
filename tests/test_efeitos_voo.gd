extends SceneTree

const C = preload("res://src/Nivel/carregador_fase.gd")
const Camera = preload("res://src/Nivel/camera_nivel.gd")
const Mira = preload("res://src/Nave/mira_nave.gd")
var verificacoes := 0
var falhas := 0


func conferir(ok: bool, mensagem: String) -> void:
	verificacoes += 1
	if not ok:
		falhas += 1
		push_error(mensagem)


func _initialize() -> void:
	_executar.call_deferred()


func _executar() -> void:
	var mundo = load("res://src/Nivel/Nivel.tscn").instantiate()
	mundo.nivel_res = C.carregar("res://Recursos/Fases/teste_001.json").nivel
	mundo.nivel_res.dados_autorais["camera"] = {"zoom": 0.5, "overview": {"position": [-180, -200], "size": [540, 800]}}
	root.add_child(mundo)
	await process_frame
	var partida = mundo.partida
	var nave = partida.nave
	var camera = mundo.camera
	var rastro = mundo.get_node("RastroNave")
	var mira = nave.get_node("Indicadores/Mira")
	partida.set_physics_process(false)
	camera.set_process(false)
	rastro.set_process(false)
	rastro.set_physics_process(false)
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	var gesto = nave.entrada.gesto
	# A mesma intensidade determina o impulso e a aparência, sem alterar a guia.
	conferir(is_zero_approx(gesto.obter_intensidade()), "Sem contato a intensidade é zero")
	gesto.iniciar(0, Vector2(90, 140))
	gesto.mover(0, Vector2(90, 140 + gesto.zona_morta * 0.5))
	conferir(is_zero_approx(gesto.obter_intensidade()) and mira.largura_forca() == 1, "Zona morta mantém linha fina e força zero")
	for intensidade in [0.1, 0.5, 1.0, 1.5]:
		var distancia: float = gesto.zona_morta + (gesto.arraste_maximo - gesto.zona_morta) * intensidade
		gesto.mover(0, Vector2(90, 140 + distancia))
		conferir(is_equal_approx(gesto.obter_intensidade(), minf(intensidade, 1.0)), "Intensidade acompanha arraste e satura no máximo")
		conferir(is_equal_approx(gesto.obter_impulso().length(), gesto.obter_intensidade() * gesto.impulso_maximo), "Visual representa a força realmente aplicada")
		conferir(mira.largura_forca() in [1.0, 2.0, 3.0], "Espessura usa apenas pixels inteiros entre 1 e 3")
	conferir(mira.largura_forca() == 3 and mira.forca_saturada(), "Força máxima usa 3 px e indica saturação")
	for par in [[0.0, Color("82f0d1")], [1.0 / 3, Color("f5cc77")], [2.0 / 3, Color("ff9c38")], [1.0, Color("ff595e")]]:
		conferir(Mira.cor_intensidade(par[0]).is_equal_approx(par[1]), "Gradiente passa por ciano, amarelo, laranja e vermelho")
	gesto.cancelar()
	conferir(is_zero_approx(gesto.obter_intensidade()) and mira.pontos_forca().is_empty(), "Cancelar remove força e linha")
	# Sem gesto, a câmera nasce próxima da nave e independe dos corpos.
	var base: Vector2 = camera.zoom
	conferir(is_equal_approx(base.x, 0.7) and camera.global_position == nave.global_position, "Fase começa perto da nave, sem passeio inicial pela Terra")
	conferir(nave.controle_permitido, "Entrada está disponível desde o início")
	var anterior := INF
	for intensidade in [0.0, 0.25, 0.5, 0.75, 1.0, 2.0]:
		var valor := Camera.calcular_zoom_arraste(intensidade, 0.5)
		conferir(valor >= 0.375 and valor <= 0.7 and valor <= anterior, "Afastamento proporcional ao arraste respeita limites")
		anterior = valor
	conferir(is_equal_approx(Camera.calcular_zoom_arraste(0.5, 0.5), 0.5375), "Metade da força usa metade da variação de zoom")
	conferir(is_equal_approx(Camera.calcular_zoom_arraste(0, 1.0), 1.4), "Enquadramento próximo acompanha a base autoral")
	nave.corpos = []
	nave.global_position = Vector2(1000, 0)
	camera._process(1)
	conferir(camera.zoom == base and camera.global_position == nave.global_position, "Espaço aberto mantém a câmera próxima e centrada na nave")
	gesto.iniciar(2, Vector2(90, 140))
	gesto.mover(2, Vector2(90, 145))
	camera._process(1)
	conferir(camera.zoom == base, "Toque dentro da zona morta não afasta a câmera")
	gesto.mover(2, Vector2(90, 220))
	camera._process(0.1)
	conferir(camera.zoom.x < base.x and camera.zoom.x > 0.375, "Arraste forte começa a afastar suavemente")
	camera._process(2)
	conferir(is_equal_approx(camera.zoom.x, 0.375), "Arraste máximo alcança o limite distante")
	gesto.mover(2, Vector2(90, 185))
	camera._process(2)
	conferir(is_equal_approx(camera.zoom.x, 0.5375), "Reduzir o arraste aproxima proporcionalmente")
	gesto.cancelar()
	var ao_soltar: float = camera.zoom.x
	camera._process(0.1)
	conferir(camera.zoom.x > ao_soltar and camera.zoom.x < base.x, "Soltar ou cancelar recupera suavemente a visão próxima")
	var voo: Vector2 = camera.zoom
	partida.alternar_exploracao()
	camera.aplicar_zoom(1.2)
	var manual: Vector2 = camera.zoom
	camera._process(1)
	conferir(camera.zoom == manual, "Exploração mantém o zoom manual")
	partida.alternar_exploracao()
	conferir(camera.zoom == voo, "Sair da exploração restaura o zoom de voo anterior")
	partida.pausar()
	camera._process(1)
	conferir(camera.zoom == voo, "Pausa preserva o enquadramento")
	partida.retomar()
	# Equivalência temporal da suavização em diferentes taxas de quadros.
	camera.zoom = Vector2.ONE * 0.5
	camera._process(0.2)
	var unico: Vector2 = camera.zoom
	camera.zoom = Vector2.ONE * 0.5
	for i in 12:
		camera._process(1.0 / 60)
	conferir(camera.zoom.is_equal_approx(unico), "Suavização independe da taxa de quadros")
	# Circular: mantém os 32 últimos pontos em ordem e em coordenadas de mundo.
	nave.condicao = nave.Condicao.EM_VOO
	nave.velocidade = Vector2(60, 0)
	var combustivel: int = nave.combustivel
	var tempo: float = partida.tempo_restante
	for indice in 48:
		nave.global_position = Vector2(indice * 2, 100)
		rastro._physics_process(1.0 / 30)
	conferir(rastro.points.size() == 32 and rastro.points[0] == Vector2(32, 100) and rastro.points[-1] == Vector2(94, 100), "Buffer circular descarta os mais antigos sem inverter a ordem")
	var pontos: PackedVector2Array = rastro.points.duplicate()
	camera.global_position += Vector2(200, 100)
	nave.global_rotation = PI
	conferir(rastro.points == pontos and rastro.get_parent() == mundo and rastro.z_index < nave.z_index, "Rastro fica no mundo atrás da nave, sem girar ou seguir a câmera")
	for zoom in [0.375, 0.5, 0.7]:
		camera.zoom = Vector2.ONE * zoom
		rastro._process(0)
		conferir(is_equal_approx(rastro.width * zoom, 2.0) and not rastro.antialiased, "Rastro mantém 2 px de tela sem antialias")
	conferir(rastro.gradient.get_color(0).a == 0 and rastro.gradient.get_color(1) == Color("82f0d1"), "Cauda transparente termina em ciano")
	conferir(nave.combustivel == combustivel and partida.tempo_restante == tempo and nave.velocidade == Vector2(60, 0), "Efeitos não consomem recursos nem mudam velocidade")
	nave.condicao = nave.Condicao.A_DERIVA
	nave.global_position += Vector2(2, 0)
	rastro._physics_process(1.0 / 30)
	conferir(not rastro.points.is_empty(), "Deriva também produz rastro")
	nave.velocidade = Vector2.ONE
	rastro._physics_process(1.0 / 30)
	conferir(rastro.points.is_empty(), "Velocidade baixa limpa o rastro")
	nave.velocidade = Vector2(60, 0)
	rastro._physics_process(1.0 / 30)
	nave.condicao = nave.Condicao.POUSADA
	nave.condicao_alterada.emit()
	conferir(rastro.points.is_empty(), "Pouso limpa o rastro imediatamente")
	nave.condicao = nave.Condicao.EM_VOO
	rastro._physics_process(1.0 / 30)
	partida.pausar()
	conferir(rastro.points.is_empty(), "Pausa não deixa rastro congelado")
	partida.retomar()
	rastro._physics_process(1.0 / 30)
	conferir(rastro.points.size() == 1, "Retomar começa um novo trecho")
	nave.parar()
	conferir(rastro.points.is_empty(), "Parar a simulação limpa imediatamente")
	partida.reiniciar()
	conferir(rastro.points.is_empty() and camera.zoom == base, "Reinício limpa histórico e recupera zoom autoral")
	nave.condicao = nave.Condicao.EM_VOO
	nave.velocidade = Vector2(60, 0)
	rastro._physics_process(1.0 / 30)
	rastro.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	conferir(rastro.points.is_empty(), "Perder foco também limpa o rastro")
	mundo.free()
	print("Efeitos de voo: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas else 0)
