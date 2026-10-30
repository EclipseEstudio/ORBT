extends SceneTree

const Area = preload("res://src/Visual/area_segura_menu.gd")
const Cenarios = preload("res://tests/test_campanha_layout.gd")

func _initialize() -> void:
	_capturar.call_deferred()

func salvar(nome: String) -> void:
	for i in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/campanha-" + nome + ".png")

func _capturar() -> void:
	root.content_scale_size = Vector2i(180, 240)
	root.size = Vector2i(360, 480)
	var itens: Array = load("res://src/Campanha/catalogo.gd").carregar("res://Recursos/Niveis.json").itens.duplicate(true)
	itens[0].nome = "Nome de fase muito longo para testar quebra de linha"
	var progresso = Cenarios.ProgressoAviso.new()
	progresso.configurar(itens)
	for item in itens.slice(0, 9):
		progresso.concluir(item.id, itens)
	var tela = load("res://src/Campanha/selecao_fases.gd").new()
	tela.itens = itens
	tela.progresso = progresso
	tela.erros = ["Não foi possível abrir uma das fases. Atualize a lista para tentar novamente."]
	root.add_child(tela)
	Area.aplicar(tela._margem, 0, root.get_screen_transform() * Rect2(8, 16, 164, 208))
	await salvar("avisos")
	tela.rolagem.ensure_control_visible(tela.cartoes.get_child(9).get_child(2))
	await salvar("decima-fase")
	tela.falhou("Não foi possível abrir a fase. Tente novamente.")
	await salvar("erro-abertura")
	progresso.pendente = false
	tela.atualizar(itens, [])
	await process_frame
	tela.rolagem.ensure_control_visible(tela.cartoes.get_child(0).get_child(0))
	await salvar("nome-longo")
	quit()
