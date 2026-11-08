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
var texto_menu := "Voltar ao menu"
var mostrar_primario := true
var modo_conclusao := false
var modo_pausa := false
var _motivo: Label
var _rolagem_motivo: ScrollContainer
var _titulo: Label
var _estrelas_resultado: HBoxContainer

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
	painel.add_theme_stylebox_override("panel", Tema.painel())
	centro.add_child(painel)
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 6)
	painel.add_child(coluna)
	var rotulo_titulo := Label.new()
	_titulo = rotulo_titulo
	rotulo_titulo.text = titulo
	rotulo_titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rotulo_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rotulo_titulo.add_theme_font_size_override("font_size", 8)
	coluna.add_child(rotulo_titulo)
	if modo_conclusao:
		rotulo_titulo.add_theme_color_override("font_color", Tema.DESTAQUE)
		_estrelas_resultado = HBoxContainer.new()
		_estrelas_resultado.name = "EstrelasResultado"
		_estrelas_resultado.alignment = BoxContainer.ALIGNMENT_CENTER
		_estrelas_resultado.add_theme_constant_override("separation", 5)
		coluna.add_child(_estrelas_resultado)
		for indice in range(4):
			var estrela := TextureRect.new()
			estrela.name = "Azul" if indice == 3 else "Dourada%d" % (indice + 1)
			estrela.texture = Icones.obter("estrela")
			estrela.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			estrela.custom_minimum_size = Vector2(20, 20)
			estrela.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			estrela.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			_estrelas_resultado.add_child(estrela)
	_rolagem_motivo = ScrollContainer.new()
	_rolagem_motivo.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_rolagem_motivo.custom_minimum_size.y = 36
	coluna.add_child(_rolagem_motivo)
	_motivo = Label.new()
	_motivo.name = "Motivo"
	_motivo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_motivo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_motivo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_motivo.add_theme_font_size_override("font_size", 8)
	_rolagem_motivo.add_child(_motivo)
	_rolagem_motivo.hide()
	var acoes: Node = coluna
	if modo_conclusao or modo_pausa:
		var linha := HBoxContainer.new()
		linha.alignment = BoxContainer.ALIGNMENT_CENTER
		coluna.add_child(linha)
		acoes = linha
	_continuar = _botao(acoes, texto_primario, "jogar", func(): continuar.emit())
	_continuar.visible = mostrar_primario
	Tema.destacar(_continuar)
	_resetar = _botao(acoes, texto_secundario, "reiniciar", func(): resetar.emit())
	_menu = _botao(acoes, texto_menu, "casa", func(): menu.emit())
	if modo_conclusao or modo_pausa:
		Icones.aplicar(_menu, "casa", "Voltar ao menu de fases")
		Icones.aplicar(_resetar, "reiniciar", "Repetir fase" if modo_conclusao else texto_secundario)
		Icones.aplicar(_continuar, "jogar", "Próxima fase" if modo_conclusao else texto_primario)
		for botao in [_menu, _resetar, _continuar]:
			botao.custom_minimum_size = Vector2(32, 32)
		acoes.move_child(_menu, 0)
		acoes.move_child(_resetar, 1)
	get_viewport().size_changed.connect(_area_segura)
	_area_segura()

func _botao(pai: Node, texto: String, icone: String, acao: Callable) -> Button:
	var botao := Button.new()
	botao.text = texto
	botao.custom_minimum_size.y = 32
	botao.add_theme_font_size_override("font_size", 8)
	Icones.aplicar(botao, icone, texto, false)
	botao.pressed.connect(acao)
	pai.add_child(botao)
	return botao

func abrir() -> void:
	_area_segura()
	show()
	if _continuar.visible:
		_continuar.grab_focus()
	elif modo_conclusao:
		_menu.grab_focus()
	else:
		_resetar.grab_focus()

func exibir_motivo(texto: String) -> void:
	_motivo.text = texto
	_rolagem_motivo.visible = not texto.is_empty()
	_rolagem_motivo.scroll_vertical = 0


func exibir_estrelas(douradas: int, azul: bool) -> void:
	if not is_instance_valid(_estrelas_resultado):
		return
	for indice in range(4):
		var estrela := _estrelas_resultado.get_child(indice) as TextureRect
		var obtida := azul if indice == 3 else indice < douradas
		estrela.visible = indice != 3 or azul
		estrela.modulate = (Color("57b9ff") if indice == 3 else Color("ffc845")) if obtida else Color("45516b")
		estrela.accessibility_name = ("Estrela azul" if indice == 3 else "Estrela dourada %d" % (indice + 1)) + (" conquistada" if obtida else " não conquistada")

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
