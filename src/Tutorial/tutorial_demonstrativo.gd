extends Control
## Demonstrações animadas no diálogo da primeira fase, com a campanha pausada.

signal fechada
const Tema = preload("res://src/Visual/tema_visual.gd")
const AreaSegura = preload("res://src/Visual/area_segura_menu.gd")
const AreaDemonstracao = preload("res://src/Tutorial/area_demonstracao.gd")
const TITULOS := ["IMPULSO", "CANCELAR"]
const INSTRUCOES := [
	"Arraste para baixo.\nDistância = força.\nSolte para subir.",
	"Arraste e volte ao\ncírculo sem soltar.\nCancelar não gasta."
]
var etapa := 0
var _fechando := false
var _pausa_anterior := false
var _foco_anterior: Control
var _margem: MarginContainer
var _painel: PanelContainer
var _contador: Label
var _titulo: Label
var _instrucao: Label
var _retorno: Label
var _avancar: Button
var _anterior: Button
var area: Control


func _ready() -> void:
	name = "TutorialDemonstrativo"
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 30
	mouse_filter = Control.MOUSE_FILTER_STOP
	theme = Tema.criar()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_pausa_anterior = get_tree().paused
	_foco_anterior = get_viewport().gui_get_focus_owner()
	get_tree().paused = true
	var fundo := ColorRect.new()
	fundo.color = Color(0.015, 0.025, 0.06, 0.8)
	fundo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fundo)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_margem = MarginContainer.new()
	add_child(_margem)
	_margem.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 4)
	var centro := CenterContainer.new()
	_margem.add_child(centro)
	_painel = PanelContainer.new()
	var estilo := Tema.painel()
	estilo.set_content_margin_all(4)
	_painel.add_theme_stylebox_override("panel", estilo)
	centro.add_child(_painel)
	_painel.add_child(coluna)
	var topo := HBoxContainer.new()
	coluna.add_child(topo)
	_contador = _rotulo(topo, "")
	_contador.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sair := _botao(topo, "×", fechar)
	sair.name = "Fechar"
	sair.accessibility_name = "Fechar tutorial"
	sair.custom_minimum_size = Vector2(32, 28)
	sair.size_flags_horizontal = Control.SIZE_SHRINK_END
	_titulo = _rotulo(coluna, "")
	_titulo.modulate = Tema.DESTAQUE
	_instrucao = _rotulo(coluna, "")
	_instrucao.add_theme_font_size_override("font_size", Tema.TAMANHO_TEXTO_AJUDA)
	_instrucao.custom_minimum_size.y = 32
	area = AreaDemonstracao.new()
	area.name = "AreaDemonstracao"
	area.accessibility_name = "Demonstração animada do gesto"
	area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	coluna.add_child(area)
	_retorno = _rotulo(coluna, "")
	_retorno.add_theme_font_size_override("font_size", Tema.TAMANHO_TEXTO_AJUDA)
	_retorno.custom_minimum_size.y = 24
	var acoes := HBoxContainer.new()
	coluna.add_child(acoes)
	_anterior = _botao(acoes, "Voltar", func(): _mostrar_etapa(etapa - 1))
	_avancar = _botao(acoes, "Próximo", _proxima)
	Tema.destacar(_avancar)
	get_viewport().size_changed.connect(_ajustar_area)
	_ajustar_area()
	_mostrar_etapa(0)
	sair.grab_focus()


func _rotulo(pai: Node, texto: String) -> Label:
	var rotulo := Label.new()
	rotulo.text = texto
	rotulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rotulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pai.add_child(rotulo)
	return rotulo


func _botao(pai: Node, texto: String, acao: Callable) -> Button:
	var botao := Button.new()
	botao.text = texto
	botao.custom_minimum_size = Vector2(0, 32)
	botao.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	botao.pressed.connect(acao)
	pai.add_child(botao)
	return botao


func _mostrar_etapa(indice: int) -> void:
	etapa = clampi(indice, 0, TITULOS.size() - 1)
	_contador.text = "COMO JOGAR\n%d / %d" % [etapa + 1, TITULOS.size()]
	_titulo.text = TITULOS[etapa]
	_instrucao.text = INSTRUCOES[etapa]
	_anterior.text = "Voltar"
	_anterior.disabled = etapa == 0
	_avancar.text = "Jogar" if etapa == TITULOS.size() - 1 else "Próximo"
	_retorno.text = "Impulso custa 1.\nLinha = direção." if etapa == 0 else "Pouso não recarrega.\nO2 diminui em voo."
	area.configurar(etapa)


func _proxima() -> void:
	if etapa == TITULOS.size() - 1:
		fechar()
	else:
		_mostrar_etapa(etapa + 1)


func _ajustar_area() -> void:
	AreaSegura.aplicar(_margem, 8, AreaSegura.fisica())
	var disponivel := get_viewport().get_visible_rect().size + Vector2(_margem.offset_right - _margem.offset_left, _margem.offset_bottom - _margem.offset_top)
	_painel.custom_minimum_size = Vector2(minf(240, disponivel.x), minf(280, disponivel.y))


func _unhandled_key_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("ui_cancel") and not evento.is_echo():
		get_viewport().set_input_as_handled()
		fechar()


func fechar() -> void:
	if _fechando:
		return
	_fechando = true
	# Consumir a entrada antes de retomar a tela que estava por baixo.
	_fechar_depois.call_deferred()


func _fechar_depois() -> void:
	get_tree().paused = _pausa_anterior
	if is_instance_valid(_foco_anterior) and _foco_anterior.is_visible_in_tree():
		_foco_anterior.grab_focus()
	fechada.emit()
	queue_free()
