extends Control

const AreaSegura = preload("res://src/Visual/area_segura_menu.gd")
const Tema = preload("res://src/Visual/tema_visual.gd")
const Icones = preload("res://src/Visual/icones_ui.gd")
const Fundo = preload("res://src/Visual/fundo_menu.gd")
signal fase_escolhida(id: String)
signal voltar
var itens: Array = []
var progresso: RefCounted
var erros: Array = []
var cartoes: GridContainer
var mensagem: Label
var _margem: MarginContainer
var _ocupada := false
var _segura := Rect2()
var _transformacao := Transform2D()
var _nota: Label
var _colecao: Label
var _tentar_salvar: Button
var controlador: Node
var _checkpoint_controles: VBoxContainer
var rolagem: ScrollContainer


func _ready() -> void:
	theme = Tema.criar()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var fundo := Fundo.new()
	fundo.mostrar_planeta = false
	add_child(fundo)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_margem = MarginContainer.new()
	add_child(_margem)
	_margem.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for lado in ["left", "top", "right", "bottom"]:
		_margem.add_theme_constant_override("margin_" + lado, 8)
	var coluna := VBoxContainer.new()
	_margem.add_child(coluna)
	var cabecalho := HBoxContainer.new()
	coluna.add_child(cabecalho)
	var voltar_menu := _botao(cabecalho, "", func(): voltar.emit(), 28)
	voltar_menu.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	voltar_menu.name = "Voltar"
	Icones.aplicar(voltar_menu, "voltar", "Voltar ao menu")
	_rotulo(cabecalho, "FASES", 8)
	var estrela := TextureRect.new()
	estrela.texture = Icones.obter("estrela")
	estrela.custom_minimum_size = Vector2(10, 12)
	estrela.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	estrela.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	estrela.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	estrela.modulate = Color("ffc845")
	cabecalho.add_child(estrela)
	_colecao = _rotulo(cabecalho, "", 8)
	_colecao.name = "Colecao"
	_colecao.autowrap_mode = TextServer.AUTOWRAP_OFF
	_colecao.size_flags_horizontal = Control.SIZE_SHRINK_END
	_colecao.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_colecao.modulate = Color("ffc845")
	rolagem = ScrollContainer.new()
	rolagem.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rolagem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolagem.follow_focus = true
	coluna.add_child(rolagem)
	var conteudo := VBoxContainer.new()
	conteudo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rolagem.add_child(conteudo)
	_nota = _rotulo(conteudo, progresso.descricao() if progresso != null else "", 8)
	mensagem = _rotulo(conteudo, "", 8)
	_checkpoint_controles = VBoxContainer.new()
	_checkpoint_controles.name = "Checkpoint"
	conteudo.add_child(_checkpoint_controles)
	cartoes = GridContainer.new()
	cartoes.columns = 5
	cartoes.add_theme_constant_override("h_separation", 2)
	cartoes.add_theme_constant_override("v_separation", 6)
	cartoes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	conteudo.add_child(cartoes)
	_tentar_salvar = _botao(coluna, "Tentar salvar\nnovamente", func():
		progresso.salvar()
		_nota.text = progresso.descricao()
		_tentar_salvar.visible = progresso.salvamento_pendente()
		_mostrar_controle(_nota), 40)
	atualizar(itens, erros)
	configurar_checkpoint()
	get_viewport().size_changed.connect(_area_segura)
	_area_segura()


func _rotulo(pai: Node, texto: String, fonte: int) -> Label:
	var rotulo := Label.new()
	rotulo.text = texto
	rotulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rotulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rotulo.add_theme_font_size_override("font_size", fonte)
	pai.add_child(rotulo)
	return rotulo


func _botao(pai: Node, texto: String, acao: Callable, altura: int) -> Button:
	var botao := Button.new()
	botao.text = texto
	botao.custom_minimum_size.y = altura
	botao.add_theme_font_size_override("font_size", 8)
	botao.pressed.connect(acao)
	pai.add_child(botao)
	return botao


func atualizar(novos: Array, diagnosticos: Array) -> void:
	itens = novos
	erros = diagnosticos
	if not is_instance_valid(cartoes):
		return
	_ocupada = false
	rolagem.scroll_vertical = 0
	_nota.text = progresso.descricao() if progresso != null else ""
	_tentar_salvar.visible = progresso != null and progresso.salvamento_pendente()
	_nota.visible = _tentar_salvar.visible
	for filho in cartoes.get_children():
		cartoes.remove_child(filho)
		filho.queue_free()
	mensagem.text = "\n".join(erros) if not erros.is_empty() else ("Nenhuma fase cadastrada." if itens.is_empty() else "")
	var total := 0
	var obtidas := 0
	for item in itens:
		var quantidade: int = item.get("estrelas", 0)
		var recorde: int = mini(quantidade, progresso.melhor_estrelas(item.id))
		total += quantidade
		obtidas += recorde
		var cartao := VBoxContainer.new()
		cartao.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cartao.add_theme_constant_override("separation", 3)
		cartoes.add_child(cartao)
		var nome := _rotulo(cartao, item.nome, 8)
		nome.hide()
		var estado: String = progresso.estado(item.id)
		var rotulo_estado := _rotulo(cartao, estado, 8)
		rotulo_estado.hide()
		var botao := _botao(cartao, "%02d" % item.ordem, func(): escolher(item.id), 40)
		botao.custom_minimum_size.x = 28
		botao.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		botao.disabled = not progresso.pode_abrir(item.id)
		var icone := "cadeado" if botao.disabled else ("concluida" if estado == "Concluída" else "jogar")
		var descricao := "%02d - %s - %s" % [item.ordem, item.nome, estado]
		if quantidade > 0:
			descricao += " - Estrelas: %d/%d" % [recorde, quantidade]
		Icones.aplicar(botao, icone, descricao, false)
		botao.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		botao.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		botao.set_meta("estado", estado)
		botao.alignment = HORIZONTAL_ALIGNMENT_CENTER
		botao.add_theme_constant_override("h_separation", 2)
		botao.add_theme_font_size_override("font_size", 8)
		if not botao.disabled:
			Tema.destacar(botao, Color("ffc845") if estado == "Concluída" else Tema.DESTAQUE)
		if quantidade > 0:
			var colecao := HBoxContainer.new()
			colecao.name = "Estrelas"
			colecao.alignment = BoxContainer.ALIGNMENT_CENTER
			colecao.add_theme_constant_override("separation", 1)
			colecao.mouse_filter = Control.MOUSE_FILTER_IGNORE
			colecao.tooltip_text = "Melhor coleta ao chegar à Terra: %d/%d" % [recorde, quantidade]
			cartao.add_child(colecao)
			for indice in range(quantidade if quantidade <= 3 else 1):
				var pequena := TextureRect.new()
				pequena.texture = Icones.obter("estrela")
				pequena.custom_minimum_size = Vector2(7, 7)
				pequena.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				pequena.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				pequena.mouse_filter = Control.MOUSE_FILTER_IGNORE
				pequena.modulate = Color("ffc845") if indice < recorde else Color("45516b")
				colecao.add_child(pequena)
			if quantidade > 3:
				var contagem := _rotulo(colecao, str(recorde), 6)
				contagem.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
				contagem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_colecao.text = "%d/%d" % [obtidas, total]
	_colecao.accessibility_name = "Coleção de estrelas: %d de %d" % [obtidas, total]
	_colecao.tooltip_text = "Melhor coleta de cada fase. Só vale ao chegar à Terra."


func escolher(id: String) -> void:
	if _ocupada:
		return
	if progresso == null or not progresso.pode_abrir(id) or not itens.any(func(item: Dictionary): return item.id == id):
		mensagem.text = "Fase bloqueada ou indisponível."
		return
	_ocupada = true
	mensagem.text = "Abrindo fase..."
	# Esperar a GUI encerrar o toque antes de instalar o novo mundo.
	fase_escolhida.emit.call_deferred(id)


func falhou(texto: String) -> void:
	_ocupada = false
	mensagem.text = texto
	_mostrar_controle(mensagem)


func _mostrar_controle(controle: Control) -> void:
	# Aviso e rodapé mudam de altura; aguardar a organização dos containers.
	await get_tree().process_frame
	if is_instance_valid(controle):
		rolagem.ensure_control_visible(controle)


func _area_segura() -> void:
	_segura = Rect2(DisplayServer.get_display_safe_area()) if OS.has_feature("android") else Rect2()
	_transformacao = get_viewport().get_screen_transform()
	AreaSegura.aplicar(_margem, 0, _segura)


func _process(_delta: float) -> void:
	if OS.has_feature("android") and (_segura != Rect2(DisplayServer.get_display_safe_area()) or _transformacao != get_viewport().get_screen_transform()):
		_area_segura()


func configurar_checkpoint() -> void:
	var jogo = controlador
	if not is_instance_valid(jogo):
		return
	var coluna := _checkpoint_controles
	# Validar o conteúdo para preservar os avisos, mesmo sem ação de retomada.
	jogo.checkpoint_disponivel()
	if jogo.checkpoint.salvamento_pendente():
		var tentar := Button.new()
		tentar.name = "TentarSalvarCheckpoint"
		tentar.text = "Salvar último pouso"
		tentar.custom_minimum_size = Vector2(120, 48)
		tentar.add_theme_font_size_override("font_size", 8)
		coluna.add_child(tentar)
		tentar.pressed.connect(func():
			jogo.tentar_salvar_checkpoint()
			jogo.mostrar_selecao.call_deferred())
	if not jogo.checkpoint.aviso.is_empty():
		_exibir_aviso(jogo.checkpoint.aviso)
	elif not jogo.checkpoint.dados.is_empty():
		_exibir_aviso("Último pouso salvo.")

func _exibir_aviso(texto: String) -> void:
	var coluna: VBoxContainer = _checkpoint_controles
	var aviso := coluna.get_node_or_null("AvisoCheckpoint") as Label
	if aviso == null:
		aviso = Label.new()
		aviso.name = "AvisoCheckpoint"
		aviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		aviso.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		aviso.add_theme_font_size_override("font_size", 8)
		coluna.add_child(aviso)
	aviso.text = texto
