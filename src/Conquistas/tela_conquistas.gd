extends Control

const Tema = preload("res://src/Visual/tema_visual.gd")
const AreaSegura = preload("res://src/Visual/area_segura_menu.gd")
const Icones = preload("res://src/Visual/icones_ui.gd")
const Conquistas = preload("res://src/Conquistas/conquistas.gd")
var progresso: RefCounted
var itens: Array = []
var _margem: MarginContainer
var rolagem: ScrollContainer
var cartoes: VBoxContainer
var _resumo: Label
var _foco_anterior: Control


func _ready() -> void:
	name = "TelaConquistas"
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	theme = Tema.criar()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_foco_anterior = get_viewport().gui_get_focus_owner()
	var fundo := preload("res://src/Visual/fundo_menu.gd").new()
	fundo.apenas_estrelas = true
	add_child(fundo)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_margem = MarginContainer.new()
	add_child(_margem)
	_margem.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 8)
	_margem.add_child(coluna)
	var cabecalho := HBoxContainer.new()
	coluna.add_child(cabecalho)
	var voltar := Button.new()
	voltar.name = "Voltar"
	Icones.aplicar(voltar, "voltar", "Voltar ao menu")
	voltar.pressed.connect(fechar)
	cabecalho.add_child(voltar)
	var titulo := _rotulo(cabecalho, "Conquistas", 8)
	titulo.name = "Titulo"
	titulo.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_resumo = _rotulo(coluna, "", 7)
	_resumo.modulate = Tema.DESTAQUE
	rolagem = ScrollContainer.new()
	rolagem.name = "Rolagem"
	rolagem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolagem.size_flags_vertical = Control.SIZE_EXPAND_FILL
	coluna.add_child(rolagem)
	cartoes = VBoxContainer.new()
	cartoes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cartoes.add_theme_constant_override("separation", 8)
	rolagem.add_child(cartoes)
	_atualizar()
	progresso.alterado.connect(_atualizar)
	get_viewport().size_changed.connect(_area_segura)
	_area_segura()
	voltar.grab_focus()


func _rotulo(pai: Node, texto: String, tamanho: int) -> Label:
	var rotulo := Label.new()
	rotulo.text = texto
	rotulo.add_theme_font_size_override("font_size", tamanho)
	rotulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rotulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rotulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pai.add_child(rotulo)
	return rotulo


func _imagem(pai: Node, nome: String, tamanho: int, cor: Color) -> TextureRect:
	var imagem := TextureRect.new()
	imagem.texture = Icones.obter(nome)
	imagem.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	imagem.custom_minimum_size = Vector2(tamanho, tamanho)
	imagem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	imagem.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	imagem.modulate = cor
	imagem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pai.add_child(imagem)
	return imagem


func _atualizar() -> void:
	for filho in cartoes.get_children():
		cartoes.remove_child(filho)
		filho.queue_free()
	var lista := Conquistas.listar(progresso, itens)
	var obtidas := 0
	for conquista in lista:
		obtidas += int(conquista.desbloqueada)
		var card := PanelContainer.new()
		card.name = conquista.id
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_theme_stylebox_override("panel", Tema.painel())
		card.accessibility_name = "%s. %s. %d de %d. %s" % [conquista.titulo, conquista.descricao, conquista.atual, conquista.meta, "Desbloqueada" if conquista.desbloqueada else "Bloqueada"]
		cartoes.add_child(card)
		var linha := HBoxContainer.new()
		linha.mouse_filter = Control.MOUSE_FILTER_IGNORE
		linha.add_theme_constant_override("separation", 6)
		card.add_child(linha)
		_imagem(linha, conquista.imagem, 24, conquista.cor if conquista.desbloqueada else Color("68788d")).name = "Imagem"
		var conteudo := VBoxContainer.new()
		conteudo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		conteudo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		linha.add_child(conteudo)
		var topo := HBoxContainer.new()
		topo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		conteudo.add_child(topo)
		_rotulo(topo, conquista.titulo, 7).name = "Titulo"
		var estado := _imagem(topo, "concluida" if conquista.desbloqueada else "cadeado", 12, Tema.SUCESSO if conquista.desbloqueada else Tema.DESTAQUE)
		estado.name = "Estado"
		estado.accessibility_name = "Desbloqueada" if conquista.desbloqueada else "Bloqueada"
		_rotulo(conteudo, conquista.descricao, 7).name = "Descricao"
		_rotulo(conteudo, "%d/%d" % [conquista.atual, conquista.meta], 7).modulate = conquista.cor if conquista.desbloqueada else Tema.DESTAQUE
	_resumo.text = "%d/%d desbloqueadas" % [obtidas, lista.size()]


func fechar() -> void:
	if is_instance_valid(_foco_anterior) and _foco_anterior.is_visible_in_tree():
		_foco_anterior.grab_focus()
	queue_free()


func _area_segura() -> void:
	AreaSegura.aplicar(_margem, 8, AreaSegura.fisica())


func _process(_delta: float) -> void:
	if OS.has_feature("android"):
		_area_segura()
