extends SceneTree
## Rotas jogáveis da campanha: economia, pousos, órbitas e coleta opcional.

const Catalogo = preload("res://src/Campanha/catalogo.gd")
const Carregador = preload("res://src/Nivel/carregador_fase.gd")
const CenaNivel = preload("res://src/Nivel/Nivel.tscn")
const ROTAS = [
	{"id": "teste_001", "margem": 1.5,
		"etapas": [{"angulo":-90,"forca":1,"contato":"terra"}],
		"coleta": [{"angulo":-90,"forca":1,"passos":70},{"ponto":[121.052,100.272],"velocidade":60,"passos":51},{"alvo":"terra","velocidade":60,"correcao":0,"contato":"terra"}]},
	{"id": "mira_aberta", "margem": 1.5,
		"etapas": [{"alvo":"terra","velocidade":90,"contato":"terra"}],
		"coleta": [{"alvo":"terra","velocidade":90,"passos":99},{"ponto":[245.121,212.252],"velocidade":60,"passos":80},{"alvo":"terra","velocidade":60,"correcao":0,"contato":"terra"}]},
	{"id": "passagem_larga", "margem": 1.5,
		"etapas": [{"alvo":"terra","velocidade":90,"contato":"terra"}],
		"coleta": [{"alvo":"terra","velocidade":90,"passos":117},{"ponto":[275.602,179.329],"velocidade":60,"passos":91},{"alvo":"terra","velocidade":60,"correcao":0,"contato":"terra"}]},
	{"id": "primeiro_pouso", "margem": 1.5,
		"etapas": [{"alvo":"apoio","velocidade":90,"contato":"apoio"},{"alvo":"terra","velocidade":90,"contato":"terra"}],
		"coleta": [{"alvo":"apoio","velocidade":90,"contato":"apoio"},{"alvo":"terra","velocidade":90,"passos":80},{"ponto":[68.905,139.76],"velocidade":60,"passos":70},{"alvo":"terra","velocidade":60,"correcao":0,"contato":"terra"}]},
	{"id": "segundo_impulso", "margem": 1.5,
		"etapas": [{"angulo":-30,"passos":120},{"angulo":90,"forca":0.9,"contato":"terra"}],
		"coleta": [{"angulo":-30,"passos":120},{"angulo":90,"forca":0.9,"passos":64},{"ponto":[377.22,296.976],"velocidade":60,"passos":63},{"alvo":"terra","velocidade":60,"correcao":0,"contato":"terra"}]},
	{"id": "de_lua_em_lua", "margem": 0.5,
		"etapas": [{"alvo":"apoio_1","velocidade":90,"contato":"apoio_1"},{"alvo":"apoio_2","velocidade":90,"contato":"apoio_2"},{"alvo":"terra","velocidade":90,"contato":"terra"}],
		"coleta": [{"alvo":"apoio_1","velocidade":90,"contato":"apoio_1"},{"alvo":"apoio_2","velocidade":90,"contato":"apoio_2"},{"alvo":"terra","velocidade":90,"passos":86},{"ponto":[332.615,175.185],"velocidade":60,"passos":73},{"alvo":"terra","velocidade":60,"correcao":0,"contato":"terra"}]},
	{"id": "escala_no_desvio", "margem": 0.5,
		"etapas": [{"alvo":"apoio","velocidade":90,"contato":"apoio"},{"alvo":"terra","velocidade":90,"contato":"terra"}],
		"coleta": [{"alvo":"apoio","velocidade":90,"contato":"apoio"},{"alvo":"terra","velocidade":90,"passos":103},{"ponto":[143.717,100.023],"velocidade":60,"passos":84},{"alvo":"terra","velocidade":60,"correcao":0,"contato":"terra"}]},
	{"id": "corredor_de_retorno", "margem": 0.5,
		"etapas": [{"angulo":-30,"passos":144},{"angulo":90,"forca":0.98,"contato":"terra"}],
		"coleta": [{"angulo":-30,"passos":144},{"angulo":90,"forca":0.98,"passos":72},{"ponto":[430.9,294.79],"velocidade":60,"passos":69},{"alvo":"terra","velocidade":60,"correcao":0,"contato":"terra"}]},
	{"id": "curva_gravitacional", "margem": 0.5,
		"etapas": [{"angulo":-38,"contato":"terra"}],
		"coleta": [{"angulo":-38,"passos":146},{"ponto":[429.899,199.036],"velocidade":50,"passos":115},{"alvo":"terra","velocidade":80,"correcao":0,"contato":"terra"}]},
	{"id": "rasante_solar", "margem": 0.5,
		"etapas": [{"angulo":-42,"contato":"terra"}],
		"coleta": [{"angulo":-42,"passos":134},{"ponto":[418.084,197.024],"velocidade":70,"passos":100},{"alvo":"terra","velocidade":80,"correcao":0,"contato":"terra"}]},
	{"id": "lua_em_movimento", "margem": 0.5,
		"etapas": [{"angulo":-19.15,"contato":"apoio"},{"alvo":"terra","velocidade":90,"contato":"terra"}],
		"coleta": [{"angulo":-19.15,"contato":"apoio"},{"alvo":"terra","velocidade":90,"passos":77},{"ponto":[129.714,111.604],"velocidade":60,"passos":68},{"alvo":"terra","velocidade":60,"correcao":0,"contato":"terra"}]},
	{"id": "janela_orbital", "margem": 0.5,
		"etapas": [{"alvo":"terra","velocidade":90,"contato":"terra"}],
		"coleta": [{"alvo":"terra","velocidade":90,"passos":97},{"ponto":[305.352,207.91],"velocidade":60,"passos":80},{"alvo":"terra","velocidade":60,"correcao":0,"contato":"terra"}]},
	{"id": "contorno", "margem": 0.5,
		"etapas": [{"angulo":-15,"passos":120},{"angulo":100,"forca":0.8,"contato":"terra"}],
		"coleta": [{"angulo":-15,"passos":120},{"angulo":100,"forca":0.8,"passos":70},{"ponto":[429.964,281.033],"velocidade":60,"passos":67},{"alvo":"terra","velocidade":60,"correcao":0,"contato":"terra"}]},
	{"id": "duas_rotas", "margem": 0.5,
		"etapas": [{"angulo":-25,"passos":120},{"angulo":90,"forca":0.8,"contato":"terra"}],
		"coleta": [{"angulo":-25,"passos":120},{"angulo":90,"forca":0.8,"passos":70},{"ponto":[433.378,257.993],"velocidade":60,"passos":67},{"alvo":"terra","velocidade":60,"correcao":0,"contato":"terra"}]},
	{"id": "pouso_de_precisao", "margem": 0.5,
		"etapas": [{"alvo":"apoio_1","velocidade":90,"contato":"apoio_1"},{"alvo":"apoio_2","velocidade":90,"contato":"apoio_2"},{"alvo":"terra","velocidade":90,"contato":"terra"}],
		"coleta": [{"alvo":"apoio_1","velocidade":90,"contato":"apoio_1"},{"alvo":"apoio_2","velocidade":90,"contato":"apoio_2"},{"alvo":"terra","velocidade":90,"passos":86},{"ponto":[344.514,127.748],"velocidade":60,"passos":74},{"alvo":"terra","velocidade":60,"correcao":0,"contato":"terra"}]},
	{"id": "travessia_orbital", "margem": 0.5,
		"etapas": [{"angulo":-24,"contato":"apoio"},{"alvo":"terra","velocidade":90,"contato":"terra"}],
		"coleta": [{"angulo":-24,"contato":"apoio"},{"alvo":"terra","velocidade":90,"passos":101},{"ponto":[132.121,99.112],"velocidade":60,"passos":82},{"alvo":"terra","velocidade":60,"correcao":0,"contato":"terra"}]},
	{"id": "arco_entre_rochas", "margem": 0.5,
		"etapas": [{"angulo":-43,"contato":"terra"}],
		"coleta": [{"angulo":-43,"passos":159},{"ponto":[423.796,269.545],"velocidade":70,"passos":83},{"alvo":"terra","velocidade":70,"correcao":4,"contato":"terra"}]},
	{"id": "tres_escalas", "margem": 0.5,
		"etapas": [{"alvo":"apoio_1","velocidade":90,"contato":"apoio_1"},{"alvo":"apoio_2","velocidade":90,"contato":"apoio_2"},{"alvo":"apoio_3","velocidade":90,"contato":"apoio_3"},{"alvo":"terra","velocidade":90,"contato":"terra"}],
		"coleta": [{"alvo":"apoio_1","velocidade":90,"contato":"apoio_1"},{"alvo":"apoio_2","velocidade":90,"contato":"apoio_2"},{"alvo":"apoio_3","velocidade":90,"contato":"apoio_3"},{"alvo":"terra","velocidade":90,"passos":97},{"ponto":[158.766,38.205],"velocidade":60,"passos":79},{"alvo":"terra","velocidade":60,"correcao":0,"contato":"terra"}]},
	{"id": "cinturao_em_movimento", "margem": 0.5,
		"etapas": [{"angulo":-32,"passos":156},{"angulo":90,"forca":1,"contato":"terra"}],
		"coleta": [{"angulo":-32,"passos":156},{"angulo":90,"forca":1,"passos":88},{"ponto":[462.977,321.868],"velocidade":60,"passos":77},{"alvo":"terra","velocidade":60,"correcao":0,"contato":"terra"}]},
	{"id": "ultima_manobra", "margem": 0.5,
		"etapas": [{"angulo":-25,"contato":"apoio_1"},{"alvo":"apoio_2","velocidade":90,"contato":"apoio_2"},{"angulo":-32,"passos":120},{"angulo":90,"forca":0.6,"contato":"terra"}],
		"coleta": [{"angulo":-25,"contato":"apoio_1"},{"alvo":"apoio_2","velocidade":90,"contato":"apoio_2"},{"angulo":-32,"passos":120},{"angulo":90,"forca":0.6,"passos":81},{"ponto":[490.943,132.086],"velocidade":60,"passos":67},{"alvo":"terra","velocidade":60,"correcao":0,"contato":"terra"}]},
]
const DELTA := 1.0 / 60.0
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


func jogar(nivel: Node, etapas: Array, estrelas: int, desvio := 0.0) -> bool:
	var partida = nivel.partida
	var nave = nivel.get_node("Nave")
	partida.set_physics_process(false)
	nivel.camera._process(2.0)
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	for indice in range(etapas.size()):
		var etapa: Dictionary = etapas[indice]
		for passo in range(int(etapa.get("espera", 0))):
			partida.avancar(DELTA)
		var impulso: Vector2
		if etapa.has("alvo") or etapa.has("ponto"):
			var alvo: Vector2
			if etapa.has("ponto"):
				alvo = Vector2(etapa.ponto[0], etapa.ponto[1])
			else:
				for corpo in nave.corpos:
					if corpo.id == etapa.alvo:
						alvo = corpo.position
			var desejada: Vector2 = (alvo - nave.global_position).normalized().rotated(deg_to_rad(etapa.get("correcao", 0.0) + desvio)) * float(etapa.get("velocidade", 90.0))
			var atual: Vector2 = nave.velocidade_apoio() if nave.condicao in [nave.Condicao.POUSADA, nave.Condicao.PRONTA] else nave.velocidade
			impulso = desejada - atual
		else:
			impulso = Vector2.RIGHT.rotated(deg_to_rad(float(etapa.angulo) + desvio)) * nave.entrada.impulso_maximo * float(etapa.get("forca", 1.0))
		var contexto := "%s etapa %d desvio %.2f" % [nivel.nivel_res.id, indice + 1, desvio]
		if not conferir(impulso.length() <= nave.entrada.impulso_maximo + 0.001, contexto + ": força ao alcance do jogador"):
			return false
		if not conferir(nave.solicitar_impulso(nave._ultimo_pedido + 1, impulso), contexto + ": impulso aceito"):
			return false
		for passo in range(int(etapa.get("passos", 1500))):
			partida.avancar(DELTA)
			if partida.estado != partida.Estado.JOGANDO or nave.condicao == nave.Condicao.POUSADA:
				break
		if etapa.has("passos"):
			if not conferir(partida.estado == partida.Estado.JOGANDO and nave.condicao in [nave.Condicao.EM_VOO, nave.Condicao.A_DERIVA], contexto + ": em voo até a correção"):
				return false
		else:
			var destino: String = "terra" if partida.estado == partida.Estado.CONCLUIDA else nave.corpo_apoio
			if not conferir(destino == etapa.contato, contexto + ": chega a " + str(etapa.contato) + " (" + partida.motivo + ")"):
				return false
		conferir(nave.combustivel == nivel.nivel_res.combustivel_inicial - indice - 1 + partida.combustiveis_coletados.size(), contexto + ": uma carga por impulso")
	if not conferir(partida.estado == partida.Estado.CONCLUIDA, nivel.nivel_res.id + ": chega à Terra"):
		return false
	conferir(partida.tempo_restante > 0, nivel.nivel_res.id + ": rota cabe no oxigênio disponível")
	if is_zero_approx(desvio):
		conferir(partida.quantidade_coletada("gold") == estrelas, "%s: rota recolhe %d estrelas, obtido %d" % [nivel.nivel_res.id, estrelas, partida.quantidade_coletada("gold")])
	return true


func _executar() -> void:
	var catalogo := Catalogo.carregar("res://Recursos/Niveis.json")
	if not conferir(catalogo.erros.is_empty() and catalogo.itens.size() == 30 and ROTAS.size() == 20, "Campanha contém trinta fases; este teste cobre as vinte originais"):
		quit(1)
		return
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	jogo.ativar_audio = false
	jogo.preferencias.dicas = false
	root.add_child(jogo)
	await process_frame
	jogo.preferencias.dicas = false
	jogo.mostrar_selecao()
	await process_frame
	conferir(jogo.interface_atual.quantidade_cartoes() == 30, "Seleção mostra trinta fases")
	for indice in range(ROTAS.size()):
		var rota: Dictionary = ROTAS[indice]
		var resultado := Carregador.carregar(catalogo.itens[indice].arquivo)
		conferir(catalogo.itens[indice].id == rota.id and catalogo.itens[indice].ordem == indice + 1, rota.id + ": ordem progressiva contínua")
		if not conferir(resultado.nivel != null, rota.id + ": dados e geometria válidos: " + str(resultado.erros)):
			continue
		conferir(resultado.nivel.quantidade_estrelas("gold") == 3, rota.id + ": três estrelas opcionais")
		conferir(rota.coleta.size() == rota.etapas.size() + 2 and rota.coleta.size() <= resultado.nivel.combustivel_inicial, rota.id + ": coleta completa exige mais recursos e cabe no combustível")
		if not conferir(jogo.iniciar_fase(rota.id), rota.id + ": desbloqueada pela vitória anterior e aberta em produção"):
			continue
		jogar(jogo.mundo_atual, rota.etapas, 2)
		if rota.id in ["mira_aberta", "passagem_larga"]:
			conferir(jogo.mundo_atual.partida.quantidade_coletada("blue") == 1, rota.id + ": primeira estrela azul aparece na rota direta")
		conferir(jogo.progresso.estado(rota.id) == "Concluída", rota.id + ": conclusão econômica registrada")
		conferir(jogo.progresso.melhor_estrelas(rota.id) == 2, rota.id + ": somente as estrelas trazidas à Terra são confirmadas")
		jogo.mostrar_selecao()
		await process_frame
		for desvio in [-float(rota.margem), float(rota.margem)]:
			var nivel = CenaNivel.instantiate()
			nivel.nivel_res = resultado.nivel
			root.add_child(nivel)
			jogar(nivel, rota.etapas, 2, desvio)
			nivel.queue_free()
			await process_frame
		if conferir(jogo.iniciar_fase(rota.id), rota.id + ": repetição abre fase concluída"):
			jogar(jogo.mundo_atual, rota.coleta, 3)
			if rota.id == "teste_001":
				conferir(jogo.mundo_atual.partida.quantidade_coletada("blue") == 1, "Primeira fase: azul acessível no desvio de coleta sem alterar a rota econômica")
			conferir(jogo.progresso.melhor_estrelas(rota.id) == 3, rota.id + ": repetição melhora recorde para três estrelas")
			var azuis: int = resultado.nivel.quantidade_estrelas("blue")
			conferir(jogo.mundo_atual.partida.quantidade_coletada("blue") == azuis, rota.id + ": rota alternativa permite a conquista azul com combustível disponível")
			conferir(jogo.progresso.melhor_azuis(rota.id) == azuis, rota.id + ": chegada confirma a conquista azul separadamente")
			jogo.mostrar_selecao()
			await process_frame
	conferir(jogo.progresso.concluidas.size() == 20 and jogo.progresso.total_estrelas() == 60, "Dois primeiros níveis: vinte fases e sessenta estrelas confirmadas")
	jogo.queue_free()
	await process_frame
	print("Fases: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
