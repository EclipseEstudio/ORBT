extends Control

const AreaSegura = preload("res://src/Visual/area_segura_menu.gd")
const Tema = preload("res://src/Visual/tema_visual.gd")
const Icones = preload("res://src/Visual/icones_ui.gd")
const Fundo = preload("res://src/Visual/fundo_menu.gd")
const RolagemFases = preload("res://src/Campanha/rolagem_fases.gd")
signal fase_escolhida(id: String)
signal voltar
var itens: Array = []
var progresso: RefCounted
var erros: Array = []
var cartoes: VBoxContainer
var mensagem: Label
var _margem: MarginContainer
var _ocupada := false
var _segura := Rect2()
var _transformacao := Transform2D()
var _nota: Label
var _colecao: Label
var _tentar_salvar: Button
var controlador: Node
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
	estrela.modulate = Color("57b9ff")
	cabecalho.add_child(estrela)
	_colecao = _rotulo(cabecalho, "", 8)
	_colecao.name = "Colecao"
	_colecao.autowrap_mode = TextServer.AUTOWRAP_OFF
	_colecao.size_flags_horizontal = Control.SIZE_SHRINK_END
	_colecao.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_colecao.modulate = Color("57b9ff")
	rolagem = RolagemFases.new()
	rolagem.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rolagem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolagem.follow_focus = true
	coluna.add_child(rolagem)
	var conteudo := VBoxContainer.new()
	conteudo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rolagem.add_child(conteudo)
	_nota = _rotulo(conteudo, progresso.descricao() if progresso != null else "", 8)
	mensagem = _rotulo(conteudo, "", 8)
	cartoes = VBoxContainer.new()
	cartoes.add_theme_constant_override("separation", 6)
	cartoes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	conteudo.add_child(cartoes)
	_tentar_salvar = _botao(coluna, "Tentar salvar\nnovamente", func():
		progresso.salvar()
		_nota.text = progresso.descricao()
		_tentar_salvar.visible = progresso.salvamento_pendente()
		_mostrar_controle(_nota), 40)
	atualizar(itens, erros)
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
	var total_azuis := 0
	var obtidas_azuis := 0
	var grade: GridContainer
	for indice_item in range(itens.size()):
		var item: Dictionary = itens[indice_item]
		if indice_item % 10 == 0:
			_adicionar_divisor(indice_item)
			grade = GridContainer.new()
			grade.name = "Fases%02d" % (indice_item + 1)
			grade.columns = 5
			grade.add_theme_constant_override("h_separation", 2)
			grade.add_theme_constant_override("v_separation", 6)
			grade.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			if not progresso.bloqueio(item.id).is_empty():
				var bloco := PanelContainer.new()
				bloco.name = "Bloco%02d" % (indice_item + 1)
				bloco.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
				cartoes.add_child(bloco)
				bloco.add_child(grade)
				_adicionar_meta(bloco, indice_item)
			else:
				cartoes.add_child(grade)
		var quantidade: int = item.get("estrelas", 0)
		var recorde: int = mini(quantidade, progresso.melhor_estrelas(item.id))
		var azuis: int = int(item.get("azuis", 0))
		total_azuis += azuis
		obtidas_azuis += mini(azuis, progresso.melhor_azuis(item.id))
		var cartao := VBoxContainer.new()
		cartao.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cartao.add_theme_constant_override("separation", 3)
		grade.add_child(cartao)
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
		var bloqueio: String = progresso.bloqueio(item.id)
		if not bloqueio.is_empty():
			descricao += " - " + bloqueio
		Icones.aplicar(botao, icone, descricao, false)
		botao.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		botao.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		botao.set_meta("estado", estado)
		botao.alignment = HORIZONTAL_ALIGNMENT_CENTER
		botao.add_theme_constant_override("h_separation", 2)
		botao.add_theme_font_size_override("font_size", 8)
		if not botao.disabled:
			Tema.destacar(botao, Color("ffc845") if estado == "Concluída" else Tema.DESTAQUE)
		else:
			var sombra := StyleBoxFlat.new()
			sombra.bg_color = Color("181b20")
			sombra.border_color = Color("44484f")
			sombra.set_border_width_all(1)
			sombra.set_content_margin_all(4)
			botao.add_theme_stylebox_override("disabled", sombra)
			botao.add_theme_color_override("font_disabled_color", Color("8b8d91"))
			botao.add_theme_color_override("icon_disabled_color", Color("797c80"))
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
				pequena.modulate = Color("77797c") if botao.disabled and indice < recorde else (Color("44464a") if botao.disabled else (Color("ffc845") if indice < recorde else Color("45516b")))
				colecao.add_child(pequena)
			if quantidade > 3:
				var contagem := _rotulo(colecao, str(recorde), 6)
				contagem.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
				contagem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_colecao.text = "%d/%d" % [obtidas_azuis, total_azuis]
	_colecao.accessibility_name = "Estrelas azuis descobertas: %d de %d" % [obtidas_azuis, total_azuis]
	_colecao.tooltip_text = "Estrelas azuis descobertas. Elas são segredos e não bloqueiam fases."


func _adicionar_divisor(indice: int) -> void:
	var divisor := HBoxContainer.new()
	divisor.name = "Divisor%02d" % (indice + 1)
	divisor.alignment = BoxContainer.ALIGNMENT_CENTER
	divisor.add_theme_constant_override("separation", 4)
	cartoes.add_child(divisor)
	var esquerda := HSeparator.new()
	esquerda.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	divisor.add_child(esquerda)
	var texto := _rotulo(divisor, "NÍVEL %d" % (indice / 10 + 1), 8)
	texto.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	texto.autowrap_mode = TextServer.AUTOWRAP_OFF
	var direita := HSeparator.new()
	direita.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	divisor.add_child(direita)


func _adicionar_meta(bloco: Control, indice: int) -> void:
	if indice > 0:
		var total := 0
		var obtidas := 0
		for anterior in itens.slice(0, indice):
			var quantidade: int = anterior.get("estrelas", 0)
			total += quantidade
			obtidas += mini(quantidade, progresso.melhor_estrelas(anterior.id))
		var centro := CenterContainer.new()
		centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bloco.add_child(centro)
		var conteudo := VBoxContainer.new()
		conteudo.alignment = BoxContainer.ALIGNMENT_CENTER
		conteudo.add_theme_constant_override("separation", 0)
		conteudo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		centro.add_child(conteudo)
		var cadeado := TextureRect.new()
		cadeado.name = "Cadeado%02d" % (indice + 1)
		cadeado.texture = Icones.obter("cadeado")
		cadeado.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		cadeado.custom_minimum_size = Vector2(44, 44)
		cadeado.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		cadeado.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		cadeado.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		cadeado.modulate = Color("b1b4bb")
		cadeado.mouse_filter = Control.MOUSE_FILTER_IGNORE
		conteudo.add_child(cadeado)
		var painel := PanelContainer.new()
		painel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var estilo := StyleBoxFlat.new()
		estilo.bg_color = Color("181b20f2")
		estilo.set_content_margin_all(3)
		painel.add_theme_stylebox_override("panel", estilo)
		conteudo.add_child(painel)
		var linha := HBoxContainer.new()
		linha.name = "Meta%02d" % (indice + 1)
		linha.alignment = BoxContainer.ALIGNMENT_CENTER
		linha.add_theme_constant_override("separation", 3)
		painel.add_child(linha)
		var icone := TextureRect.new()
		icone.texture = Icones.obter("estrela")
		icone.custom_minimum_size = Vector2(10, 10)
		icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icone.modulate = Color("ffc845")
		linha.add_child(icone)
		var exigidas := total
		var meta := _rotulo(linha, "%d/%d" % [obtidas, exigidas], 8)
		meta.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		meta.autowrap_mode = TextServer.AUTOWRAP_OFF
		meta.modulate = Color("ffc845")
		meta.accessibility_name = "%d de %d estrelas douradas; %d necessárias" % [obtidas, total, exigidas]


func quantidade_cartoes() -> int:
	return itens.size()


func obter_cartao(indice: int) -> Control:
	if indice < 0 or indice >= itens.size():
		return null
	var grade := cartoes.find_child("Fases%02d" % (indice / 10 * 10 + 1), true, false) as GridContainer
	return grade.get_child(indice % 10) if grade != null else null


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
