extends Control

const Tema = preload("res://src/Visual/tema_visual.gd")
const AreaSegura = preload("res://src/Visual/area_segura_menu.gd")
const Fundo = preload("res://src/Visual/fundo_menu.gd")
const Icones = preload("res://src/Visual/icones_ui.gd")
signal fechada
var preferencias: RefCounted
var _aviso: Label
var _margem: MarginContainer
var _tentar_salvar: Button
var rolagem: ScrollContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	theme = Tema.criar()
	var fundo := Fundo.new()
	fundo.name = "Fundo"
	add_child(fundo)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margem := MarginContainer.new()
	_margem = margem
	add_child(margem)
	margem.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for lado in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margem.add_theme_constant_override(lado, 8)
	var estrutura := VBoxContainer.new()
	margem.add_child(estrutura)
	var cabecalho := HBoxContainer.new()
	cabecalho.name = "Cabecalho"
	estrutura.add_child(cabecalho)
	var voltar := Button.new()
	voltar.name = "Voltar"
	Icones.aplicar(voltar, "voltar", "Voltar")
	voltar.pressed.connect(fechar)
	cabecalho.add_child(voltar)
	var titulo := Label.new()
	titulo.text = "CONFIGURAÇÕES"
	titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titulo.add_theme_font_size_override("font_size", 8)
	cabecalho.add_child(titulo)
	var coluna := VBoxContainer.new()
	coluna.alignment = BoxContainer.ALIGNMENT_BEGIN
	coluna.add_theme_constant_override("separation", 8)
	rolagem = ScrollContainer.new()
	rolagem.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rolagem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolagem.follow_focus = true
	estrutura.add_child(rolagem)
	var centro := VBoxContainer.new()
	centro.alignment = BoxContainer.ALIGNMENT_CENTER
	centro.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	centro.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rolagem.add_child(centro)
	var painel := PanelContainer.new()
	painel.name = "Painel"
	painel.add_theme_stylebox_override("panel", Tema.painel())
	centro.add_child(painel)
	painel.add_child(coluna)
	_criar_volume(coluna, "Música", "musica", preferencias.musica)
	_criar_volume(coluna, "Efeitos", "efeitos", preferencias.efeitos)
	_aviso = Label.new()
	_aviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_aviso.name = "aviso"
	_aviso.add_theme_font_size_override("font_size", 8)
	_aviso.text = preferencias.aviso
	coluna.add_child(_aviso)
	_tentar_salvar = Button.new()
	_tentar_salvar.name = "TentarSalvar"
	_tentar_salvar.text = "Tentar salvar\nnovamente"
	_tentar_salvar.custom_minimum_size.y = 36
	_tentar_salvar.add_theme_font_size_override("font_size", 8)
	coluna.add_child(_tentar_salvar)
	_tentar_salvar.pressed.connect(func():
		preferencias.salvar()
		_atualizar_aviso())
	_atualizar_aviso()
	get_viewport().size_changed.connect(_area_segura)
	_area_segura()

func fechar() -> void:
	if is_queued_for_deletion():
		return
	fechada.emit()
	queue_free()

func _atualizar_aviso() -> void:
	_aviso.text = preferencias.aviso
	if preferencias.salvamento_pendente():
		_aviso.text += "\nOs volumes valem nesta sessão, mas ainda não foram salvos."
	_tentar_salvar.visible = preferencias.salvamento_pendente()

func _area_segura() -> void:
	AreaSegura.aplicar(_margem, 0, AreaSegura.fisica())

func _process(_delta: float) -> void:
	if OS.has_feature("android"):
		_area_segura()

func _criar_volume(coluna: VBoxContainer, titulo: String, campo: String, valor: float) -> void:
	var rotulo := Label.new()
	rotulo.add_theme_font_size_override("font_size", 8)
	coluna.add_child(rotulo)
	var seletor := HSlider.new()
	seletor.name = campo
	seletor.min_value = 0
	seletor.max_value = 1
	seletor.step = 0.05
	seletor.custom_minimum_size.y = 30
	seletor.value = valor
	coluna.add_child(seletor)
	rotulo.text = "%s: %d%%" % [titulo, roundi(valor * 100)]
	seletor.value_changed.connect(func(novo: float):
		preferencias.alterar(campo, novo)
		rotulo.text = "%s: %d%%" % [titulo, roundi(novo * 100)]
		_atualizar_aviso())
