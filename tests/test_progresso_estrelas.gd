extends SceneTree

const Progresso = preload("res://src/Campanha/progresso_persistente.gd")
const Sessao = preload("res://src/Campanha/progresso_sessao.gd")
var verificacoes := 0
var falhas := 0
var base := "res://.godot/estrelas-save-%d" % OS.get_process_id()
var itens: Array = [{"id": "a"}, {"id": "b"}, {"id": "c"}]

class FalhaDisco:
	extends "res://src/Campanha/progresso_persistente.gd"
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


func escrever(caminho: String, texto: String) -> void:
	var arquivo := FileAccess.open(caminho, FileAccess.WRITE)
	arquivo.store_string(texto)
	arquivo.close()


func ler(caminho: String) -> RefCounted:
	var progresso := Progresso.new()
	progresso.caminho = caminho
	progresso.carregar()
	progresso.configurar(itens)
	return progresso


func _executar() -> void:
	var sessao := Sessao.new()
	sessao.configurar(itens)
	conferir(not sessao.registrar_estrelas("a", 3) and sessao.total_estrelas() == 0, "Coleta sem vitória não credita estrelas")
	conferir(not sessao.concluir_com_estrelas("b", itens, 3) and sessao.total_estrelas() == 0, "Fase bloqueada não confirma coleta")
	conferir(sessao.concluir_com_estrelas("a", itens, 0) and sessao.pode_abrir("b") and sessao.total_estrelas() == 0, "Vitória sem coletáveis libera a próxima fase")
	conferir(sessao.concluir_com_estrelas("a", itens, 2) and sessao.melhor_estrelas("a") == 2, "Replay melhora coleta da fase já concluída")
	conferir(not sessao.concluir_com_estrelas("a", itens, 1) and sessao.melhor_estrelas("a") == 2, "Replay pior mantém recorde e não acumula")
	conferir(sessao.concluir_com_estrelas("a", itens, 3) and sessao.total_estrelas() == 3, "Melhora conta apenas diferença do recorde")
	conferir(sessao.concluir_com_estrelas("b", itens, 2) and sessao.total_estrelas() == 5, "Total soma recordes de fases distintas")
	conferir(not sessao.registrar_estrelas("b", 257) and not sessao.registrar_estrelas("desconhecida", 3) and not sessao.registrar_estrelas("b", -1), "Coleta inválida e ID desconhecido são rejeitados")
	conferir(sessao.registrar_estrelas("b", 4) and sessao.melhor_estrelas("b") == 4, "Fase criada no editor pode registrar mais de três estrelas")
	var progresso := Progresso.new()
	progresso.caminho = base
	progresso.configurar(itens)
	conferir(progresso.concluir_com_estrelas("a", itens, 2) and progresso.geracao == 1, "Vitória e coleta são salvas em uma única geração")
	conferir(ler(base).melhor_estrelas("a") == 2 and ler(base).pode_abrir("b"), "Reabertura restaura coleta e desbloqueio")
	var primeira := FileAccess.get_file_as_string(base)
	conferir(not progresso.concluir_com_estrelas("a", itens, 2) and FileAccess.get_file_as_string(base) == primeira, "Replay idêntico não regrava save")
	conferir(progresso.concluir_com_estrelas("a", itens, 3) and progresso.geracao == 2 and FileAccess.get_file_as_string(base + ".bak") == primeira, "Melhora salva novo recorde com backup anterior")
	escrever(base, "{interrompido")
	var recuperado = ler(base)
	conferir(recuperado.melhor_estrelas("a") == 2 and recuperado.aviso.contains("recuperado"), "Corrupção recupera recorde da última cópia válida")
	var legado := {"schema_version": 1, "geracao": 9, "concluidas": ["a"], "liberadas": ["a", "b"]}
	legado["checksum"] = JSON.stringify(legado, "", true).sha256_text()
	var texto_legado := JSON.stringify(legado)
	escrever(base + "-legado", texto_legado)
	var migrado = ler(base + "-legado")
	var dados_migrados: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(base + "-legado"))
	conferir(migrado.estado("a") == "Concluída" and migrado.pode_abrir("b") and migrado.total_estrelas() == 0 and dados_migrados.schema_version == 4, "Migração preserva progresso antigo e inicia coleta vazia")
	conferir(FileAccess.get_file_as_string(base + "-legado.bak") == texto_legado, "Migração guarda save antigo como backup")
	conferir(migrado.concluir_com_estrelas("a", itens, 1) and ler(base + "-legado").melhor_estrelas("a") == 1, "Fase migrada recebe estrela no replay")
	var falha := FalhaDisco.new()
	falha.caminho = base + "-falha"
	falha.configurar(itens)
	falha.concluir_com_estrelas("a", itens, 1)
	var antes_falha := FileAccess.get_file_as_string(falha.caminho)
	falha.falhar = true
	conferir(falha.concluir_com_estrelas("a", itens, 3) and falha.melhor_estrelas("a") == 3 and falha.salvamento_pendente(), "Falha de disco mantém melhora em memória e oferece retentativa")
	conferir(not falha.carregar() and FileAccess.get_file_as_string(falha.caminho) == antes_falha, "Releitura não descarta estrelas pendentes nem sobrescreve save")
	falha.falhar = false
	conferir(falha.salvar() and ler(falha.caminho).melhor_estrelas("a") == 3, "Retentativa persiste estrelas pendentes")
	var futuro := "{\"schema_version\":5}"
	escrever(base + "-futuro", futuro)
	var bloqueado = ler(base + "-futuro")
	bloqueado.concluir_com_estrelas("a", itens, 3)
	conferir(not bloqueado.salvar() and FileAccess.get_file_as_string(base + "-futuro") == futuro, "Versão futura permanece protegida de sobrescrita")
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	jogo.ativar_audio = false
	root.add_child(jogo)
	await process_frame
	jogo.mostrar_selecao()
	await process_frame
	var primeira_fase: String = jogo.get_node("GerenciadorDeNivel").itens[0].id
	conferir(jogo.iniciar_fase(primeira_fase), "Controlador abre fase para confirmar coleta somente na chegada")
	var partida = jogo.mundo_atual.partida
	partida.set_physics_process(false)
	partida.estrelas_coletadas = {"estrela_1": true, "estrela_2": true}
	partida.finalizar(false, "Colisão")
	conferir(jogo.progresso.total_estrelas() == 0 and jogo.progresso.estado(primeira_fase) != "Concluída", "Derrota real não confirma estrelas nem conclusão")
	partida.reiniciar()
	partida.estrelas_coletadas = {"estrela_1": true, "estrela_2": true}
	partida.finalizar(true, "Terra")
	conferir(jogo.progresso.melhor_estrelas(primeira_fase) == 2 and jogo.progresso.estado(primeira_fase) == "Concluída", "Chegada confirma conjunto da tentativa pelo controlador")
	partida.reiniciar()
	partida.estrelas_coletadas = {"estrela_3": true}
	partida.finalizar(true, "Terra novamente")
	conferir(jogo.progresso.melhor_estrelas(primeira_fase) == 2, "Chegada posterior com menos estrelas preserva recorde")
	jogo.queue_free()
	await process_frame
	for prefixo in [base, base + "-legado", base + "-falha", base + "-futuro"]:
		for sufixo in ["", ".bak", ".tmp", ".bak.tmp"]:
			if FileAccess.file_exists(prefixo + sufixo):
				DirAccess.remove_absolute(prefixo + sufixo)
	print("Progresso de estrelas: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
