extends SceneTree

const Progresso = preload("res://src/Campanha/progresso_persistente.gd")
var verificacoes := 0
var falhas := 0
var base := "res://.godot/progresso-teste-%d" % OS.get_process_id()
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


func novo(caminho: String) -> RefCounted:
	var progresso := Progresso.new()
	progresso.caminho = caminho
	progresso.carregar()
	progresso.configurar(itens)
	return progresso


func _executar() -> void:
	var progresso = novo(base)
	conferir(progresso.aviso.is_empty() and progresso.pode_abrir("a") and not progresso.pode_abrir("b"), "Primeira execução configura acesso sem save")
	conferir(not progresso.concluir("b", itens) and not FileAccess.file_exists(base), "Pedido bloqueado não grava progresso")
	conferir(progresso.concluir("a", itens) and progresso.aviso.is_empty(), "Vitória salva e libera próxima")
	var salvo := FileAccess.get_file_as_string(base)
	progresso = novo(base)
	conferir(progresso.estado("a") == "Concluída" and progresso.pode_abrir("b") and not progresso.pode_abrir("c"), "Nova instância restaura conclusão e desbloqueio")
	conferir(not progresso.concluir("a", itens) and FileAccess.get_file_as_string(base) == salvo, "Vitória duplicada não regrava nem duplica liberação")
	conferir(progresso.concluir("b", itens) and FileAccess.get_file_as_string(base + ".bak") == salvo, "Segunda gravação preserva último save válido")
	var segundo := FileAccess.get_file_as_string(base)
	progresso = novo(base)
	progresso.configurar([{"id": "c"}, {"id": "b"}, {"id": "a"}])
	conferir(progresso.estado("a") == "Concluída" and progresso.estado("b") == "Concluída", "Reordenação mantém progresso por IDs")
	conferir(progresso.concluir("c", itens) and progresso.liberadas.size() == 3, "Última fase não cria próximo ID")
	escrever(base + ".tmp", "{incompleto")
	progresso = novo(base)
	conferir(progresso.estado("c") == "Concluída", "Temporário interrompido não substitui save válido")
	escrever(base, "{interrompido")
	progresso = novo(base)
	conferir(progresso.estado("b") == "Concluída" and progresso.aviso.contains("recuperado"), "Save truncado recupera última cópia válida")
	conferir(progresso.concluir("c", itens) and novo(base).estado("c") == "Concluída", "Recuperação permite nova gravação válida")
	escrever(base, "{}")
	conferir(novo(base).aviso.contains("recuperado"), "Save sem versão é corrupção recuperável, não uma versão futura")
	var danificado: Dictionary = JSON.parse_string(segundo)
	danificado.concluidas.append("desconhecido")
	escrever(base, JSON.stringify(danificado))
	progresso = novo(base)
	conferir(not progresso.concluidas.has("desconhecido") and progresso.aviso.contains("recuperado"), "Checksum impede usar payload alterado")
	var futuro := "{\"schema_version\": 2}"
	escrever(base, futuro)
	progresso = novo(base)
	conferir(progresso.aviso.contains("incompatível") and not progresso.salvar() and FileAccess.get_file_as_string(base) == futuro, "Versão futura não é sobrescrita nem rebaixada pelo backup")
	escrever(base, "invalido")
	escrever(base + ".bak", "invalido")
	progresso = novo(base)
	conferir(progresso.pode_abrir("a") and not progresso.salvar() and FileAccess.get_file_as_string(base) == "invalido", "Ambos inválidos preservam arquivos e permitem sessão temporária")
	var falha := FalhaDisco.new()
	falha.caminho = base + "-falha"
	falha.configurar(itens)
	falha.concluir("a", itens)
	var anterior := FileAccess.get_file_as_string(falha.caminho)
	falha.falhar = true
	conferir(falha.concluir("b", itens) and falha.aviso.contains("Não foi possível salvar"), "Falha de disco sinaliza progresso apenas em memória")
	conferir(falha.salvamento_pendente() and not falha.aviso_para_partida().is_empty(), "Falha expõe aviso e opção de tentar novamente")
	conferir(FileAccess.get_file_as_string(falha.caminho) == anterior and novo(falha.caminho).estado("b") != "Concluída", "Falha preserva arquivo anterior")
	conferir(not falha.carregar() and falha.estado("b") == "Concluída", "Releitura não descarta vitória ainda não salva")
	falha.falhar = false
	conferir(falha.salvar() and novo(falha.caminho).estado("b") == "Concluída", "Nova tentativa grava vitórias pendentes")
	var permissao = novo(base + "/pasta-ausente/progresso.json")
	conferir(permissao.concluir("a", itens) and not permissao.aviso.is_empty(), "Destino indisponível não perde resultado em memória")
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.caminho_progresso = base + "-jogo"
	root.add_child(jogo)
	await process_frame
	conferir(jogo.iniciar_fase("teste_001"), "Fluxo aceita serviço persistente")
	jogo.mundo_atual.partida.finalizar(true, "Chegada")
	jogo.queue_free()
	await process_frame
	conferir(novo(base + "-jogo").estado("teste_001") == "Concluída", "Vitória real do controlador persiste ao fechar a cena")
	# Segunda execução de processo: não compartilha objeto ou estado em memória.
	var saida: Array = []
	var codigo := OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/verificar_progresso.gd", "--log-file", ProjectSettings.globalize_path("res://.godot/filho-progresso.log"), "--", base + "-jogo"], saida, true)
	conferir(codigo == 0 and "PROGRESSO_REABERTO" in "\n".join(saida), "Processo separado restaura progresso do arquivo")
	for prefixo in [base, base + "-falha", base + "-jogo"]:
		for sufixo in ["", ".bak", ".tmp", ".bak.tmp"]:
			if FileAccess.file_exists(prefixo + sufixo):
				DirAccess.remove_absolute(prefixo + sufixo)
	print("Persistência: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
