extends RefCounted
## Rotas testemunha executadas pela física real, sem alterar combustível/velocidade.
const ROTAS := [
	{"id":"fenda_no_espaco", "etapas":[{"alvo":"A","velocidade":90,"contato":"terra"}],
	 "coleta":[{"alvo":"A","velocidade":90,"passos":110},{"ponto":[740,-65],"velocidade":45,"passos":85},{"alvo":"terra","velocidade":50,"contato":"terra"}]},
	{"id":"salto_entre_rochas", "etapas":[{"alvo":"A","velocidade":90,"contato":"terra"}],
	 "coleta":[{"alvo":"A","velocidade":90,"passos":125},{"ponto":[785,-65],"velocidade":45,"passos":85},{"alvo":"terra","velocidade":50,"contato":"terra"}]},
	{"id":"nevoa_cega", "etapas":[{"alvo":"terra","velocidade":90,"contato":"terra"}],
	 "coleta":[{"alvo":"terra","velocidade":90,"passos":220},{"ponto":[380,-65],"velocidade":45,"passos":85},{"alvo":"terra","velocidade":50,"contato":"terra"}]},
	{"id":"rota_no_escuro", "etapas":[{"angulo":-38,"contato":"terra"}],
	 "coleta":[{"angulo":-38,"passos":146},{"ponto":[429.899,199.036],"velocidade":50,"passos":115},{"alvo":"terra","velocidade":80,"contato":"terra"}]},
	{"id":"desvio_nebuloso", "etapas":[{"alvo":"apoio_1","velocidade":90,"contato":"apoio_1"},{"ponto":[-20,-280],"velocidade":50,"passos":285},{"alvo":"apoio_3","velocidade":50,"contato":"apoio_3"},{"alvo":"terra","velocidade":90,"contato":"terra"}]},
	{"id":"portal_invisivel", "etapas":[{"alvo":"A","velocidade":90,"contato":"terra"}],
	 "coleta":[{"alvo":"A","velocidade":90,"passos":145},{"ponto":[785,5],"velocidade":45,"passos":85},{"alvo":"terra","velocidade":50,"contato":"terra"}]},
	{"id":"orbita_cega", "etapas":[{"angulo":-38,"contato":"terra"}],
	 "coleta":[{"angulo":-38,"passos":146},{"ponto":[429.899,199.036],"velocidade":50,"passos":115},{"alvo":"terra","velocidade":80,"contato":"terra"}]},
	{"id":"rede_de_portais", "etapas":[{"alvo":"A","velocidade":90,"contato":"terra"}],
	 "coleta":[{"alvo":"A","velocidade":40,"passos":430},{"ponto":[897,-100],"velocidade":45,"passos":180},{"alvo":"terra","velocidade":50,"contato":"terra"}]},
	{"id":"travessia_extrema", "etapas":[{"alvo":"apoio_1","velocidade":90,"contato":"apoio_1"},{"ponto":[35,-220],"velocidade":50,"passos":180},{"alvo":"A","velocidade":50,"contato":"apoio_2"},{"alvo":"apoio_3","velocidade":90,"contato":"apoio_3"},{"alvo":"terra","velocidade":90,"contato":"terra"}]},
	{"id":"grande_retorno", "etapas":[{"alvo":"planeta","velocidade":90,"contato":"planeta"},{"alvo":"A","velocidade":90,"espera":225,"contato":"orbital"},{"ponto":[530,-130],"velocidade":50,"passos":210},{"alvo":"C","velocidade":50,"contato":"apoio_3"},{"alvo":"apoio_4","velocidade":90,"contato":"apoio_4"},{"alvo":"terra","velocidade":90,"contato":"terra"}]}
]

static func executar(partida: Node, etapas: Array) -> Dictionary:
	var nave = partida.nave
	var rastros: Array = []
	var resumo: Array = []
	var saltos := [0]
	var registrar := func(inicio: Vector2, fim: Vector2): rastros.append([inicio, fim])
	var salto := func(): saltos[0] += 1
	nave.trecho_percorrido.connect(registrar)
	nave.trajeto_interrompido.connect(salto)
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	for etapa in etapas:
		for i in int(etapa.get("espera", 0)):
			partida.avancar(1.0 / 60)
		var impulso: Vector2
		if etapa.has("angulo"):
			impulso = Vector2.RIGHT.rotated(deg_to_rad(float(etapa.angulo))) * 100
		else:
			var alvo: Vector2
			if etapa.has("ponto"):
				alvo = Vector2(etapa.ponto[0], etapa.ponto[1])
			else:
				for corpo in nave.corpos:
					if corpo.id == etapa.alvo:
						alvo = corpo.position
			var atual: Vector2 = nave.velocidade_apoio() if nave.condicao in [nave.Condicao.POUSADA,nave.Condicao.PRONTA] else nave.velocidade
			impulso = (alvo - nave.global_position).normalized() * float(etapa.get("velocidade",90)) - atual
		if not nave.solicitar_impulso(nave._ultimo_pedido + 1, impulso):
			resumo.append({"erro":"impulso recusado","modulo":impulso.length(),"combustivel":nave.combustivel})
			break
		for i in int(etapa.get("passos",2400)):
			partida.avancar(1.0/60)
			if partida.estado != partida.Estado.JOGANDO or nave.condicao == nave.Condicao.POUSADA:
				break
		resumo.append({"posicao":nave.global_position,"apoio":nave.corpo_apoio,"combustivel":nave.combustivel,"motivo":partida.motivo,"oxigenio":partida.tempo_restante})
		if partida.estado != partida.Estado.JOGANDO:
			break
		if etapa.has("contato") and nave.corpo_apoio != etapa.contato:
			break
	nave.trecho_percorrido.disconnect(registrar)
	nave.trajeto_interrompido.disconnect(salto)
	return {"venceu":partida.estado==partida.Estado.CONCLUIDA,"trechos":rastros,"resumo":resumo,"saltos":maxi(0,saltos[0]-1),"douradas":partida.quantidade_coletada(),"tanques":partida.combustiveis_coletados.size()}
