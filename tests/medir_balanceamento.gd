extends SceneTree
## Varredura reproduzível de mira: uma etapa varia por vez, sem simular destreza humana.

const Carregador = preload("res://src/Nivel/carregador_fase.gd")
const CenaNivel = preload("res://src/Nivel/Nivel.tscn")
const Rotas = preload("res://tests/test_fases.gd")
const DELTA := 1.0 / 60.0
const PASSO_GRAUS := 0.25
const LIMITE_GRAUS := 4.0

func _initialize() -> void:
	_executar.call_deferred()

func executar_rota(recurso: NivelRes, etapas: Array, indice_alterado := -1, desvio := 0.0) -> Dictionary:
	var nivel = CenaNivel.instantiate()
	nivel.nivel_res = recurso
	root.add_child(nivel)
	var partida = nivel.partida
	var nave = nivel.get_node("Nave")
	partida.set_physics_process(false)
	nivel.camera._process(2.0)
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	var registros: Array = []
	var ultimo_contato: Array = []
	nave.contato_detectado.connect(func(c): ultimo_contato.assign([c.get("body", {}).get("id", c.get("kind", ""))]))
	var resultado := false
	for indice in range(etapas.size()):
		var etapa: Dictionary = etapas[indice]
		for passo in range(int(etapa.get("espera", 0))):
			partida.avancar(DELTA)
		var ajuste := desvio if indice == indice_alterado else 0.0
		var impulso: Vector2
		if etapa.has("alvo") or etapa.has("ponto"):
			var alvo: Vector2
			if etapa.has("ponto"):
				alvo = Vector2(etapa.ponto[0], etapa.ponto[1])
			else:
				for corpo in nave.corpos:
					if corpo.id == etapa.alvo:
						alvo = corpo.position
			var desejada: Vector2 = (alvo - nave.global_position).normalized().rotated(deg_to_rad(float(etapa.get("correcao", 0.0)) + ajuste)) * float(etapa.get("velocidade", 90.0))
			var atual: Vector2 = nave.velocidade_apoio() if nave.condicao in [nave.Condicao.POUSADA, nave.Condicao.PRONTA] else nave.velocidade
			impulso = desejada - atual
		else:
			impulso = Vector2.RIGHT.rotated(deg_to_rad(float(etapa.angulo) + ajuste)) * nave.entrada.impulso_maximo * float(etapa.get("forca", 1.0))
		var angulo := rad_to_deg(impulso.angle())
		if not nave.solicitar_impulso(nave._ultimo_pedido + 1, impulso):
			break
		var passos := 0
		for i in range(int(etapa.get("passos", 1200))):
			partida.avancar(DELTA)
			passos += 1
			if partida.estado != partida.Estado.JOGANDO or nave.condicao == nave.Condicao.POUSADA:
				break
		var destino: String = "terra" if partida.estado == partida.Estado.CONCLUIDA else nave.corpo_apoio
		registros.append({"angulo": snappedf(angulo, 0.01), "impulso": snappedf(impulso.length(), 0.01), "passos": passos, "destino": destino if not destino.is_empty() else "voo", "saldo": nave.combustivel, "contato": ultimo_contato.back() if not ultimo_contato.is_empty() else ""})
		if etapa.has("passos"):
			if partida.estado != partida.Estado.JOGANDO or nave.condicao not in [nave.Condicao.EM_VOO, nave.Condicao.A_DERIVA]:
				break
		elif destino != etapa.contato:
			break
		if indice == etapas.size() - 1 and partida.estado == partida.Estado.CONCLUIDA:
			resultado = true
	var motivo: String = partida.motivo
	var estrelas: int = partida.estrelas_coletadas.size()
	nivel.free()
	return {"venceu": resultado, "etapas": registros, "motivo": motivo, "estrelas": estrelas}

func _executar() -> void:
	var falhas := 0
	for rota in Rotas.ROTAS:
		var recurso = Carregador.carregar("res://Recursos/Fases/" + rota.id + ".json").nivel
		if recurso == null:
			falhas += 1
			continue
		var nominal := executar_rota(recurso, rota.etapas)
		var coleta := executar_rota(recurso, rota.coleta)
		if not nominal.venceu or not coleta.venceu or nominal.estrelas != 2 or coleta.estrelas != 3:
			falhas += 1
			print("FALHA nominal: ", rota.id, " ", nominal, " coleta: ", coleta)
			continue
		var margens: Array = []
		for indice in range(rota.etapas.size()):
			var lados: Array = []
			var falhas_lado: Array = []
			for sinal in [-1.0, 1.0]:
				var ultima := 0.0
				for i in range(1, int(LIMITE_GRAUS / PASSO_GRAUS) + 1):
					var desvio := i * PASSO_GRAUS
					var tentativa := executar_rota(recurso, rota.etapas, indice, sinal * desvio)
					if not tentativa.venceu:
						falhas_lado.append({"desvio": sinal * desvio, "motivo": tentativa.motivo, "etapas": tentativa.etapas})
						break
					ultima = desvio
				lados.append(ultima)
			margens.append(lados)
		print(JSON.stringify({"id": rota.id, "etapas": nominal.etapas, "etapas_coleta": coleta.etapas, "estrelas": nominal.estrelas, "estrelas_coleta": coleta.estrelas, "margens_graus": margens, "passo": PASSO_GRAUS, "limite": LIMITE_GRAUS}))
	print("Medição: ", Rotas.ROTAS.size(), " rotas, ", falhas, " falhas nominais.")
	quit(1 if falhas else 0)
