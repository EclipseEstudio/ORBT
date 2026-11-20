extends CanvasLayer

const Tema = preload("res://src/Visual/tema_visual.gd")
const Icones = preload("res://src/Visual/icones_ui.gd")
const AreaSegura = preload("res://src/Visual/area_segura_menu.gd")
const DURACAO := 3.0
const FADE := 0.35

var _fila: Array[Dictionary] = []
var _margem: MarginContainer
var _painel: PanelContainer
var _icone: TextureRect
var _titulo: Label
var _estilo: StyleBoxFlat
var _transicao: Tween


func _ready() -> void:
	name = "NotificacaoConquistas"
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20
	_margem = MarginContainer.new()
	_margem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_margem.theme = Tema.criar()
	add_child(_margem)
	_margem.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_painel = PanelContainer.new()
	_painel.name = "Painel"
	_painel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_painel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_estilo = Tema.painel()
	_estilo.set_content_margin_all(5)
	_painel.add_theme_stylebox_override("panel", _estilo)
	_margem.add_child(_painel)
	var linha := HBoxContainer.new()
	linha.mouse_filter = Control.MOUSE_FILTER_IGNORE
	linha.add_theme_constant_override("separation", 6)
	_painel.add_child(linha)
	_icone = TextureRect.new()
	_icone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icone.custom_minimum_size = Vector2(18, 18)
	_icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	linha.add_child(_icone)
	var coluna := VBoxContainer.new()
	coluna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coluna.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	coluna.add_theme_constant_override("separation", 3)
	linha.add_child(coluna)
	var cabecalho := Label.new()
	cabecalho.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cabecalho.text = "Nova conquista"
	cabecalho.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cabecalho.add_theme_font_size_override("font_size", Tema.TAMANHO_TEXTO_AJUDA)
	cabecalho.modulate = Tema.DESTAQUE
	coluna.add_child(cabecalho)
	_titulo = Label.new()
	_titulo.name = "Titulo"
	_titulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	coluna.add_child(_titulo)
	get_viewport().size_changed.connect(_ajustar_area)
	_ajustar_area()
	_painel.hide()


func mostrar(conquista: Dictionary) -> void:
	_fila.append(conquista)
	if not _painel.visible:
		_mostrar_proxima()


func limpar() -> void:
	_fila.clear()
	if _transicao != null:
		_transicao.kill()
		_transicao = null
	_painel.hide()


func _mostrar_proxima() -> void:
	if _fila.is_empty():
		_painel.hide()
		_transicao = null
		return
	var conquista: Dictionary = _fila.pop_front()
	_titulo.text = conquista.titulo
	_icone.texture = Icones.obter(conquista.imagem)
	_icone.modulate = conquista.cor
	_estilo.border_color = conquista.cor
	_painel.modulate.a = 1.0
	_painel.show()
	_transicao = create_tween().set_ignore_time_scale(true)
	_transicao.tween_interval(DURACAO)
	_transicao.tween_property(_painel, "modulate:a", 0.0, FADE)
	_transicao.tween_callback(_mostrar_proxima)


func _ajustar_area() -> void:
	AreaSegura.aplicar(_margem, 8, AreaSegura.fisica())
	var largura := get_viewport().get_visible_rect().size.x + _margem.offset_right - _margem.offset_left
	var recuo := maxf(0.0, (largura - 238.0) * 0.5)
	_margem.offset_left += recuo
	_margem.offset_right -= recuo
	_margem.offset_top += 30
