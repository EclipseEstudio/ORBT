extends SceneTree
## Rotas reais da campanha, com margem de mira e conferência da prévia.
## Também pode ser executado externamente contra o PCK exportado.

const Catalogo = preload("res://src/Campanha/catalogo.gd")
const Carregador = preload("res://src/Nivel/carregador_fase.gd")
const CenaNivel = preload("res://src/Nivel/Nivel.tscn")
const ROTAS = [
	{"id": "teste_001", "margem": 3.0, "etapas": [{"angulo": -90.0, "contato": "terra"}]},
	{"id": "salto_curto", "modelo": 1, "rochas": 44, "margem": 0.5, "etapas": [{"angulo": -14.5, "contato": "terra"}]},
	{"id": "na_diagonal", "modelo": 2, "rochas": 58, "margem": 0.4, "etapas": [{"angulo": -0.7, "contato": "terra"}]},
	{"id": "curva_suave", "modelo": 3, "rochas": 68, "margem": 0.5, "etapas": [
		{"angulo": -40.0, "contato": "apoio_1"},
		{"radial": "apoio_1", "fator": 0.137, "correcao": -1.43, "margem": 0.25, "contato": "apoio_2"},
		{"alvo": "terra", "correcao": 7.0, "margem": 1.0, "contato": "terra"},
	]},
	{"id": "escala_segura", "modelo": 4, "rochas": 59, "margem": 0.5, "etapas": [{"angulo": 11.7, "contato": "terra"}]},
	{"id": "entre_asteroides", "modelo": 5, "rochas": 60, "margem": 1.0, "etapas": [{"angulo": 18.0, "passos": 90}, {"angulo": -50.0, "forca": 0.5, "contato": "terra"}]},
	{"id": "contorno", "margem": 1.0, "etapas": [{"angulo": -15.0, "passos": 120}, {"angulo": 100.0, "forca": 0.8, "contato": "terra"}]},
	{"id": "duas_rotas", "margem": 1.0, "etapas": [{"angulo": -25.0, "passos": 120}, {"angulo": 90.0, "forca": 0.8, "contato": "terra"}], "alternativa": [{"angulo": 25.0, "passos": 120}, {"angulo": -90.0, "forca": 0.8, "contato": "terra"}]},
	{"id": "portas_gemeas", "margem": 1.0, "etapas": [{"angulo": 65.0, "passos": 120}, {"angulo": 180.0, "forca": 0.8, "contato": "terra"}], "alternativa": [{"angulo": 115.0, "passos": 120}, {"angulo": 0.0, "forca": 0.8, "contato": "terra"}]},
	{"id": "retorno_a_terra", "margem": 1.0, "etapas": [{"angulo": -40.0, "passos": 120}, {"angulo": 75.0, "forca": 0.8, "contato": "terra"}]},
]
const DELTA = 1.0 / 60.0
var verificacoes := 0
var falhas := 0


func _initialize() -> void:
	_executar.call_deferred()


func conferir(condicao: bool, mensagem: String) -> bool:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)
	return condicao


func jogar(nivel: Node, etapas: Array, desvios: Array = [], comparar_previa := false) -> bool:
	var partida = nivel.partida
	var nave = nivel.get_node("Nave")
	partida.set_physics_process(false)
	nivel.camera._process(2.0)
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	for indice_etapa in range(etapas.size()):
		var etapa: Dictionary = etapas[indice_etapa]
		var desvio: float = desvios[indice_etapa] if indice_etapa < desvios.size() else 0.0
		var forca: float = etapa.get("forca", 1.0)
		var angulo: float = etapa.get("angulo", 0.0)
		# Como o jogador, a rota reajusta a mira depois de cada ponto de pouso.
		if etapa.has("radial"):
			var apoio: Dictionary = nivel.nivel_res.obter_corpo(etapa.radial)
			angulo = rad_to_deg((nave.global_position - apoio.position).angle()) * etapa.fator + etapa.correcao
		elif etapa.has("alvo"):
			var alvo: Dictionary = nivel.nivel_res.obter_corpo(etapa.alvo)
			angulo = rad_to_deg((alvo.position - nave.global_position).angle()) + etapa.correcao
		var impulso: Vector2 = Vector2.RIGHT.rotated(deg_to_rad(angulo + desvio)) * nave.entrada.impulso_maximo * forca
		var contexto := "%s, etapa %d, desvio %.1f°" % [nivel.nivel_res.id, indice_etapa + 1, desvio]
		var pontos := PackedVector2Array()
		if comparar_previa:
			nave.entrada.gesto.iniciar(0, Vector2(90, 140))
			var arraste: float = nave.entrada.zona_morta + (nave.entrada.arraste_maximo - nave.entrada.zona_morta) * forca
			nave.entrada.gesto.mover(0, Vector2(90, 140) - impulso.normalized() * arraste)
			pontos = nave.prever_trajetoria()
			nave.entrada.cancelar()
		if not conferir(nave.solicitar_impulso(nave._ultimo_pedido + 1, impulso), contexto + ": lançamento aceito"):
			return false
		var indice_previa := 1
		var amostras := 0
		var erro_maximo := 0.0
		var limite_passos: int = etapa.get("passos", 1200)
		for passo in range(limite_passos):
			partida.avancar(DELTA)
			var terminou: bool = partida.estado != partida.Estado.JOGANDO or nave.condicao == nave.Condicao.POUSADA
			if comparar_previa and (passo % 3 == 2 or terminou) and indice_previa < pontos.size():
				# O pouso encaixa a nave na superfície depois do contato previsto.
				if nave.condicao != nave.Condicao.POUSADA:
					erro_maximo = maxf(erro_maximo, nave.global_position.distance_to(pontos[indice_previa]))
					amostras += 1
				indice_previa += 1
			if terminou:
				break
		if etapa.has("passos"):
			if not conferir(partida.estado == partida.Estado.JOGANDO and nave.condicao in [nave.Condicao.EM_VOO, nave.Condicao.A_DERIVA], contexto + ": permanece em voo até a correção"):
				return false
		else:
			var destino: String = "terra" if partida.estado == partida.Estado.CONCLUIDA else nave.corpo_apoio
			if not conferir(destino == etapa.contato, contexto + ": chega a " + etapa.contato + " em até 20 segundos (" + partida.motivo + ")"):
				return false
		conferir(nave.combustivel == nivel.nivel_res.combustivel_inicial - indice_etapa - 1, contexto + ": uma cobrança por lançamento")
		if comparar_previa:
			conferir(amostras > 0 and erro_maximo < 0.001, contexto + ": prévia acompanha o voo")
	return conferir(partida.estado == partida.Estado.CONCLUIDA, nivel.nivel_res.id + ": rota completa chega à Terra")


func _executar() -> void:
	var catalogo := Catalogo.carregar("res://Recursos/Niveis.json")
	if not conferir(catalogo.erros.is_empty() and catalogo.itens.size() == ROTAS.size(), "Campanha contém dez fases"):
		quit(1)
		return
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	root.add_child(jogo)
	await process_frame
	jogo.mostrar_selecao()
	await process_frame
	conferir(jogo.interface_atual.cartoes.get_child_count() == ROTAS.size(), "Seleção mostra as dez fases")
	for indice in range(ROTAS.size()):
		var rota: Dictionary = ROTAS[indice]
		conferir(catalogo.itens[indice].id == rota.id, rota.id + ": ordem correta no catálogo")
		var resultado := Carregador.carregar(catalogo.itens[indice].arquivo)
		if not conferir(resultado.nivel != null, rota.id + ": dados e geometria válidos"):
			continue
		conferir(jogo.progresso.pode_abrir(rota.id), rota.id + ": desbloqueada pela vitória anterior")
		if not conferir(jogo.iniciar_fase(rota.id), rota.id + ": abre pelo controlador de produção"):
			continue
		if rota.has("modelo"):
			var dados: Dictionary = resultado.nivel.dados_autorais
			conferir(dados.reference_level == rota.modelo and dados.bodies.filter(func(corpo: Dictionary): return corpo.type == "asteroid").size() == rota.rochas, rota.id + ": preserva mapa de referência e muros de asteroides")
			conferir(jogo.mundo_atual.get_node("Nave").condicao == jogo.mundo_atual.get_node("Nave").Condicao.PRONTA, rota.id + ": início livre aguarda lançamento")
			var camera: Camera2D = jogo.mundo_atual.camera
			conferir(camera.zoom.is_equal_approx(Vector2(0.5, 0.5)), rota.id + ": zoom de voo do mapa maior")
			jogo.mundo_atual.partida.alternar_exploracao()
			conferir(camera.zoom.x < 0.5 and is_equal_approx(camera.global_position.x, 450.0) and camera.global_position.y > 300.0, rota.id + ": explorar enquadra o mapa entre o HUD e o rodapé")
			jogo.mundo_atual.partida.alternar_exploracao()
			conferir(camera.zoom.is_equal_approx(Vector2(0.5, 0.5)), rota.id + ": voltar restaura zoom de voo")
		jogar(jogo.mundo_atual, rota.etapas, [], true)
		conferir(jogo.progresso.estado(rota.id) == "Concluída", rota.id + ": vitória registrada na campanha")
		jogo.mostrar_selecao()
		await process_frame
		if rota.has("alternativa"):
			for desvios in [[], [-1.0, -1.0], [-1.0, 1.0], [1.0, -1.0], [1.0, 1.0]]:
				var alternativa = CenaNivel.instantiate()
				alternativa.nivel_res = resultado.nivel
				root.add_child(alternativa)
				jogar(alternativa, rota.alternativa, desvios, desvios.is_empty())
				alternativa.queue_free()
				await process_frame
		var variacoes: Array = [[]]
		for etapa in rota.etapas:
			var seguintes: Array = []
			var margem: float = etapa.get("margem", rota.margem)
			for combinacao in variacoes:
				for desvio in [-margem, margem]:
					seguintes.append(combinacao + [desvio])
			variacoes = seguintes
		for desvios in variacoes:
			var nivel = CenaNivel.instantiate()
			nivel.nivel_res = resultado.nivel
			root.add_child(nivel)
			jogar(nivel, rota.etapas, desvios)
			nivel.queue_free()
			await process_frame
	conferir(jogo.progresso.concluidas.size() == ROTAS.size(), "Campanha completa libera e conclui todas as fases")
	jogo.queue_free()
	await process_frame
	print("Fases: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
