extends Node

signal estado_alterado
signal concluida(id_fase: String)
signal perdida(motivo: String)
signal proximidade_alterada(id_corpo: String, proximo: bool)
signal reiniciada
signal selecao_solicitada
signal menu_solicitado
signal proxima_solicitada
signal checkpoint_alterado(checkpoint: Dictionary)
signal pouso_realizado
signal estrela_coletada(id: String)
signal combustivel_coletado(id: String)
var campanha_permitida := false

enum Estado { JOGANDO, PAUSADO, PERDIDA, CONCLUIDA }
var estado := Estado.JOGANDO
var motivo := ""
var aviso_salvamento := ""
var tempo_restante := 0.0
var temporizador_ativo := false
var explorando := false
var apresentando_fase := false
var proximos: Dictionary = {}
var estrelas_coletadas: Dictionary = {}
var combustiveis_coletados: Dictionary = {}
var nivel: NivelRes
var nave: Node2D
var _checkpoint: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func iniciar(dados: NivelRes, nave_atual: Node2D) -> void:
	nivel = dados
	nave = nave_atual
	nave.simulacao_automatica = false
	nave.impulso_aplicado.connect(_ao_impulso)
	nave.contato_detectado.connect(resolver_contato)
	nave.trecho_percorrido.connect(_coletar_trecho)
	reiniciar()


func reiniciar() -> void:
	get_tree().paused = false
	estado = Estado.JOGANDO
	motivo = ""
	explorando = false
	tempo_restante = nivel.tempo_voo
	temporizador_ativo = false
	estrelas_coletadas.clear()
	combustiveis_coletados.clear()
	_limpar_proximidade()
	nave.configurar(nivel)
	_registrar_checkpoint()
	estado_alterado.emit()
	reiniciada.emit()


func _physics_process(delta: float) -> void:
	if not apresentando_fase:
		avancar(delta * escala_tempo())


func escala_tempo() -> float:
	if estado != Estado.JOGANDO or not is_instance_valid(nave):
		return 1.0
	if nave.entrada.gesto.contato_ativo != -1 and nave.entrada.pode_controlar():
		return 0.25
	if nave.condicao == nave.Condicao.POUSADA:
		return 1.0
	var escala := 1.0
	for corpo in nave.corpos:
		# A Terra é o destino e uma margem de erro gravitacional: aproximar-se
		# dela não altera o ritmo de voo. A câmera lenta é reservada aos demais
		# obstáculos e corpos da rota, além da mira.
		if corpo.type in ["earth", "station", "portal"]:
			continue
		var contato: float = nave.Fisica.raio_contato(corpo) + nave.raio
		var alcance: float = maxf(contato + 24.0, corpo.proximity_radius + nave.raio)
		var fracao := clampf((nave.global_position.distance_to(corpo.position) - contato) / (alcance - contato), 0, 1)
		escala = minf(escala, lerpf(0.35, 1.0, smoothstep(0.0, 1.0, fracao)))
	return escala


func quantidade_coletada(tipo := "gold") -> int:
	return nivel.estrelas.filter(func(estrela: Dictionary): return estrela.get("type", "gold") == tipo and estrelas_coletadas.has(estrela.id)).size()


func avancar(delta: float) -> void:
	if estado != Estado.JOGANDO or not is_instance_valid(nave) or get_tree().paused:
		return
	# A nave aplica a fila uma única vez, no início de avancar().
	# O oxigênio é um saldo da tentativa; novos impulsos não o recarregam.
	var consumindo: bool = (temporizador_ativo and nave.condicao != nave.Condicao.POUSADA) or nave.tem_impulso_pendente()
	var consumo := 1.0 if nave.Fisica.dentro_limites(nave.global_position, nivel.limites) else 2.0
	var passo := minf(delta, tempo_restante / consumo) if consumindo else delta
	nave.avancar(passo)
	if estado != Estado.JOGANDO:
		return
	_atualizar_proximidade()
	if temporizador_ativo and nave.condicao != nave.Condicao.POUSADA:
		tempo_restante = maxf(0, tempo_restante - passo * consumo)
		if tempo_restante <= 0:
			finalizar(false, "Oxigênio esgotado")


func _ao_impulso(_gesto_id: int) -> void:
	temporizador_ativo = true


func _coletar_trecho(inicio: Vector2, fim: Vector2) -> void:
	if estado != Estado.JOGANDO or get_tree().paused:
		return
	for tanque in nivel.combustiveis:
		if combustiveis_coletados.has(tanque.id):
			continue
		if is_finite(nave.Fisica.intersecao_circulo(inicio, fim, tanque.position, tanque.radius + nave.raio)):
			combustiveis_coletados[tanque.id] = true
			nave.combustivel += tanque.amount
			if nave.condicao == nave.Condicao.A_DERIVA:
				nave.condicao = nave.Condicao.EM_VOO
			nave.atualizar_entrada()
			nave.combustivel_alterado.emit(nave.combustivel)
			combustivel_coletado.emit(tanque.id)
	var encontradas: Array = []
	for estrela in nivel.estrelas:
		if estrelas_coletadas.has(estrela.id):
			continue
		var fracao: float = nave.Fisica.intersecao_circulo(inicio, fim, estrela.position, estrela.radius + nave.raio)
		if is_finite(fracao):
			encontradas.append({"id": estrela.id, "fracao": fracao})
	encontradas.sort_custom(func(a: Dictionary, b: Dictionary): return a.fracao < b.fracao)
	for estrela in encontradas:
		estrelas_coletadas[estrela.id] = true
		estrela_coletada.emit(estrela.id)


func resolver_contato(contato: Dictionary) -> void:
	if estado != Estado.JOGANDO:
		return
	if contato.kind == "bounds":
		# Compatibilidade com contatos antigos: o espaço não encerra o voo.
		return
	var corpo: Dictionary = contato.body
	if not contato.get("safe_landing", true):
		finalizar(false, "Pouso fora da faixa segura")
		return
	match corpo.type:
		"sun", "asteroid":
			finalizar(false, "Colisão com perigo")
		"earth":
			finalizar(true, "Você chegou à Terra!")
		_:
			nave.pousar(corpo)
			pouso_realizado.emit()
			_registrar_checkpoint()
			if nave.combustivel == 0:
				finalizar(false, "Sem combustível para decolar")


func _registrar_checkpoint() -> void:
	_checkpoint = {
		"fase": nivel.id,
		"corpo": nave.corpo_apoio,
		"posicao": nave.global_position,
		"posicao_relativa": nave.posicao_relativa,
		"orientacao": nave.global_rotation,
		"combustivel": nave.combustivel,
		"tempo": tempo_restante,
		"temporizador_ativo": temporizador_ativo,
		"tempo_simulacao": nave.tempo_simulacao,
		"estrelas_coletadas": estrelas_coletadas.keys(),
		"combustiveis_coletados": combustiveis_coletados.keys(),
	}
	checkpoint_alterado.emit(_checkpoint.duplicate(true))


func restaurar_checkpoint(ao_reabrir := false) -> bool:
	if estado not in [Estado.PERDIDA, Estado.PAUSADO] or _checkpoint.is_empty() or _checkpoint.fase != nivel.id:
		return false
	nave.tempo_simulacao = _checkpoint.get("tempo_simulacao", 0.0)
	nave.Fisica.atualizar_corpos(nave.corpos, nave.tempo_simulacao)
	var corpo: Dictionary = {}
	for candidato in nave.corpos:
		if candidato.id == _checkpoint.corpo:
			corpo = candidato
	if not _checkpoint.corpo.is_empty() and corpo.is_empty():
		return false
	get_tree().paused = false
	estado = Estado.JOGANDO
	motivo = ""
	explorando = false
	_limpar_proximidade()
	nave.entrada.cancelar()
	nave.cancelar_pedidos()
	nave.simulacao_ativa = true
	nave.controle_permitido = true
	nave.velocidade = Vector2.ZERO
	nave.corpo_apoio = _checkpoint.corpo
	nave.posicao_relativa = _checkpoint.posicao_relativa
	nave.global_position = corpo.position + nave.posicao_relativa if not corpo.is_empty() else _checkpoint.posicao
	nave.global_rotation = _checkpoint.orientacao
	nave.origem_decolagem = ""
	nave.tempo_decolagem = -INF
	nave.combustivel = _checkpoint.combustivel
	nave.condicao = nave.Condicao.POUSADA if not corpo.is_empty() else nave.Condicao.PRONTA
	tempo_restante = _checkpoint.tempo
	temporizador_ativo = _checkpoint.temporizador_ativo
	estrelas_coletadas.clear()
	for id in _checkpoint.get("estrelas_coletadas", []):
		estrelas_coletadas[id] = true
	combustiveis_coletados.clear()
	for id in _checkpoint.get("combustiveis_coletados", []):
		combustiveis_coletados[id] = true
	nave.animation_player.play("default")
	nave.combustivel_alterado.emit(nave.combustivel)
	nave.condicao_alterada.emit()
	nave.atualizar_entrada()
	if ao_reabrir:
		pausar()
	elif nave.combustivel == 0:
		finalizar(false, "Sem combustível para decolar")
	else:
		estado_alterado.emit()
	reiniciada.emit()
	return true


func finalizar(venceu: bool, causa: String) -> void:
	if estado != Estado.JOGANDO:
		return
	estado = Estado.CONCLUIDA if venceu else Estado.PERDIDA
	motivo = causa
	explorando = false
	nave.parar()
	_limpar_proximidade()
	estado_alterado.emit()
	if venceu:
		concluida.emit(nivel.id)
	else:
		perdida.emit(causa)


func pausar() -> void:
	if estado != Estado.JOGANDO:
		return
	estado = Estado.PAUSADO
	explorando = false
	nave.controle_permitido = false
	nave.entrada.cancelar()
	nave.atualizar_entrada()
	get_tree().paused = true
	estado_alterado.emit()


func retomar() -> void:
	if estado != Estado.PAUSADO:
		return
	estado = Estado.JOGANDO
	nave.controle_permitido = true
	get_tree().paused = false
	nave.atualizar_entrada()
	estado_alterado.emit()


func alternar_exploracao() -> void:
	if estado != Estado.JOGANDO:
		return
	explorando = not explorando
	nave.controle_permitido = not explorando
	nave.entrada.cancelar()
	nave.atualizar_entrada()
	estado_alterado.emit()


func _atualizar_proximidade() -> void:
	var atuais: Dictionary = {}
	for corpo in nave.corpos:
		if nave.global_position.distance_to(corpo.position) <= corpo.proximity_radius + nave.raio:
			atuais[corpo.id] = corpo.type
			if not proximos.has(corpo.id):
				proximidade_alterada.emit(corpo.id, true)
	for id_corpo in proximos:
		if not atuais.has(id_corpo):
			proximidade_alterada.emit(id_corpo, false)
	proximos = atuais


func _limpar_proximidade() -> void:
	for id_corpo in proximos:
		proximidade_alterada.emit(id_corpo, false)
	proximos.clear()


func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_WM_WINDOW_FOCUS_OUT]:
		if is_instance_valid(nave) and is_inside_tree():
			pausar()
