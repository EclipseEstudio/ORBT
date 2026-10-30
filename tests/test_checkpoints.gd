extends SceneTree

const Carregador = preload("res://src/Nivel/carregador_fase.gd")
const CenaNave = preload("res://src/Nave/Nave.tscn")
const Partida = preload("res://src/ControladorJogo/partida.gd")
var verificacoes := 0
var falhas := 0

func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)

func _initialize() -> void:
	_executar.call_deferred()

func _executar() -> void:
	var nivel = Carregador.carregar("res://Recursos/Fases/teste_001.json").nivel
	var dados_antes: Dictionary = nivel.dados_autorais.duplicate(true)
	var nave = CenaNave.instantiate()
	root.add_child(nave)
	var partida = Partida.new()
	root.add_child(partida)
	partida.set_physics_process(false)
	partida.iniciar(nivel, nave)
	var pos_inicial: Vector2 = nave.global_position
	var apoio: Dictionary = nivel.obter_corpo("apoio")
	conferir(partida._checkpoint.fase == nivel.id and partida._checkpoint.corpo == "origem", "checkpoint inicial")
	nave.combustivel = 3
	partida.tempo_restante = 12.5
	partida.temporizador_ativo = true
	nave.global_position = apoio.position + Vector2.LEFT * 30
	partida.resolver_contato({"kind": "body", "body": apoio})
	var pos_pouso: Vector2 = nave.global_position
	var orientacao: float = nave.global_rotation
	conferir(partida._checkpoint.corpo == "apoio" and partida._checkpoint.combustivel == 3, "pouso substitui checkpoint")
	partida.finalizar(false, "teste")
	nave.global_position = Vector2.ZERO
	nave.combustivel = 1
	conferir(partida.restaurar_checkpoint(), "restauração disponível após derrota")
	conferir(nave.global_position.is_equal_approx(pos_pouso) and nave.posicao_relativa.is_equal_approx(pos_pouso - apoio.position), "posição relativa restaurada")
	conferir(is_equal_approx(nave.global_rotation, orientacao) and nave.corpo_apoio == "apoio", "orientação e apoio restaurados")
	conferir(nave.combustivel == 3 and is_equal_approx(partida.tempo_restante, 12.5) and partida.temporizador_ativo, "saldo e tempo restaurados")
	conferir(nave.velocidade == Vector2.ZERO and nave.condicao == nave.Condicao.POUSADA and nave.simulacao_ativa, "nave volta pousada")
	nave.entrada.gesto.iniciar(5, Vector2(10, 10))
	nave.solicitar_impulso(100, Vector2(10, 0))
	partida.pausar()
	conferir(partida.restaurar_checkpoint(), "restaura durante pausa")
	partida.avancar(1.0 / 60)
	conferir(nave.combustivel == 3 and nave.entrada.gesto.contato_ativo == -1 and nave.velocidade == Vector2.ZERO, "gesto e pedido pendentes não são reaplicados")
	partida.reiniciar()
	conferir(nave.global_position.is_equal_approx(pos_inicial) and nave.combustivel == nivel.combustivel_inicial and partida.tempo_restante == nivel.tempo_voo, "reiniciar volta ao início")
	conferir(partida._checkpoint.corpo == "origem", "reinício substitui checkpoint")
	nave.combustivel = 0
	nave.global_position = apoio.position + Vector2.LEFT * 30
	partida.resolver_contato({"kind": "body", "body": apoio})
	conferir(partida.estado == partida.Estado.PERDIDA and partida._checkpoint.combustivel == 0, "pouso sem combustível é registrado e perde")
	conferir(partida.restaurar_checkpoint() and partida.estado == partida.Estado.PERDIDA and nave.combustivel == 0, "restaurar saldo zero mantém derrota")
	partida.reiniciar()
	conferir(partida.estado == partida.Estado.JOGANDO and nave.combustivel == nivel.combustivel_inicial, "reinício recupera de checkpoint sem saldo")
	conferir(nivel.dados_autorais == dados_antes, "dados autorais preservados")
	var livre_dados: Dictionary = dados_antes.duplicate(true)
	livre_dados.start = {"position": [90, 400]}
	var livre = Carregador.validar(livre_dados).nivel
	partida.nivel = livre
	partida.reiniciar()
	partida.finalizar(false, "teste")
	conferir(partida.restaurar_checkpoint() and nave.condicao == nave.Condicao.PRONTA and nave.global_position == Vector2(90, 400) and nave.corpo_apoio.is_empty(), "restaura início livre")
	partida.queue_free()
	nave.queue_free()
	print("Checkpoints: ", verificacoes, " verificações, ", falhas, " falhas.")
	quit(1 if falhas else 0)
