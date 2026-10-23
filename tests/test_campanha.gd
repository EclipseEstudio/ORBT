extends SceneTree

const Catalogo = preload("res://src/Campanha/catalogo.gd")
const Progresso = preload("res://src/Campanha/progresso_sessao.gd")
const Selecao = preload("res://src/Campanha/selecao_fases.gd")
var verificacoes := 0
var falhas := 0
var arquivos: Array[String] = []
var pasta := "res://Recursos/Fases/.teste-campanha-%d" % OS.get_process_id()


func _initialize() -> void:
	_executar.call_deferred()


func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)


func gravar(caminho: String, dados: Variant) -> void:
	var arquivo := FileAccess.open(caminho, FileAccess.WRITE)
	arquivo.store_string(JSON.stringify(dados))
	arquivo.close()
	if caminho not in arquivos:
		arquivos.append(caminho)


func _executar() -> void:
	DirAccess.make_dir_recursive_absolute(pasta)
	var exemplo: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://Recursos/Fases/teste_001.json"))
	var a := exemplo.duplicate(true)
	a.id = "a"
	a.name = "Primeira fase com um nome longo para conferir a quebra de linhas"
	a.order = 1
	a.initial_fuel = 3
	var b := exemplo.duplicate(true)
	b.id = "b"
	b.name = "Segunda fase"
	b.order = 2
	b.initial_fuel = 2
	var arquivo_a := pasta + "/a.json"
	var arquivo_b := pasta + "/b.json"
	gravar(arquivo_a, a)
	gravar(arquivo_b, b)
	var caminho := "res://.godot/test-catalogo.json"
	var catalogo := {"b": arquivo_b, "a": arquivo_a}
	gravar(caminho, catalogo)
	var resultado := Catalogo.carregar(caminho)
	conferir(resultado.erros.is_empty() and resultado.itens.size() == 2 and resultado.itens[0].id == "a", "Catálogo ordena por dados e não posição no JSON")
	var progresso := Progresso.new()
	progresso.configurar(resultado.itens)
	conferir(progresso.estado("a") == "Disponível" and progresso.estado("b") == "Bloqueada", "Primeira execução só libera primeira fase")
	conferir(not progresso.concluir("b", resultado.itens) and not progresso.concluir("desconhecida", resultado.itens), "Vitória não autoriza ID bloqueado ou desconhecido")
	conferir(progresso.concluir("a", resultado.itens) and progresso.pode_abrir("b"), "Vitória libera próxima por ID")
	conferir(not progresso.concluir("a", resultado.itens) and progresso.concluidas.size() == 1, "Vitória repetida é idempotente")
	conferir(progresso.concluir("b", resultado.itens) and progresso.liberadas.size() == 2, "Última fase não inventa próximo ID")
	conferir(Progresso.new().concluidas.is_empty(), "Progresso M2 não simula persistência entre sessões")
	a.order = 3
	a.name = "Nome alterado"
	gravar(arquivo_a, a)
	conferir(Catalogo.carregar(caminho).itens[0].id == "b" and progresso.estado("a") == "Concluída", "Reordenação e renomeação preservam identidade do progresso")
	a.order = 1
	a.name = "Primeira fase com um nome longo para conferir a quebra de linhas"
	gravar(arquivo_a, a)
	var tela := Selecao.new()
	tela.progresso = progresso
	tela.itens = resultado.itens
	root.add_child(tela)
	await process_frame
	conferir(tela.cartoes.get_child_count() == 2, "Tela abre sem mundo ou nave")
	tela.atualizar(resultado.itens, [])
	conferir(tela.cartoes.get_child_count() == 2, "Atualização não duplica cartões")
	var botao: Button = tela.cartoes.get_child(0).get_child(2)
	conferir(botao.text == "Repetir" and botao.custom_minimum_size.y == 48, "Concluída disponível para repetição com alvo de toque")
	tela.atualizar([], [])
	conferir(tela.mensagem.text.contains("Nenhuma fase"), "Catálogo vazio mantém navegação")
	tela.atualizar([], ["Catálogo inválido"])
	conferir(tela.mensagem.text.contains("inválido"), "Erro legível na seleção")
	tela.queue_free()
	await process_frame
	gravar(caminho, {"a": arquivo_a, "alias": arquivo_a})
	conferir(not Catalogo.carregar(caminho).erros.is_empty() and Catalogo.carregar(caminho).itens.is_empty(), "Referência duplicada rejeitada sem campanha parcial")
	gravar(caminho, {"a": "res://Recursos/Fases/../a.json"})
	conferir(not Catalogo.carregar(caminho).erros.is_empty(), "Caminho inválido rejeitado")
	gravar(caminho, {"a": pasta + "/ausente.json"})
	conferir(not Catalogo.carregar(caminho).erros.is_empty(), "Arquivo ausente diagnosticado")
	gravar(caminho, {})
	conferir(Catalogo.carregar(caminho).itens.is_empty() and Catalogo.carregar(caminho).erros.is_empty(), "Catálogo vazio válido")
	gravar(caminho, catalogo)
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	root.add_child(jogo)
	await process_frame
	var gerenciador = jogo.get_node("GerenciadorDeNivel")
	gerenciador.caminho = caminho
	jogo.progresso = Progresso.new()
	jogo.mostrar_selecao()
	conferir(gerenciador.itens.all(func(item: Dictionary): return item.keys().size() == 4 and not item.has("corpos")), "Listagem usa somente metadados de campanha")
	var mundo_antes: Node = jogo.mundo_atual
	gerenciador.erros.append("sentinela")
	conferir(not jogo.iniciar_fase("b") and jogo.mundo_atual == mundo_antes and gerenciador.erros.has("sentinela"), "Bloqueio direto impede até carregar JSON")
	jogo.interface_atual.escolher("b")
	conferir(jogo.interface_atual.mensagem.text.contains("bloqueada"), "Interface também rejeita fase bloqueada")
	jogo.interface_atual.escolher("a")
	jogo.interface_atual.escolher("a")
	await process_frame
	await process_frame
	conferir(jogo.mundo_atual.nivel_res.id == "a" and jogo.mundo.get_child_count() == 1, "Duplo toque abre uma instância do ID escolhido")
	var nivel = jogo.mundo_atual
	var nave = nivel.get_node("Nave")
	var partida = nivel.partida
	partida.set_physics_process(false)
	nivel.camera._process(2)
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	conferir(nave.combustivel == 3 and nave.entrada.gesto.contato_ativo == -1 and nave._pedidos.is_empty(), "Escolha não transfere gesto e usa saldo da fase")
	nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2(0, -80))
	for passo in range(180):
		partida.avancar(1.0 / 60)
	conferir(jogo.progresso.estado("a") == "Concluída" and jogo.progresso.pode_abrir("b"), "Vitória de produção atualiza progresso da sessão")
	jogo.mostrar_selecao()
	await process_frame
	conferir(not is_instance_valid(nivel) and jogo.interface_atual.cartoes.get_child_count() == 2, "Retorno libera mundo anterior e atualiza cartões")
	conferir(jogo.iniciar_fase("b") and not jogo.iniciar_fase("b"), "Chamadas diretas duplicadas não criam duas cenas")
	await process_frame
	conferir(jogo.mundo_atual.nivel_res.id == "b" and jogo.mundo_atual.get_node("Nave").combustivel == 2 and jogo.mundo_atual.partida.tempo_restante == 30, "Alternância começa nova fase com dados corretos")
	jogo.mundo_atual.partida.pausar()
	jogo.mostrar_selecao()
	conferir(not paused, "Retorno da pausa mantém seleção operável")
	await process_frame
	conferir(jogo.iniciar_fase("a"), "Concluída pode ser repetida")
	jogo.mundo_atual.partida.set_physics_process(false)
	await process_frame
	conferir(jogo.mundo_atual.get_node("Nave").combustivel == 3 and jogo.mundo_atual.partida.proximos.is_empty(), "Repetição restaura saldo e contatos")
	jogo.mostrar_selecao()
	await process_frame
	a.schema_version = 99
	gravar(arquivo_a, a)
	conferir(not jogo.iniciar_fase("a") and jogo.interface_atual is Control and jogo.erro_abertura.contains("schema_version"), "Erro físico usa carregador comum e preserva navegação")
	jogo.mostrar_menu()
	conferir(jogo.interface_atual.has_node("VBoxContainer/Button"), "Erro permite voltar ao menu")
	jogo.queue_free()
	await process_frame
	for arquivo in arquivos:
		DirAccess.remove_absolute(arquivo)
	DirAccess.remove_absolute(pasta)
	print("Campanha: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
