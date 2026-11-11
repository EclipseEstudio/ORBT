extends SceneTree
## Executado externamente contra o PCK, sem acessar recursos do checkout.

var verificacoes := 0
var falhas := 0


func _initialize() -> void:
	_executar.call_deferred()


func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)


func _executar() -> void:
	conferir(FileAccess.file_exists("res://Recursos/Niveis.json"), "Catálogo incluído no pacote")
	conferir(FileAccess.file_exists("res://Recursos/Fases/teste_001.json"), "JSON da fase incluído no pacote")
	var catalogo: Dictionary = load("res://src/Campanha/catalogo.gd").carregar("res://Recursos/Niveis.json")
	conferir(catalogo.erros.is_empty() and catalogo.itens.size() == 30, "Pacote inclui campanha de trinta fases")
	for item in catalogo.itens:
		var resultado: Dictionary = load("res://src/Nivel/carregador_fase.gd").carregar(item.arquivo)
		conferir(resultado.nivel != null and resultado.nivel.quantidade_estrelas("gold") == 3, item.id + ": fase e três estrelas válidas no pacote")
	conferir(not ResourceLoader.exists("res://tests/test_controles.gd"), "Testes excluídos da entrega")
	conferir(not ResourceLoader.exists("res://addons/orbt_editor/plugin.gd"), "Plugin de edição excluído da entrega")
	conferir(not ResourceLoader.exists("res://addons/orbt_editor/teste.tscn"), "Cena de teste do editor excluída da entrega")
	conferir(not DirAccess.dir_exists_absolute("res://docs/arte/fontes"), "Fontes de arte excluídas da entrega")
	for indice in range(1, 7):
		conferir(not ResourceLoader.exists("res://Recursos/Sprites/fogo%d.png" % indice), "Bitmap legado de propulsão %d excluído do pacote" % indice)
	conferir(not ResourceLoader.exists("res://Recursos/Sprites/nave1.png"), "Casco legado excluído do pacote")
	for nome in ["nave", "planeta", "satelite", "terra", "sol", "asteroide"]:
		conferir(ResourceLoader.exists("res://Recursos/Sprites/Identidade/" + nome + ".png"), "Sprite incluído: " + nome)
	conferir(ResourceLoader.exists("res://Recursos/Fontes/PressStart2P-Regular.ttf") and FileAccess.file_exists("res://Recursos/Fontes/OFL.txt"), "Fonte Press Start 2P e licença incluídas")
	conferir(ResourceLoader.exists("res://Recursos/Logos/wmdg.png"), "Logo WMDG incluída no pacote")
	conferir(ResourceLoader.exists("res://Recursos/Logos/godot.svg"), "Logo Godot incluída no pacote")
	conferir(FileAccess.file_exists("res://Recursos/Logos/GODOT-LICENSE.txt"), "Licença da logo Godot incluída no pacote")
	var referencias := DirAccess.get_files_at("res://Recursos/ModelosVisuais") if DirAccess.dir_exists_absolute("res://Recursos/ModelosVisuais") else PackedStringArray()
	conferir(Array(referencias).all(func(nome: String): return nome.begins_with("fundo_menu.png")), "Somente fundo de produção pode ser incluído com os modelos visuais")
	conferir(not DirAccess.dir_exists_absolute("res://tmp"), "Arquivos temporários excluídos da entrega")
	conferir(ProjectSettings.get_setting("display/window/handheld/orientation") == 1, "Orientação retrato incluída")
	var principal = load(ProjectSettings.get_setting("application/run/main_scene"))
	conferir(principal is PackedScene, "Cena principal resolvida no pacote")
	if principal == null:
		quit(1)
		return
	var jogo = principal.instantiate()
	jogo.ativar_audio = false
	var caminho_progresso := "user://progresso-exportacao-%d.json" % OS.get_process_id()
	jogo.caminho_progresso = caminho_progresso
	jogo.caminho_checkpoint = caminho_progresso + "-checkpoint"
	jogo.caminho_preferencias = caminho_progresso + "-preferencias"
	root.add_child(jogo)
	await process_frame
	conferir(jogo.iniciar_fase("teste_001"), "Fase carrega usando apenas dados exportados")
	var nivel = jogo.mundo_atual
	if nivel.nivel_res == null:
		quit(1)
		return
	var partida = nivel.partida
	var nave = nivel.get_node("Nave")
	partida.set_physics_process(false)
	nivel.camera._process(2.0)
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	conferir(nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2(0, -80)), "Impulso aceito no pacote")
	for passo in range(180):
		partida.avancar(1.0 / 60)
	conferir(partida.estado == partida.Estado.CONCLUIDA and nave.combustivel == 4, "Rota exportada chega à Terra com uma cobrança")
	conferir(partida.estrelas_coletadas.size() == 2 and jogo.progresso.melhor_estrelas("teste_001") == 2, "Rota econômica exportada confirma duas estrelas")
	jogo.mostrar_selecao()
	await process_frame
	conferir(jogo.interface_atual.quantidade_cartoes() == jogo.get_node("GerenciadorDeNivel").itens.size(), "Campanha lista todas as fases no pacote isolado")
	conferir(jogo.progresso.estado("teste_001") == "Concluída", "Vitória exportada atualiza estado da sessão")
	var restaurado = jogo.progresso.get_script().new()
	restaurado.caminho = caminho_progresso
	var carregou: bool = restaurado.carregar()
	restaurado.configurar(jogo.get_node("GerenciadorDeNivel").itens)
	conferir(carregou and restaurado.estado("teste_001") == "Concluída", "Pacote exportado grava e restaura progresso real")
	conferir(restaurado.melhor_estrelas("teste_001") == 2, "Estrelas confirmadas persistem no pacote exportado")
	conferir(jogo.iniciar_fase("teste_001") and jogo.mundo_atual.get_node("Nave").combustivel == 5, "Repetição exportada restaura combustível")
	jogo.queue_free()
	await process_frame
	for sufixo in ["", ".bak", ".tmp", ".bak.tmp"]:
		if FileAccess.file_exists(caminho_progresso + sufixo):
			DirAccess.remove_absolute(caminho_progresso + sufixo)
	print("Exportação: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
