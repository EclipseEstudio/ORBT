extends SceneTree

const Save = preload("res://src/Campanha/checkpoint_persistente.gd")
const Carregador = preload("res://src/Nivel/carregador_fase.gd")
var verificacoes := 0
var falhas := 0
var base := "res://.godot/checkpoint-teste-%d" % OS.get_process_id()

class FalhaDisco:
	extends "res://src/Campanha/checkpoint_persistente.gd"
	func _gravar(_arquivo: String, _texto: String) -> bool:
		return false

func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)

func _initialize() -> void:
	_executar.call_deferred()

func _executar() -> void:
	var argumentos := OS.get_cmdline_user_args()
	if argumentos.size() == 1:
		var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
		jogo.ativar_audio = false
		jogo.caminho_checkpoint = argumentos[0]
		jogo.caminho_progresso = argumentos[0] + "-progresso"
		jogo.caminho_preferencias = argumentos[0] + "-preferencias"
		root.add_child(jogo)
		await process_frame
		var botao: Button
		for item in jogo.interface_atual.get_node("Margem/Rolagem/VBoxContainer").get_children():
			if item is Button and item.text == "Continuar":
				botao = item
		conferir(botao != null, "menu oferece Continuar")
		if botao != null:
			botao.pressed.emit()
		var abriu: bool = is_instance_valid(jogo.mundo_atual) and jogo.mundo_atual.get("partida") != null
		conferir(abriu, "controlador reaberto continua checkpoint")
		if not abriu:
			quit(1)
			return
		var partida = jogo.mundo_atual.partida
		conferir(partida.estado == partida.Estado.PAUSADO and paused, "recuperação inicia pausada")
		conferir(partida.nave.corpo_apoio == "apoio" and partida.nave.combustivel == 3 and is_equal_approx(partida.tempo_restante, 12.5), "checkpoint e saldo corretos após novo processo")
		conferir(partida.nave.entrada.gesto.contato_ativo == -1 and partida.nave.velocidade == Vector2.ZERO, "gesto cancelado e velocidade zero")
		conferir(jogo.mundo_atual.camera.global_position.is_equal_approx(partida.nave.global_position) and jogo.mundo_atual.camera._abertura == 0.0, "recuperação pausada enquadra a nave no checkpoint")
		paused = false
		jogo.queue_free()
		print("CHECKPOINT_REABERTO")
		quit(1 if falhas else 0)
		return
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.ativar_audio = false
	jogo.caminho_checkpoint = base
	jogo.caminho_progresso = base + "-progresso"
	jogo.caminho_preferencias = base + "-preferencias"
	root.add_child(jogo)
	await process_frame
	conferir(jogo.iniciar_fase("teste_001"), "inicia fase no catálogo")
	var partida = jogo.mundo_atual.partida
	var apoio: Dictionary = partida.nivel.obter_corpo("apoio")
	partida.nave.combustivel = 3
	partida.tempo_restante = 12.5
	partida.temporizador_ativo = true
	partida.nave.global_position = apoio.position + Vector2.LEFT * 30
	partida.resolver_contato({"kind": "body", "body": apoio})
	var texto_atual := FileAccess.get_file_as_string(base)
	conferir(not texto_atual.is_empty() and FileAccess.file_exists(base + ".bak"), "pouso grava checkpoint e cópia anterior")
	jogo.queue_free()
	await process_frame
	var saida: Array = []
	var codigo := OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/test_checkpoint_persistente.gd", "--log-file", ProjectSettings.globalize_path("res://.godot/checkpoint-filho.log"), "--", base], saida, true)
	print("\n".join(saida))
	conferir(codigo == 0 and "CHECKPOINT_REABERTO" in "\n".join(saida), "processo separado restaura checkpoint")
	var salvo := Save.new()
	salvo.caminho = base
	conferir(salvo.carregar(), "carrega checkpoint íntegro")
	var nivel = Carregador.carregar("res://Recursos/Fases/teste_001.json").nivel
	conferir(not salvo.validar(nivel).is_empty(), "conteúdo compatível é validado")
	var alterado: NivelRes = nivel.duplicate(true)
	alterado.dados_autorais = nivel.dados_autorais.duplicate(true)
	alterado.dados_autorais.content_version += 1
	conferir(salvo.validar(alterado).is_empty() and salvo.bloqueado, "versão incompatível é bloqueada")
	for id in ["salto_curto", "na_diagonal", "escala_segura", "curva_suave"]:
		var fase_rebalanceada = Carregador.carregar("res://Recursos/Fases/" + id + ".json").nivel
		var antigo := Save.new()
		antigo.dados = {"fase": id, "content_version": 2}
		conferir(antigo.validar(fase_rebalanceada).is_empty() and antigo.bloqueado and not antigo.aviso.is_empty(), id + ": checkpoint anterior é recusado com diagnóstico")
	var falha := FalhaDisco.new()
	falha.caminho = base
	falha.carregar()
	var snapshot: Dictionary = falha.validar(nivel)
	conferir(not falha.salvar(snapshot, 2) and FileAccess.get_file_as_string(base) == texto_atual, "falha de gravação preserva arquivo anterior")
	var arquivo := FileAccess.open(base, FileAccess.WRITE)
	arquivo.store_string("interrompido")
	arquivo.close()
	var recuperado := Save.new()
	recuperado.caminho = base
	conferir(recuperado.carregar() and not recuperado.aviso.is_empty() and not recuperado.validar(nivel).is_empty(), "arquivo danificado recupera cópia anterior")
	conferir(recuperado.dados.corpo == "origem", "backup preserva checkpoint inicial anterior")
	var jogo_backup = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo_backup.ativar_audio = false
	jogo_backup.caminho_checkpoint = base
	jogo_backup.caminho_progresso = base + "-progresso"
	jogo_backup.caminho_preferencias = base + "-preferencias"
	root.add_child(jogo_backup)
	await process_frame
	var coluna = jogo_backup.interface_atual.get_node("Margem/Rolagem/VBoxContainer")
	var continuar_backup = coluna.get_node_or_null("Continuar")
	conferir(continuar_backup != null and continuar_backup.visible and coluna.has_node("AvisoCheckpoint"), "menu oferece Continuar e mostra aviso ao recuperar cópia válida")
	if continuar_backup != null and continuar_backup.visible:
		continuar_backup.pressed.emit()
		conferir(jogo_backup.mundo_atual.get("partida") != null and jogo_backup.mundo_atual.partida.estado == jogo_backup.mundo_atual.partida.Estado.PAUSADO and jogo_backup.mundo_atual.partida.nave.corpo_apoio == "origem", "cópia anterior continua pausada no checkpoint recuperado")
	else:
		conferir(false, "cópia anterior continua pausada no checkpoint recuperado")
	paused = false
	jogo_backup.queue_free()
	await process_frame
	conferir(recuperado.limpar() and not FileAccess.file_exists(base), "descarte explícito remove somente checkpoint")
	var invalido := FileAccess.open(base, FileAccess.WRITE)
	invalido.store_string("inválido")
	invalido.close()
	var sem_backup := Save.new()
	sem_backup.caminho = base
	conferir(not sem_backup.carregar() and sem_backup.bloqueado and not sem_backup.aviso.is_empty(), "checkpoint corrompido sem cópia informa e bloqueia escrita")
	conferir(not sem_backup.salvar(snapshot, 2) and FileAccess.get_file_as_string(base) == "inválido", "checkpoint inválido é preservado até descarte explícito")
	conferir(sem_backup.limpar(), "descartar checkpoint inválido permite reinício seguro")
	for prefixo in [base, base + "-progresso"]:
		for sufixo in ["", ".bak", ".tmp", ".bak.tmp"]:
			if FileAccess.file_exists(prefixo + sufixo):
				DirAccess.remove_absolute(prefixo + sufixo)
	print("Checkpoint persistente: ", verificacoes, " verificações, ", falhas, " falhas.")
	quit(1 if falhas else 0)
