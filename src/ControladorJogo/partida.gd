extends Node

signal estado_alterado
signal concluida(id_fase: String)
signal perdida(motivo: String)
signal proximidade_alterada(id_corpo: String, proximo: bool)
signal reiniciada
signal selecao_solicitada
var campanha_permitida := false

enum Estado { JOGANDO, PAUSADO, PERDIDA, CONCLUIDA }
var estado := Estado.JOGANDO
var motivo := ""
var tempo_restante := 0.0
var temporizador_ativo := false
var explorando := false
var proximos: Dictionary = {}
var nivel: NivelRes
var nave: Node2D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func iniciar(dados: NivelRes, nave_atual: Node2D) -> void:
	nivel = dados
	nave = nave_atual
	nave.simulacao_automatica = false
	nave.impulso_aplicado.connect(_ao_impulso)
	nave.contato_detectado.connect(resolver_contato)
	reiniciar()


func reiniciar() -> void:
	get_tree().paused = false
	estado = Estado.JOGANDO
	motivo = ""
	explorando = false
	tempo_restante = nivel.tempo_voo
	temporizador_ativo = false
	_limpar_proximidade()
	nave.configurar(nivel)
	estado_alterado.emit()
	reiniciada.emit()


func _physics_process(delta: float) -> void:
	avancar(delta)


func avancar(delta: float) -> void:
	if estado != Estado.JOGANDO or not is_instance_valid(nave) or get_tree().paused:
		return
	nave.aplicar_pedidos()
	var passo := minf(delta, tempo_restante) if temporizador_ativo else delta
	nave.avancar(passo)
	if estado != Estado.JOGANDO:
		return
	_atualizar_proximidade()
	if temporizador_ativo and nave.condicao != nave.Condicao.POUSADA:
		tempo_restante = maxf(0, tempo_restante - passo)
		if tempo_restante <= 0:
			finalizar(false, "Tempo esgotado")


func _ao_impulso(_gesto_id: int) -> void:
	temporizador_ativo = true
	tempo_restante = nivel.tempo_voo


func resolver_contato(contato: Dictionary) -> void:
	if estado != Estado.JOGANDO:
		return
	if contato.kind == "bounds":
		finalizar(false, "Fora dos limites")
		return
	var corpo: Dictionary = contato.body
	match corpo.type:
		"sun", "asteroid":
			finalizar(false, "Colisão com perigo")
		"earth":
			finalizar(true, "Você chegou à Terra!")
		_:
			nave.pousar(corpo)
			if nave.combustivel == 0:
				finalizar(false, "Sem combustível para decolar")


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
