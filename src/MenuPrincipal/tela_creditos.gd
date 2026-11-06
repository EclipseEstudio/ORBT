extends Control

const Tema = preload("res://src/Visual/tema_visual.gd")
const AreaSegura = preload("res://src/Visual/area_segura_menu.gd")
const Icones = preload("res://src/Visual/icones_ui.gd")
const LOGO_WMDG = preload("res://Recursos/Logos/wmdg.png")
const LOGO_GODOT = preload("res://Recursos/Logos/godot.svg")
var _margem: MarginContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	theme = Tema.criar()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var fundo := preload("res://src/Visual/fundo_menu.gd").new()
	fundo.apenas_estrelas = true
	add_child(fundo)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margem := MarginContainer.new()
	_margem = margem
	add_child(margem)
	margem.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for lado in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margem.add_theme_constant_override(lado, 8)
	var coluna := VBoxContainer.new()
	margem.add_child(coluna)
	var cabecalho := HBoxContainer.new()
	cabecalho.name = "Cabecalho"
	coluna.add_child(cabecalho)
	var voltar := Button.new()
	voltar.name = "Voltar"
	Icones.aplicar(voltar, "voltar", "Voltar")
	voltar.pressed.connect(fechar)
	cabecalho.add_child(voltar)
	var titulo := Label.new()
	titulo.text = "CRÉDITOS"
	titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titulo.add_theme_font_size_override("font_size", 8)
	cabecalho.add_child(titulo)
	var rolagem := ScrollContainer.new()
	rolagem.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rolagem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolagem.name = "RolagemEquipe"
	coluna.add_child(rolagem)
	var equipe := VBoxContainer.new()
	equipe.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	equipe.size_flags_vertical = Control.SIZE_EXPAND_FILL
	equipe.alignment = BoxContainer.ALIGNMENT_CENTER
	rolagem.add_child(equipe)
	var secao := Label.new()
	secao.text = "EQUIPE"
	secao.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	secao.add_theme_font_size_override("font_size", 8)
	equipe.add_child(secao)
	var texto := Label.new()
	texto.name = "Texto"
	texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.add_theme_font_size_override("font_size", 8)
	texto.text = "Miguel Alves\nRubens Augusto\nGustavo Costa\nCesar Caus"
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	equipe.add_child(texto)
	var rodape := VBoxContainer.new()
	rodape.name = "Rodape"
	coluna.add_child(rodape)
	var logos := HBoxContainer.new()
	logos.name = "Logos"
	logos.alignment = BoxContainer.ALIGNMENT_CENTER
	logos.add_theme_constant_override("separation", 16)
	rodape.add_child(logos)
	_adicionar_logo(logos, LOGO_WMDG, "WMDG", "WMDG", "We Make Digital Games")
	var versao := Engine.get_version_info()
	var numero_versao := "%d.%d.%d" % [versao.major, versao.minor, versao.patch]
	_adicionar_logo(logos, LOGO_GODOT, "Godot", numero_versao, "Godot Engine\nLogo: Andrea Calabró — CC BY 4.0\nhttps://creativecommons.org/licenses/by/4.0/")
	get_viewport().size_changed.connect(_area_segura)
	_area_segura()


func _adicionar_logo(pai: Control, textura: Texture2D, nome: String, legenda: String, descricao: String) -> void:
	var coluna := VBoxContainer.new()
	pai.add_child(coluna)
	var logo := TextureRect.new()
	logo.name = nome
	logo.texture = textura
	logo.custom_minimum_size = Vector2(32, 32)
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if nome == "WMDG" else CanvasItem.TEXTURE_FILTER_LINEAR
	logo.tooltip_text = descricao
	logo.accessibility_name = descricao
	coluna.add_child(logo)
	var texto := Label.new()
	texto.text = legenda
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.add_theme_font_size_override("font_size", 6)
	coluna.add_child(texto)

func fechar() -> void:
	queue_free()

func _area_segura() -> void:
	AreaSegura.aplicar(_margem, 0, AreaSegura.fisica())

func _process(_delta: float) -> void:
	if OS.has_feature("android"):
		_area_segura()
