extends SceneTree

const Save = preload("res://src/Campanha/checkpoint_persistente.gd")
var verificacoes := 0
var falhas := 0
var base := ProjectSettings.globalize_path("res://.godot/retentar-checkpoint-%d" % OS.get_process_id())

class FalhaTemporaria:
	extends "res://src/Campanha/checkpoint_persistente.gd"
	var falhar := false
	func _gravar(arquivo: String, texto: String) -> bool:
		return false if falhar else super._gravar(arquivo, texto)

func _initialize() -> void:
	_executar.call_deferred()

func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)

func acomodar() -> void:
	for i in range(4):
		await process_frame

func _executar() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(base.get_base_dir()))
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.ativar_audio = false
	jogo.caminho_progresso = base + "-progresso"
	jogo.caminho_preferencias = base + "-preferencias"
	jogo.caminho_checkpoint = base
	jogo.checkpoint = FalhaTemporaria.new()
	root.add_child(jogo)
	await acomodar()
	conferir(jogo.iniciar_fase("teste_001"), "Inicia fase e grava checkpoint inicial")
	await acomodar()
	var partida = jogo.mundo_atual.partida
	partida.set_physics_process(false)
	var anterior := FileAccess.get_file_as_string(base)
	conferir(not anterior.is_empty() and not jogo.checkpoint.salvamento_pendente(), "Checkpoint inicial salvo sem pendência")
	jogo.checkpoint.falhar = true
	var apoio: Dictionary = partida.nivel.obter_corpo("apoio")
	partida.nave.combustivel = 3
	partida.tempo_restante = 12.5
	partida.temporizador_ativo = true
	partida.nave.global_position = apoio.position + Vector2.LEFT * 30
	partida.resolver_contato({"kind": "body", "body": apoio})
	conferir(jogo.checkpoint.salvamento_pendente() and FileAccess.get_file_as_string(base) == anterior, "Falha no pouso conserva pendência e arquivo anterior")
	conferir(not jogo.checkpoint.carregar() and jogo.checkpoint.salvamento_pendente(), "Recarregar não apaga pouso pendente")
	conferir(not jogo.continuar_checkpoint(), "Não restaura cópia antiga enquanto há pouso pendente")
	jogo.mostrar_menu()
	await acomodar()
	var coluna = jogo.interface_atual.get_node("Margem/Rolagem/VBoxContainer")
	conferir(coluna.has_node("TentarSalvarCheckpoint") and not coluna.has_node("Continuar"), "Menu oferece retentativa sem Continuar antigo")
	coluna.get_node("TentarSalvarCheckpoint").pressed.emit()
	await acomodar()
	conferir(jogo.checkpoint.salvamento_pendente() and jogo.interface_atual.has_node("Margem/Rolagem/VBoxContainer/TentarSalvarCheckpoint") and FileAccess.get_file_as_string(base) == anterior, "Nova falha mantém retentativa e arquivo válido")
	jogo.checkpoint.falhar = false
	jogo.interface_atual.get_node("Margem/Rolagem/VBoxContainer/TentarSalvarCheckpoint").pressed.emit()
	await acomodar()
	coluna = jogo.interface_atual.get_node("Margem/Rolagem/VBoxContainer")
	conferir(not jogo.checkpoint.salvamento_pendente() and coluna.has_node("Continuar") and not coluna.has_node("TentarSalvarCheckpoint"), "Sucesso oferece Continuar e remove retentativa")
	var salvo := Save.new()
	salvo.caminho = base
	conferir(salvo.carregar() and salvo.dados.corpo == "apoio" and salvo.dados.combustivel == 3 and is_equal_approx(salvo.dados.tempo, 12.5), "Nova instância lê último pouso gravado de verdade")
	conferir(FileAccess.get_file_as_string(base + ".bak") == anterior, "Retentativa mantém checkpoint anterior como cópia")
	conferir(not FileAccess.file_exists(base + "-progresso") and not FileAccess.file_exists(base + "-preferencias"), "Retentativa não grava progresso nem preferências")
	coluna.get_node("Continuar").pressed.emit()
	await acomodar()
	partida = jogo.mundo_atual.partida
	conferir(paused and partida.estado == partida.Estado.PAUSADO and partida.nave.corpo_apoio == "apoio" and partida.nave.combustivel == 3 and is_equal_approx(partida.tempo_restante, 12.5), "Continuar restaura pouso recuperado com partida pausada")
	var snapshot: Dictionary = partida._checkpoint.duplicate(true)
	jogo.checkpoint.falhar = true
	jogo.checkpoint.salvar(snapshot, int(partida.nivel.dados_autorais.content_version))
	jogo.checkpoint.bloqueado = true
	var texto := FileAccess.get_file_as_string(base)
	conferir(not jogo.checkpoint.carregar() and jogo.checkpoint.bloqueado, "Recarregar não remove bloqueio de checkpoint com gravação pendente")
	conferir(not jogo.checkpoint.salvamento_pendente() and not jogo.checkpoint.tentar_salvar() and FileAccess.get_file_as_string(base) == texto, "Bloqueio impede sobrescrever arquivo durante retentativa")
	jogo.checkpoint.bloqueado = false
	conferir(jogo.checkpoint.limpar() and not jogo.checkpoint.salvamento_pendente() and not jogo.checkpoint.tentar_salvar(), "Descarte elimina pendência e impede ressuscitar checkpoint")
	jogo.checkpoint.salvar(snapshot, int(partida.nivel.dados_autorais.content_version))
	partida.retomar()
	partida.finalizar(true, "Chegada à Terra")
	await acomodar()
	conferir(not jogo.checkpoint.salvamento_pendente() and not jogo.checkpoint.tentar_salvar() and not FileAccess.file_exists(base), "Vitória elimina pouso pendente sem permitir retentativa posterior")
	jogo.queue_free()
	paused = false
	await process_frame
	for prefixo in [base, base + "-progresso", base + "-preferencias"]:
		for sufixo in ["", ".bak", ".tmp", ".bak.tmp"]:
			if FileAccess.file_exists(prefixo + sufixo):
				DirAccess.remove_absolute(prefixo + sufixo)
	print("Retentativa de checkpoint: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas else 0)
