extends SceneTree
## Coleta física, chegada, reinício e restauração de estrelas sem depender da campanha.

const Carregador = preload("res://src/Nivel/carregador_fase.gd")
const CenaNave = preload("res://src/Nave/Nave.tscn")
const Partida = preload("res://src/ControladorJogo/partida.gd")
const Checkpoint = preload("res://src/Campanha/checkpoint_persistente.gd")
var verificacoes := 0
var falhas := 0
var base := "res://.godot/estrelas-checkpoint-%d.json" % OS.get_process_id()


func _initialize() -> void:
	_executar.call_deferred()


func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)


func exemplo() -> Dictionary:
	return {
		"schema_version": 1, "content_version": 1, "id": "teste_estrelas", "name": "Estrelas", "order": 1,
		"bounds": {"position": [-500, -500], "size": [2000, 2000]}, "initial_fuel": 5, "flight_timeout": 30,
		"physics": {"gravity_constant": 0, "softening": 8},
		"ship": {"radius": 8, "mass": 1, "dead_zone": 10, "max_drag": 80, "max_impulse": 1000},
		"start": {"position": [0, 0]}, "bodies": [],
		"goal": {"id": "terra", "position": [200, 0], "mass": 0, "visual_radius": 14,
			"collision_radius": 14, "capture_radius": 16, "danger_radius": 0, "proximity_radius": 45},
		"stars": [{"id": "a", "position": [50, 0], "radius": 5},
			{"id": "b", "position": [170, 0], "radius": 5}, {"id": "depois", "position": [250, 0], "radius": 5}]
	}


func criar(dados: Dictionary) -> Node:
	var resultado := Carregador.validar(dados)
	conferir(resultado.nivel != null, "Fixture válida: " + str(resultado.erros))
	if resultado.nivel == null:
		return null
	var nave = CenaNave.instantiate()
	root.add_child(nave)
	var partida := Partida.new()
	root.add_child(partida)
	partida.set_physics_process(false)
	partida.iniciar(resultado.nivel, nave)
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	return partida


func remover(partida: Node) -> void:
	partida.nave.free()
	partida.free()


func _executar() -> void:
	var dados := exemplo()
	var legado := dados.duplicate(true)
	legado.erase("stars")
	conferir(Carregador.validar(legado).nivel.estrelas.is_empty(), "JSON antigo sem estrelas continua válido")
	var normalizado = Carregador.validar(dados).nivel
	conferir(normalizado.estrelas[0].position == Vector2(50, 0) and normalizado.dados_autorais.stars[0].position is Array, "Normalização preserva o JSON autoral")
	for valor in [null, "estrela", {}, [null], [{"id": "a", "position": [NAN, 0], "radius": 5}],
		[{"id": "a", "position": [0, 0], "radius": 0}], [{"id": "a", "position": [0, 0], "radius": INF}],
		[{"id": "a", "position": [1499, 0], "radius": 5}], [{"id": "a", "position": [200, 0], "radius": 5}],
		[{"id": "a", "position": [50, 0], "radius": 5}, {"id": "a", "position": [70, 0], "radius": 5}]]:
		var errado := dados.duplicate(true)
		errado.stars = valor
		conferir(Carregador.validar(errado).nivel == null, "Estrelas malformadas, repetidas ou inacessíveis são rejeitadas")
	var partida = criar(dados)
	if partida == null:
		quit(1)
		return
	var eventos: Array = []
	partida.estrela_coletada.connect(func(id: String): eventos.append(id))
	partida.concluida.connect(func(_id: String): eventos.append("terra:%d" % partida.estrelas_coletadas.size()))
	conferir(partida.nave.solicitar_impulso(1, Vector2(1000, 0)), "Impulso rápido é aceito")
	partida.avancar(1)
	conferir(partida.estado == partida.Estado.CONCLUIDA and partida.estrelas_coletadas.size() == 2, "Alta velocidade coleta estrelas atravessadas antes da Terra")
	conferir(eventos == ["a", "b", "terra:2"], "Coleta é temporal e está disponível quando a vitória é emitida")
	conferir(not partida.estrelas_coletadas.has("depois"), "Estrela além da Terra não é coletada no mesmo passo")
	conferir(partida.nave.combustivel == 4, "Coleta não gasta combustível adicional")
	partida.avancar(1)
	conferir(eventos.size() == 3, "Partida encerrada não coleta novamente")
	partida.reiniciar()
	conferir(partida.estrelas_coletadas.is_empty(), "Reiniciar restaura todas as estrelas")
	partida._coletar_trecho(Vector2.ZERO, Vector2(60, 0))
	partida._coletar_trecho(Vector2.ZERO, Vector2(60, 0))
	conferir(partida.estrelas_coletadas.size() == 1 and eventos.count("a") == 2, "Cada estrela emite uma coleta por tentativa")
	partida.pausar()
	partida._coletar_trecho(Vector2.ZERO, Vector2(180, 0))
	conferir(partida.estrelas_coletadas.size() == 1, "Pausa preserva e bloqueia novas coletas")
	partida.retomar()
	partida.alternar_exploracao()
	conferir(partida.estrelas_coletadas.size() == 1, "Explorar preserva a coleta da tentativa")
	partida.alternar_exploracao()
	partida._registrar_checkpoint()
	partida._coletar_trecho(Vector2(60, 0), Vector2(180, 0))
	partida.finalizar(false, "Teste")
	conferir(partida.estrelas_coletadas.size() == 2, "Tentativa perdida mantém somente o resultado local")
	conferir(partida.restaurar_checkpoint() and partida.estrelas_coletadas.keys() == ["a"], "Último pouso restaura coleta e devolve estrelas posteriores")
	var save := Checkpoint.new()
	save.caminho = base
	conferir(save.salvar(partida._checkpoint, 1), "Checkpoint persiste as estrelas")
	var reaberto := Checkpoint.new()
	reaberto.caminho = base
	conferir(reaberto.carregar() and reaberto.validar(partida.nivel).estrelas_coletadas == ["a"], "Checkpoint reaberto conserva IDs coletados")
	reaberto.dados.erase("estrelas_coletadas")
	conferir(reaberto.validar(partida.nivel).estrelas_coletadas.is_empty(), "Checkpoint antigo migra com coleta vazia")
	for ids in [["inexistente"], ["a", "a"], "a"]:
		reaberto.bloqueado = false
		reaberto.dados.estrelas_coletadas = ids
		conferir(reaberto.validar(partida.nivel).is_empty(), "Checkpoint rejeita estrelas inválidas ou repetidas")
	conferir(save.limpar(), "Limpeza remove arquivos do teste")
	remover(partida)

	var portal: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://Recursos/Fases/demo_portais.json"))
	portal.stars = [{"id": "entrada", "position": [25, 0], "radius": 4},
		{"id": "salto", "position": [120, 0], "radius": 4}, {"id": "saida", "position": [245, 0], "radius": 4}]
	var invalido := portal.duplicate(true)
	invalido.stars = [{"id": "sobre_saida", "position": [220.01, 0], "radius": 4}]
	conferir(Carregador.validar(invalido).nivel == null, "Estrela sobre saída de portal é rejeitada")
	partida = criar(portal)
	if partida == null:
		quit(1)
		return
	partida.nave.solicitar_impulso(1, Vector2(80, 0))
	partida.avancar(1)
	conferir(partida.nave.global_position.x > 200 and partida.estrelas_coletadas.keys() == ["entrada"], "Entrada coleta sem atravessar a linha imaginária do teleporte")
	partida.avancar(1)
	conferir(partida.estado == partida.Estado.CONCLUIDA and partida.estrelas_coletadas.has("saida") and not partida.estrelas_coletadas.has("salto"), "Trajeto real após o portal coleta normalmente")
	remover(partida)

	var sem_coleta := exemplo()
	sem_coleta.stars = [{"id": "opcional", "position": [50, 100], "radius": 5}]
	partida = criar(sem_coleta)
	partida.nave.solicitar_impulso(1, Vector2(1000, 0))
	partida.avancar(1)
	conferir(partida.estado == partida.Estado.CONCLUIDA and partida.estrelas_coletadas.is_empty(), "Chegar à Terra sem estrelas continua vencendo")
	remover(partida)

	var com_pouso := exemplo()
	com_pouso.bodies = [{"id": "apoio", "type": "satellite", "position": [100, 0], "mass": 0,
		"visual_radius": 12, "collision_radius": 12, "capture_radius": 16, "danger_radius": 0, "proximity_radius": 40}]
	partida = criar(com_pouso)
	partida.nave.solicitar_impulso(1, Vector2(1000, 0))
	partida.avancar(1)
	conferir(partida.nave.condicao == partida.nave.Condicao.POUSADA and partida._checkpoint.corpo == "apoio", "Voo real pousa e registra checkpoint")
	conferir(partida._checkpoint.estrelas_coletadas == ["a"] and partida.estrelas_coletadas.keys() == ["a"], "Estrela antes do contato entra no checkpoint; estrelas depois do pouso ficam disponíveis")
	partida.finalizar(false, "Teste após pouso")
	conferir(partida.restaurar_checkpoint() and partida.estrelas_coletadas.keys() == ["a"], "Restauração após pouso real mantém exatamente a coleta desse pouso")
	remover(partida)
	print("Estrelas: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas else 0)
