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


func testar_expansao_catalogo() -> void:
	var original: Array = [{"id": "teste_001"}]
	for quantidade in [2, 6]:
		var caminho := base + "-expansao-%d" % quantidade
		var legado := Progresso.new()
		legado.caminho = caminho
		legado.configurar(original)
		conferir(legado.concluir("teste_001", original), "Catálogo antigo salva conclusão da única fase (%d)" % quantidade)
		var salvo := FileAccess.get_file_as_string(caminho)
		var expandido: Array = original.duplicate(true)
		for indice in range(1, quantidade):
			expandido.append({"id": "nova_%d" % indice})
		var progresso := Progresso.new()
		progresso.caminho = caminho
		conferir(progresso.carregar() and not progresso.pode_abrir("nova_1"), "Save legado carrega antes de reconciliar expansão (%d)" % quantidade)
		progresso.configurar(expandido)
		conferir(progresso.estado("teste_001") == "Concluída" and progresso.estado("nova_1") == "Disponível" and progresso.liberadas.size() == 2, "Expansão libera somente sucessora da fase concluída (%d)" % quantidade)
		conferir(expandido.slice(2).all(func(item: Dictionary): return progresso.estado(item.id) == "Bloqueada"), "Expansão mantém fases futuras bloqueadas (%d)" % quantidade)
		var reconciliado := FileAccess.get_file_as_string(caminho)
		var reaberto := Progresso.new()
		reaberto.caminho = caminho
		conferir(reaberto.carregar() and reaberto.estado("teste_001") == "Concluída" and reaberto.estado("nova_1") == "Disponível" and FileAccess.get_file_as_string(caminho + ".bak") == salvo, "Reconciliação persiste e preserva save anterior (%d)" % quantidade)
		reaberto.configurar(expandido)
		conferir(not reaberto.concluir("teste_001", expandido) and FileAccess.get_file_as_string(caminho) == reconciliado, "Reconfiguração e vitória repetida não regravam expansão (%d)" % quantidade)
		for sufixo in ["", ".bak", ".tmp", ".bak.tmp"]:
			if FileAccess.file_exists(caminho + sufixo):
				DirAccess.remove_absolute(caminho + sufixo)

	var caminho := base + "-expansao-falha"
	var legado := Progresso.new()
	legado.caminho = caminho
	legado.configurar(original)
	legado.concluir("teste_001", original)
	var salvo := FileAccess.get_file_as_string(caminho)
	var falha := FalhaDisco.new()
	falha.caminho = caminho
	falha.carregar()
	falha.falhar = true
	falha.configurar([{"id": "teste_001"}, {"id": "nova_1"}, {"id": "nova_2"}])
	conferir(falha.pode_abrir("nova_1") and not falha.pode_abrir("nova_2") and falha.salvamento_pendente(), "Falha ao salvar expansão preserva liberação em memória e sinaliza retentativa")
	conferir(FileAccess.get_file_as_string(caminho) == salvo and not falha.carregar(), "Falha na reconciliação preserva save e não descarta liberação pendente")
	falha.falhar = false
	var reaberto := Progresso.new()
	reaberto.caminho = caminho
	conferir(falha.salvar() and reaberto.carregar() and reaberto.pode_abrir("nova_1") and not reaberto.pode_abrir("nova_2"), "Retentativa persiste somente próxima fase após expansão")
	for sufixo in ["", ".bak", ".tmp", ".bak.tmp"]:
		if FileAccess.file_exists(caminho + sufixo):
			DirAccess.remove_absolute(caminho + sufixo)


func _executar() -> void:
	testar_expansao_catalogo()
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
	# Catálogo isolado de duas fases para testar o fluxo real antes/depois da reabertura.
	var pasta := "res://Recursos/Fases/.teste-persistencia-%d" % OS.get_process_id()
	DirAccess.make_dir_recursive_absolute(pasta)
	var exemplo: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://Recursos/Fases/teste_001.json"))
	var catalogo := {}
	for indice in range(2):
		var fase := exemplo.duplicate(true)
		fase.id = "a" if indice == 0 else "b"
		fase.name = "Persistência %d" % (indice + 1)
		fase.order = indice + 1
		fase.initial_fuel = 3 - indice
		var arquivo: String = pasta + "/" + fase.id + ".json"
		escrever(arquivo, JSON.stringify(fase))
		catalogo[fase.id] = arquivo
	var caminho_catalogo := base + "-catalogo.json"
	escrever(caminho_catalogo, JSON.stringify(catalogo))
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.caminho_progresso = base + "-jogo"
	jogo.caminho_checkpoint = base + "-checkpoint"
	jogo.caminho_preferencias = base + "-preferencias"
	jogo.get_node("GerenciadorDeNivel").caminho = caminho_catalogo
	root.add_child(jogo)
	await process_frame
	jogo.mostrar_selecao()
	conferir(jogo.progresso.estado("a") == "Disponível" and jogo.progresso.estado("b") == "Bloqueada", "Controlador persistente inicia somente com a primeira fase disponível")
	var gerenciador = jogo.get_node("GerenciadorDeNivel")
	var mundo_antes: Node = jogo.mundo_atual
	gerenciador.erros.append("sentinela")
	conferir(not jogo.iniciar_fase("b") and jogo.mundo_atual == mundo_antes and gerenciador.erros.has("sentinela") and not FileAccess.file_exists(jogo.caminho_progresso), "Bloqueio direto não chama carregador nem grava save no fluxo persistente")
	jogo.interface_atual.escolher("b")
	conferir(jogo.interface_atual.mensagem.text.contains("bloqueada") and jogo.mundo_atual == mundo_antes, "Seleção também impede abrir a fase bloqueada com serviço persistente")
	var abriu: bool = jogo.iniciar_fase("a")
	conferir(abriu, "Fluxo persistente abre a primeira fase pelo catálogo temporário")
	if abriu:
		var partida = jogo.mundo_atual.partida
		partida.set_physics_process(false)
		partida.finalizar(true, "Chegada")
		conferir(jogo.progresso.estado("a") == "Concluída" and jogo.progresso.pode_abrir("b") and FileAccess.file_exists(jogo.caminho_progresso), "Vitória do controlador salva a conclusão e libera a segunda fase")
		var primeira_vitoria := FileAccess.get_file_as_string(jogo.caminho_progresso)
		partida.reiniciar()
		partida.finalizar(true, "Chegada repetida")
		conferir(FileAccess.get_file_as_string(jogo.caminho_progresso) == primeira_vitoria and jogo.progresso.concluidas.size() == 1 and jogo.progresso.liberadas.size() == 2, "Segunda vitória real não regrava nem duplica a liberação")
	jogo.queue_free()
	await process_frame
	# Segunda execução de processo: não compartilha objeto ou estado em memória.
	var saida: Array = []
	var codigo := OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/verificar_progresso.gd", "--log-file", ProjectSettings.globalize_path("res://.godot/filho-progresso.log"), "--", base + "-jogo", caminho_catalogo], saida, true)
	print("\n".join(saida))
	conferir(codigo == 0 and "PROGRESSO_REABERTO" in "\n".join(saida), "Processo separado reabre controlador, conclui última fase e permite repetição")
	for arquivo in catalogo.values():
		DirAccess.remove_absolute(arquivo)
	DirAccess.remove_absolute(pasta)
	DirAccess.remove_absolute(caminho_catalogo)
	for prefixo in [base, base + "-falha", base + "-jogo", base + "-checkpoint"]:
		for sufixo in ["", ".bak", ".tmp", ".bak.tmp"]:
			if FileAccess.file_exists(prefixo + sufixo):
				DirAccess.remove_absolute(prefixo + sufixo)
	print("Persistência: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
