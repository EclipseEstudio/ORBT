extends SceneTree
const Carregador = preload("res://src/Nivel/carregador_fase.gd")
const Catalogo = preload("res://src/Campanha/catalogo.gd")
const Sessao = preload("res://src/Campanha/progresso_sessao.gd")
const Disco = preload("res://src/Campanha/progresso_persistente.gd")
const Checkpoint = preload("res://src/Campanha/checkpoint_persistente.gd")
const Fisica = preload("res://src/Nave/simulacao_voo.gd")
const Ceu = preload("res://src/Visual/ceu_parallax.gd")
var verificacoes := 0
var falhas := 0

func _initialize() -> void:
	executar.call_deferred()

func conferir(ok: bool, mensagem: String) -> bool:
	verificacoes += 1
	if not ok:
		falhas += 1
		push_error(mensagem)
	return ok

func executar() -> void:
	var itens: Array = []
	for i in range(31):
		itens.append({"id": str(i), "estrelas": 3})
	var progresso := Sessao.new()
	progresso.configurar(itens)
	for i in range(10):
		progresso.concluir_com_coletas(str(i), itens, 2, 1)
	conferir(progresso.liberadas.has("10") and not progresso.pode_abrir("10"), "Vitória libera próxima; portão impede entrar sem 80%")
	conferir(not progresso.pode_abrir("11") and progresso.total_estrelas() == 20, "Azuis não contam no bloqueio nem pulam sequência")
	progresso.concluidas["12"] = true
	progresso.liberadas["12"] = true
	progresso.concluidas["13"] = true
	progresso.liberadas["13"] = true
	progresso.configurar(itens)
	conferir(not progresso.pode_abrir("12") and not progresso.pode_abrir("13") and progresso.estado("12") == "Bloqueada", "Conclusões antigas não ultrapassam o portão de estrelas")
	progresso.concluidas.erase("12")
	progresso.concluidas.erase("13")
	for i in range(3):
		progresso.registrar_estrelas(str(i), 3)
	conferir(not progresso.pode_abrir("10"), "23 de 30 não atingem 80%")
	progresso.registrar_estrelas("3", 3)
	conferir(progresso.pode_abrir("10") and not progresso.pode_abrir("11"), "24 de 30 abrem somente a próxima fase")
	conferir(not progresso.pode_abrir("13"), "Liberação antiga não pula fase anterior após abrir o portão")
	for i in range(10, 20):
		progresso.concluir_com_coletas(str(i), itens, 2, 1)
	conferir(not progresso.pode_abrir("20"), "Novo portão avalia o bloco anterior, sem reutilizar douradas do primeiro")
	for i in range(10, 14):
		progresso.registrar_estrelas(str(i), 3)
	conferir(progresso.pode_abrir("20"), "Segundo conjunto exige outras 24 douradas")
	var salvo := Disco.new()
	salvo.caminho = "res://.godot/revisao-save-%d.json" % OS.get_process_id()
	salvo.configurar(itens)
	conferir(salvo.concluir_com_coletas("0", itens, 3, 1) and salvo.geracao == 1, "Douradas e azuis salvas atomicamente na mesma geração")
	var reaberto := Disco.new()
	reaberto.caminho = salvo.caminho
	conferir(reaberto.carregar() and reaberto.melhor_estrelas("0") == 3 and reaberto.melhor_azuis("0") == 1, "Save restaura os dois tipos")
	var legado := {"schema_version": 2, "geracao": 1, "concluidas": ["0"], "liberadas": ["0", "1"], "melhores_estrelas": {"0": 2}}
	legado.checksum = JSON.stringify(legado, "", true).sha256_text()
	var fluxo := FileAccess.open(salvo.caminho + "-legado", FileAccess.WRITE)
	fluxo.store_string(JSON.stringify(legado))
	fluxo.close()
	var migrado := Disco.new()
	migrado.caminho = salvo.caminho + "-legado"
	conferir(migrado.carregar() and migrado.melhor_estrelas("0") == 2 and migrado.melhor_azuis("0") == 0, "Migração do esquema 2 mantém douradas, sem inventar azuis")
	var catalogo := Catalogo.carregar("res://Recursos/Niveis.json")
	for item in catalogo.itens:
		var resultado := Carregador.carregar(item.arquivo)
		if conferir(resultado.nivel != null, item.id + ": fase válida"):
			var recurso: NivelRes = resultado.nivel
			conferir(recurso.obter_corpo(recurso.inicio.body_id).type == "station", item.id + ": começa em estação")
			conferir(not recurso.corpos.any(func(corpo: Dictionary): return corpo.type == "satellite"), item.id + ": sem satélites")
			conferir(recurso.quantidade_estrelas() == 3 and item.estrelas == 3, item.id + ": classificação só dourada")
	var dados: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://Recursos/Fases/segundo_impulso.json"))
	for tanques in [[{"id":"a", "position":[0,0], "radius":7, "amount":0}], [{"id":"a", "position":[0,0], "radius":7, "amount":1.5}], [{"id":"a", "position":[9999,0], "radius":7, "amount":1}], [dados.fuel_pickups[0], dados.fuel_pickups[0]]]:
		var invalido := dados.duplicate(true)
		invalido.fuel_pickups = tanques
		conferir(Carregador.validar(invalido).nivel == null, "Tanques inválidos rejeitados")
	var mundo = load("res://src/Nivel/Nivel.tscn").instantiate()
	mundo.nivel_res = Carregador.validar(dados).nivel
	root.add_child(mundo)
	var partida = mundo.partida
	partida.set_physics_process(false)
	var nave = partida.nave
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	var tanque: Dictionary = partida.nivel.combustiveis[0]
	var antes: int = nave.combustivel
	partida._coletar_trecho(tanque.position - Vector2(40, 0), tanque.position + Vector2(40, 0))
	conferir(nave.combustivel == antes + tanque.amount, "Varredura recolhe tanque atravessado entre quadros")
	partida._coletar_trecho(tanque.position, tanque.position)
	conferir(nave.combustivel == antes + tanque.amount, "Tanque não duplica combustível")
	partida._registrar_checkpoint()
	var cp := Checkpoint.new()
	cp.caminho = salvo.caminho + "-checkpoint"
	conferir(cp.salvar(partida._checkpoint, int(dados.content_version)) and not cp.validar(partida.nivel).is_empty(), "Checkpoint aceita combustível extra e registra tanque coletado")
	partida.pausar()
	conferir(partida.restaurar_checkpoint() and partida.combustiveis_coletados.has(tanque.id), "Retomada preserva coleta do tanque")
	partida.reiniciar()
	conferir(partida.combustiveis_coletados.is_empty() and nave.combustivel == antes, "Reinício restaura tanques e saldo autoral")
	nave.condicao = nave.Condicao.A_DERIVA
	nave.combustivel = 0
	partida._coletar_trecho(tanque.position, tanque.position)
	conferir(nave.combustivel == tanque.amount and nave.condicao == nave.Condicao.EM_VOO and nave.entrada.habilitada, "Tanque permite voltar a controlar nave sem combustível")
	partida.reiniciar()
	nave.entrada.gesto.iniciar(42, Vector2(90, 140))
	conferir(is_equal_approx(partida.escala_tempo(), 0.25), "Mirar reduz tempo a um quarto")
	nave.entrada.cancelar()
	nave.condicao = nave.Condicao.EM_VOO
	var terra: Dictionary = partida.nivel.obter_corpo("terra")
	nave.global_position = terra.position + Vector2(terra.capture_radius + nave.raio + 1, 0)
	conferir(is_equal_approx(partida.escala_tempo(), 1), "Aproximar a Terra não desacelera simulação")
	nave.global_position = Vector2(680, 580)
	conferir(is_equal_approx(partida.escala_tempo(), 1), "Longe dos corpos o tempo volta ao normal")
	var externa: Vector2 = terra.position + Vector2(terra.gravity_radius + 1, 0)
	var interna: Vector2 = terra.position + Vector2(terra.capture_radius + nave.raio + 1, 0)
	conferir(Fisica.aceleracao(externa, [terra], partida.nivel.fisica).is_zero_approx(), "Gravidade da Terra tem alcance limitado")
	conferir(Fisica.aceleracao(interna, [terra], partida.nivel.fisica).x < -100, "Gravidade forte perto da Terra atrai rasantes")
	var ceu := Ceu.new()
	ceu.atualizar_sensor(Vector3(0, 1, 0), 0.1)
	conferir(ceu.deslocamento.x < 0 and ceu.inclinacao.length() <= 0.7, "Giroscópio move camadas com amplitude limitada")
	ceu.free()
	mundo.free()
	for prefixo in [salvo.caminho, salvo.caminho + "-legado", cp.caminho]:
		for sufixo in ["", ".bak", ".tmp", ".bak.tmp"]:
			if FileAccess.file_exists(prefixo + sufixo):
				DirAccess.remove_absolute(prefixo + sufixo)
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	jogo.ativar_audio = false
	root.add_child(jogo)
	await process_frame
	jogo.iniciar_fase("teste_001")
	var hud = jogo.mundo_atual.find_child("DialogoPausa", true, false).get_parent()
	jogo.mundo_atual.partida.pausar()
	hud._dialogo_pausa.menu.emit()
	await process_frame
	await process_frame
	conferir(jogo.interface_atual.get("cartoes") != null and not paused, "Voltar da pausa abre menu de fases")
	conferir(jogo.interface_atual.find_child("Checkpoint", true, false) == null, "Seleção não exibe Último pouso salvo nem ação de salvar pouso")
	for i in range(5):
		await process_frame
	var selecao = jogo.interface_atual
	var primeiro_cartao = selecao.obter_cartao(0)
	conferir(selecao._colecao.modulate.is_equal_approx(Color("57b9ff")) and selecao.find_child("Divisor11", true, false) != null, "Cabeçalho usa contador azul e a décima fase cria divisor com meta")
	conferir(selecao.find_child("Divisor01", true, false) != null and selecao.find_child("Meta11", true, false) != null and selecao.find_child("Cadeado11", true, false) != null, "Níveis têm divisores e o grupo bloqueado tem meta e cadeado")
	conferir(primeiro_cartao.find_child("Azuis", true, false) == null and not selecao.rolagem.get_h_scroll_bar().visible, "Cartões não revelam estrelas azuis secretas")
	jogo.free()
	await process_frame
	print("Revisão de jogabilidade: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
