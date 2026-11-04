extends Control

signal continuar
signal resetar
signal menu
const Tema = preload("res://src/Visual/tema_visual.gd")
const Icones = preload("res://src/Visual/icones_ui.gd")
const AreaSegura = preload("res://src/Visual/area_segura_menu.gd")
var _margem: MarginContainer
var _continuar: Button
var _resetar: Button
var _menu: Button
var titulo := "PAUSA"
var texto_primario := "Continuar"
var texto_secundario := "Resetar"
var mostrar_primario := true
var _motivo: Label
var _rolagem_motivo: ScrollContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	theme = Tema.criar()
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var sombra := ColorRect.new()
	sombra.color = Color(0.015, 0.025, 0.06, 0.8)
	sombra.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(sombra)
	sombra.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_margem = MarginContainer.new()
	_margem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_margem)
	_margem.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var centro := CenterContainer.new()
	centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_margem.add_child(centro)
	var painel := PanelContainer.new()
	painel.name = "Painel"
	painel.custom_minimum_size.x = 144
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Tema.FUNDO
	estilo.border_color = Tema.DESTAQUE
	estilo.set_border_width_all(1)
	estilo.set_content_margin_all(8)
	painel.add_theme_stylebox_override("panel", estilo)
	centro.add_child(painel)
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 6)
	painel.add_child(coluna)
	var rotulo_titulo := Label.new()
	rotulo_titulo.text = titulo
	rotulo_titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rotulo_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rotulo_titulo.add_theme_font_size_override("font_size", 14)
	coluna.add_child(rotulo_titulo)
	_rolagem_motivo = ScrollContainer.new()
	_rolagem_motivo.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_rolagem_motivo.custom_minimum_size.y = 36
	coluna.add_child(_rolagem_motivo)
	_motivo = Label.new()
	_motivo.name = "Motivo"
	_motivo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_motivo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_motivo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_motivo.add_theme_font_size_override("font_size", 10)
	_rolagem_motivo.add_child(_motivo)
	_rolagem_motivo.hide()
	_continuar = _botao(coluna, texto_primario, "jogar", func(): continuar.emit())
	_continuar.visible = mostrar_primario
	Tema.destacar(_continuar)
	_resetar = _botao(coluna, texto_secundario, "reiniciar", func(): resetar.emit())
	_menu = _botao(coluna, "Voltar ao menu", "casa", func(): menu.emit())
	get_viewport().size_changed.connect(_area_segura)
	_area_segura()

func _botao(pai: Node, texto: String, icone: String, acao: Callable) -> Button:
	var botao := Button.new()
	botao.text = texto
	botao.custom_minimum_size.y = 32
	botao.add_theme_font_size_override("font_size", 10)
	Icones.aplicar(botao, icone, texto, false)
	botao.pressed.connect(acao)
	pai.add_child(botao)
	return botao

func abrir() -> void:
	_area_segura()
	show()
	if _continuar.visible:
		_continuar.grab_focus()
	else:
		_resetar.grab_focus()

func exibir_motivo(texto: String) -> void:
	_motivo.text = texto
	_rolagem_motivo.visible = not texto.is_empty()
	_rolagem_motivo.scroll_vertical = 0

func _area_segura() -> void:
	var fisica := AreaSegura.fisica()
	if fisica.has_area():
		AreaSegura.aplicar(_margem, 8, fisica)
	else:
		_margem.offset_left = 8
		_margem.offset_top = 8
		_margem.offset_right = -8
		_margem.offset_bottom = -8

func _process(_delta: float) -> void:
	if visible and OS.has_feature("android"):
		_area_segura()
