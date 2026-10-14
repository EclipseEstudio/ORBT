extends SceneTree

const Carregador = preload("res://src/Nivel/carregador_fase.gd")
const Fisica = preload("res://src/Nave/simulacao_voo.gd")
const CenaNave = preload("res://src/Nave/Nave.tscn")
const Partida = preload("res://src/ControladorJogo/partida.gd")

var verificacoes := 0
var falhas := 0
var vitorias := 0
var derrotas := 0
var confirmacoes := 0
var alertas: Array[String] = []


func _initialize() -> void:
	_executar.call_deferred()


func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)


func lancar(nave: Node, impulso: Vector2) -> void:
	nave.solicitar_impulso(nave._ultimo_pedido + 1, impulso)


func testar_dados(dados: Dictionary) -> void:
	conferir(Carregador.validar(dados).nivel != null, "Exemplo válido carrega")
	for campo in ["schema_version", "content_version", "id", "name", "order", "bounds", "flight_timeout", "physics", "ship", "start", "bodies", "goal"]:
		var copia: Dictionary = dados.duplicate(true)
		copia.erase(campo)
		var resultado := Carregador.validar(copia)
		conferir(resultado.nivel == null and not resultado.erros.is_empty(), "Campo obrigatório: " + campo)
	var copia: Dictionary = dados.duplicate(true)
	copia.erase("initial_fuel")
	conferir(Carregador.validar(copia).nivel.combustivel_inicial == 5, "Saldo padrão explícito")
	for valor in [0, -1, 1.5, "5", INF, NAN, true]:
		copia = dados.duplicate(true)
		copia.initial_fuel = valor
		conferir(Carregador.validar(copia).nivel == null, "Combustível inválido: %s" % valor)
	for valor in [0, 2, "1", true]:
		copia = dados.duplicate(true)
		copia.schema_version = valor
		conferir(Carregador.validar(copia).nivel == null, "Versão inválida: %s" % valor)
	copia = dados.duplicate(true)
	copia.bodies.append(copia.bodies[0].duplicate(true))
	conferir(Carregador.validar(copia).nivel == null, "IDs duplicados rejeitados")
	copia = dados.duplicate(true)
	copia.start.body_id = "ausente"
	conferir(Carregador.validar(copia).nivel == null, "Apoio inexistente rejeitado")
	copia = dados.duplicate(true)
	copia.start.body_id = "asteroide"
	conferir(Carregador.validar(copia).nivel == null, "Apoio perigoso rejeitado")
	copia = dados.duplicate(true)
	copia.bodies[1].position = copia.bodies[0].position
	conferir(Carregador.validar(copia).nivel == null, "Zonas sobrepostas rejeitadas")
	for campo in ["visual_radius", "collision_radius", "capture_radius", "danger_radius", "proximity_radius", "mass"]:
		copia = dados.duplicate(true)
		copia.bodies[0][campo] = -1
		conferir(Carregador.validar(copia).nivel == null, "Raio/massa negativos: " + campo)
	copia = dados.duplicate(true)
	copia.bodies[0].position = [NAN, 0]
	conferir(Carregador.validar(copia).nivel == null, "Coordenada não finita rejeitada")
	copia = dados.duplicate(true)
	copia.physics.softening = 0
	conferir(Carregador.validar(copia).nivel == null, "Suavização zero rejeitada")
	conferir(Carregador.carregar("res://inexistente.json").nivel == null, "Arquivo ausente gera diagnóstico")
	conferir(Carregador.carregar("res://project.godot").nivel == null, "Arquivo malformado gera diagnóstico")


func testar_fisica(nivel: NivelRes) -> void:
	var corpo: Dictionary = nivel.corpos[0].duplicate(true)
	corpo.position = Vector2.ZERO
	var a := Fisica.aceleracao(Vector2(100, 0), [corpo], nivel.fisica)
	conferir(a.x < 0 and a.y == 0 and a.is_finite(), "Gravidade aponta para fonte")
	conferir(Fisica.aceleracao(Vector2.ZERO, [corpo], nivel.fisica) == Vector2.ZERO, "Centro não é singular")
	var outro: Dictionary = corpo.duplicate(true)
	outro.position = Vector2(200, 0)
	conferir(Fisica.aceleracao(Vector2(100, 0), [corpo, outro], nivel.fisica).is_zero_approx(), "Fontes simétricas se cancelam")
	conferir(Fisica.aceleracao(Vector2(1000, 0), [corpo], nivel.fisica).length() < a.length(), "Atração diminui com distância")
	corpo.mass = 0
	conferir(Fisica.aceleracao(Vector2(100, 0), [corpo], nivel.fisica) == Vector2.ZERO, "Fonte sem massa não atrai")
	var vazio := {"gravity_constant": 0, "softening": 8}
	var limites := Rect2(-500, -500, 1000, 1000)
	var contato := Fisica.passo(Vector2(-100, 0), Vector2(12000, 0), 1.0 / 60, [corpo], vazio, limites, 8)
	conferir(not contato.contact.is_empty() and contato.position.x < 0, "Segmento rápido não atravessa corpo")
	var saida := Vector2(0, -corpo.collision_radius - 8)
	contato = Fisica.passo(saida, Vector2(0, -80), 1.0 / 60, [corpo], vazio, limites, 8, corpo.id)
	conferir(contato.contact.is_empty(), "Decolagem externa ignora só recaptura")
	contato = Fisica.passo(saida, Vector2(0, 80), 1.0 / 60, [corpo], vazio, limites, 8, corpo.id)
	conferir(not contato.contact.is_empty() and contato.position.is_equal_approx(saida), "Lançamento contra origem não atravessa")
	var terra: Dictionary = corpo.duplicate(true)
	terra.id = "terra"
	terra.type = "earth"
	var perigo: Dictionary = corpo.duplicate(true)
	perigo.type = "sun"
	perigo.danger_radius = corpo.capture_radius
	contato = Fisica.passo(Vector2(-100, 0), Vector2(12000, 0), 1.0 / 60, [terra, perigo], vazio, limites, 8)
	conferir(contato.contact.body.type == "sun", "Perigo vence empate com Terra")
	terra.position = Vector2(-60, 0)
	contato = Fisica.passo(Vector2(-150, 0), Vector2(18000, 0), 1.0 / 60, [perigo, terra], vazio, limites, 8)
	conferir(contato.contact.body.id == "terra", "Contato anterior vence independentemente da ordem")
	for direcao in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2(1, 1).normalized()]:
		contato = Fisica.passo(Vector2.ZERO, direcao * 100000, 1.0 / 60, [], vazio, limites, 8)
		conferir(contato.contact.kind == "bounds", "Saída pela borda: %s" % direcao)


func _executar() -> void:
	var dados: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://Recursos/Fases/teste_001.json"))
	testar_dados(dados)
	var nivel: NivelRes = Carregador.validar(dados).nivel
	if nivel == null:
		quit(1)
		return
	testar_fisica(nivel)
	var nave = CenaNave.instantiate()
	root.add_child(nave)
	var partida = Partida.new()
	root.add_child(partida)
	partida.set_physics_process(false)
	partida.concluida.connect(func(_id: String): vitorias += 1)
	partida.perdida.connect(func(_motivo: String): derrotas += 1)
	partida.proximidade_alterada.connect(func(id: String, ativo: bool): alertas.append("%s:%s" % [id, ativo]))
	nave.impulso_aplicado.connect(func(_id: int): confirmacoes += 1)
	partida.iniciar(nivel, nave)
	var inicio: Vector2 = nave.global_position
	conferir(nave.condicao == nave.Condicao.POUSADA and nave.corpo_apoio == "origem", "Início pousado no ID declarado")
	conferir(inicio.is_equal_approx(Vector2(90, 222)), "Nave inicia na superfície sem sobreposição")
	conferir(nave.combustivel == 5 and nave.velocidade == Vector2.ZERO, "Estado inicial limpo")
	partida.avancar(5)
	conferir(partida.tempo_restante == 30 and nave.global_position == inicio, "Observação pousada não conta tempo")
	conferir(nave.solicitar_impulso(1, Vector2(0, -80)), "Impulso válido aceito para próximo passo")
	conferir(not nave.solicitar_impulso(1, Vector2(0, -80)), "Mesmo ID rejeitado antes de aplicar")
	conferir(nave.combustivel == 5 and confirmacoes == 0, "Pedido não cobra antes da física")
	partida.avancar(1.0 / 60)
	conferir(nave.combustivel == 4 and confirmacoes == 1, "Uma aplicação e uma cobrança")
	conferir(not nave.solicitar_impulso(1, Vector2(0, -80)), "Reenvio após aplicar é rejeitado")
	conferir(nave.condicao == nave.Condicao.EM_VOO and nave.corpo_apoio.is_empty(), "Decolagem libera vínculo")
	partida.avancar(0.25)
	var anterior: Vector2 = nave.velocidade
	conferir(nave.solicitar_impulso(2, Vector2(10, 0)), "Correção aceita em voo")
	partida.avancar(0)
	conferir(nave.velocidade.is_equal_approx(anterior + Vector2(10, 0)), "Correção soma velocidade")
	conferir(nave.combustivel == 3 and partida.tempo_restante == 30, "Correção cobra e reinicia tempo")
	var corpos_guardados: Array = nave.corpos
	var velocidade_guardada: Vector2 = nave.velocidade
	nave.corpos = []
	nave.velocidade = Vector2(10, -20)
	nave.entrada.gesto.iniciar(0, Vector2(100, 100))
	nave.entrada.gesto.mover(0, Vector2(72.5, 100))
	var previa_correcao: PackedVector2Array = nave.prever_trajetoria()
	conferir(previa_correcao[1].distance_to(nave.global_position + Vector2(30, -20) * 0.05) < 0.001, "Prévia em voo inclui a velocidade existente")
	nave.entrada.cancelar()
	nave.corpos = corpos_guardados
	nave.velocidade = velocidade_guardada
	var posicao: Vector2 = nave.global_position
	var tempo: float = partida.tempo_restante
	nave.solicitar_impulso(3, Vector2(0, -20))
	partida.pausar()
	partida.avancar(10)
	conferir(nave.global_position == posicao and partida.tempo_restante == tempo, "Pausa suspende posição e tempo")
	partida.retomar()
	partida.avancar(0)
	conferir(nave.combustivel == 3, "Retomada não executa impulso cancelado")
	partida.alternar_exploracao()
	conferir(not nave.solicitar_impulso(4, Vector2(0, -20)), "Exploração rejeita lançamento")
	partida.avancar(0.1)
	conferir(partida.tempo_restante < tempo, "Explorar mantém tempo em voo")
	partida.alternar_exploracao()
	partida.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	conferir(partida.estado == partida.Estado.PAUSADO and paused, "Perda de foco pausa partida")
	partida.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	conferir(partida.estado == partida.Estado.PAUSADO, "Retorno ao foco exige retomar")
	partida.reiniciar()
	conferir(not paused and nave.combustivel == 5 and nave.global_position == inicio and nave.velocidade == Vector2.ZERO, "Reinício restaura tudo após pausa")
	conferir(partida.proximos.is_empty() and not partida.temporizador_ativo and not partida.explorando, "Reinício limpa alertas, modo e tempo")
	conferir(not nave.solicitar_impulso(1, Vector2(0, -80)), "Reinício rejeita pedido atrasado da tentativa anterior")
	lancar(nave, Vector2(0, 40))
	partida.avancar(1.0 / 60)
	conferir(nave.condicao == nave.Condicao.POUSADA and nave.global_position.is_equal_approx(inicio) and nave.combustivel == 4, "Contra origem pousa novamente e cobra")
	var saldo: int = nave.combustivel
	partida.avancar(2)
	conferir(nave.combustivel == saldo, "Pouso nunca recarrega")

	# Prévia: três segundos de voo, amostrados a cada três passos, sem tocar estado real.
	partida.reiniciar()
	nave.entrada.gesto.iniciar(0, Vector2(90, 100))
	nave.entrada.gesto.mover(0, Vector2(90, 180))
	var pontos: PackedVector2Array = nave.prever_trajetoria()
	for repeticao in range(5):
		conferir(nave.prever_trajetoria() == pontos, "Prévia repetível %d" % repeticao)
	conferir(nave.combustivel == 5 and nave.global_position == inicio and partida.tempo_restante == 30, "Prévia preserva estado real")
	nave.entrada.cancelar()
	lancar(nave, Vector2(0, -80))
	var indice := 1
	for passo in range(180):
		partida.avancar(1.0 / 60)
		if (passo % 3 == 2 or partida.estado != partida.Estado.JOGANDO) and indice < pontos.size():
			conferir(nave.global_position.distance_to(pontos[indice]) < 0.001, "Prévia corresponde ao voo no ponto %d" % indice)
			indice += 1
		if partida.estado != partida.Estado.JOGANDO:
			break
	conferir(partida.estado == partida.Estado.CONCLUIDA and vitorias == 1, "Rota de um impulso chega à Terra")
	posicao = nave.global_position
	partida.resolver_contato({"kind": "bounds"})
	partida.avancar(50)
	conferir(vitorias == 1 and derrotas == 0 and nave.global_position == posicao, "Vitória impede movimento e derrota tardia")
	var ultimo: Dictionary = dados.duplicate(true)
	ultimo.initial_fuel = 1
	partida.nivel = Carregador.validar(ultimo).nivel
	partida.reiniciar()
	lancar(nave, Vector2(0, -80))
	partida.avancar(1.0 / 60)
	conferir(nave.combustivel == 0 and nave.condicao == nave.Condicao.A_DERIVA and partida.estado == partida.Estado.JOGANDO, "Último impulso mantém deriva ativa")
	conferir(not nave.solicitar_impulso(2, Vector2(0, -80)), "Saldo zero bloqueia impulso")
	for passo in range(180):
		partida.avancar(1.0 / 60)
	conferir(vitorias == 2 and partida.estado == partida.Estado.CONCLUIDA, "Último combustível pode vencer")
	partida.reiniciar()
	lancar(nave, Vector2(0, 40))
	partida.avancar(1.0 / 60)
	conferir(partida.estado == partida.Estado.PERDIDA and partida.motivo == "Sem combustível para decolar", "Contato seguro sem saldo encerra com causa")
	partida.nivel = nivel
	partida.reiniciar()
	lancar(nave, Vector2(0, -80))
	partida.avancar(1.0 / 60)
	partida.tempo_restante = 0.001
	partida.avancar(1.0 / 60)
	conferir(partida.motivo == "Tempo esgotado", "Timeout encerra a tentativa")
	var eventos: int = derrotas
	partida.avancar(10)
	conferir(derrotas == eventos, "Derrota emitida uma vez")
	partida.reiniciar()
	alertas.clear()
	partida.avancar(0)
	partida.avancar(0)
	conferir(alertas.count("origem:true") == 1, "Proximidade não duplica entrada")
	nave.global_position = Vector2(300, 400)
	partida.avancar(0)
	conferir(alertas.count("origem:false") == 1, "Proximidade emite uma saída")
	partida.reiniciar()
	nave.corpos[0].proximity_radius = 100
	nave.corpos[1].proximity_radius = 100
	nave.global_position = Vector2(150, 190)
	partida.avancar(0)
	conferir(partida.proximos.has("origem") and partida.proximos.has("apoio"), "Áreas simultâneas preservam duas identidades")
	nave.global_position = Vector2(290, 140)
	partida.avancar(0)
	conferir(not partida.proximos.has("origem") and partida.proximos.has("apoio"), "Sair de uma área não limpa a outra")
	conferir(nivel.dados_autorais == dados, "Simulação não altera JSON autoral")
	for repeticao in range(5):
		partida.reiniciar()
		conferir(nave.combustivel == 5 and nave.global_position == inicio and nave.corpo_apoio == "origem", "Reinício repetido %d" % repeticao)
	partida.queue_free()
	nave.queue_free()
	await process_frame
	print("Partida: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
