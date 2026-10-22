extends CanvasLayer

const Tema = preload("res://src/Visual/tema_visual.gd")
const Indicadores = preload("res://src/Visual/indicadores.gd")
var _indicadores: Control

var partida: Node
var _status: Label
var _mensagem: Label
var _alerta: Label
var _destino: Label
var _pausa: Button
var _explorar: Button
var _raiz: Control
var _area_fisica := Rect2()
var _transformacao_tela := Transform2D()


func rotulo(pai: Control, texto: String, tamanho := 10) -> Label:
	var item := Label.new()
	item.text = texto
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	item.add_theme_font_size_override("font_size", tamanho)
	pai.add_child(item)
	return item


func botao(pai: Control, texto: String, acao: Callable) -> Button:
	var item := Button.new()
	item.text = texto
	item.custom_minimum_size = Vector2(0, 28)
	item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item.add_theme_font_size_override("font_size", 10)
	item.pressed.connect(acao)
	pai.add_child(item)
	return item


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	var raiz := Control.new()
	raiz.theme = Tema.criar()
	_raiz = raiz
	raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(raiz)
	raiz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var topo := VBoxContainer.new()
	topo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(topo)
	topo.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	topo.offset_left = 6
	topo.offset_top = 5
	topo.offset_right = -6
	var linha := HBoxContainer.new()
	linha.mouse_filter = Control.MOUSE_FILTER_IGNORE
	topo.add_child(linha)
	_status = rotulo(linha, "", 10)
	_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_pausa = botao(linha, "Pausar", _alternar_pausa)
	_pausa.size_flags_horizontal = Control.SIZE_SHRINK_END
	_indicadores = Indicadores.new()
	topo.add_child(_indicadores)
	_destino = rotulo(topo, "")
	_alerta = rotulo(topo, "", 9)
	_alerta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var base := VBoxContainer.new()
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(base)
	base.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	base.offset_left = 6
	base.offset_right = -6
	base.offset_top = -104 if partida.campanha_permitida else -74
	base.offset_bottom = -6
	base.minimum_size_changed.connect(func(): base.offset_top = -base.get_combined_minimum_size().y - 6)
	_mensagem = rotulo(base, "", 9)
	_mensagem.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_mensagem.custom_minimum_size.y = 36
	_mensagem.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	var acoes := HBoxContainer.new()
	acoes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	base.add_child(acoes)
	_explorar = botao(acoes, "Explorar mapa", partida.alternar_exploracao)
	botao(acoes, "Reiniciar", partida.reiniciar)
	if partida.campanha_permitida:
		botao(base, "Seleção de fases", func():
			partida.nave.entrada.cancelar()
			partida.selecao_solicitada.emit.call_deferred())
	base.set_deferred("offset_top", -base.get_combined_minimum_size().y - 6)
	get_viewport().size_changed.connect(_atualizar_area_segura)
	_atualizar_area_segura()


static func area_segura_logica(area_fisica: Rect2, transformacao: Transform2D, viewport: Rect2) -> Rect2:
	if not area_fisica.has_area() or is_zero_approx(transformacao.determinant()):
		return viewport
	var area := (transformacao.affine_inverse() * area_fisica).intersection(viewport)
	return area if area.has_area() else viewport


func _atualizar_area_segura() -> void:
	if not OS.has_feature("android"):
		return
	_area_fisica = Rect2(DisplayServer.get_display_safe_area())
	_transformacao_tela = get_viewport().get_screen_transform()
	var viewport := get_viewport().get_visible_rect()
	var area := area_segura_logica(_area_fisica, _transformacao_tela, viewport)
	_raiz.offset_left = area.position.x
	_raiz.offset_top = area.position.y
	_raiz.offset_right = area.end.x - viewport.end.x
	_raiz.offset_bottom = area.end.y - viewport.end.y


func _alternar_pausa() -> void:
	if partida.estado == partida.Estado.PAUSADO:
		partida.retomar()
	else:
		partida.pausar()


func _process(_delta: float) -> void:
	if OS.has_feature("android") and (_area_fisica != Rect2(DisplayServer.get_display_safe_area()) or _transformacao_tela != get_viewport().get_screen_transform()):
		_atualizar_area_segura()
	_status.text = "Combustível: %d\nTempo: %.1f s" % [partida.nave.combustivel, partida.tempo_restante]
	_indicadores.combustivel = partida.nave.combustivel
	_indicadores.capacidade = partida.nivel.combustivel_inicial
	_indicadores.tempo = partida.tempo_restante
	_indicadores.duracao = partida.nivel.tempo_voo
	_indicadores.queue_redraw()
	_pausa.text = "Retomar" if partida.estado == partida.Estado.PAUSADO else "Pausar"
	_pausa.disabled = partida.estado in [partida.Estado.PERDIDA, partida.Estado.CONCLUIDA]
	_explorar.text = "Voltar à nave" if partida.explorando else "Explorar mapa"
	_explorar.disabled = partida.estado != partida.Estado.JOGANDO
	if partida.estado == partida.Estado.PAUSADO:
		_mensagem.text = "Partida pausada.\nToque em Retomar para continuar."
	elif partida.estado in [partida.Estado.PERDIDA, partida.Estado.CONCLUIDA]:
		_mensagem.text = partida.motivo + "\nToque em Reiniciar para tentar novamente."
	elif partida.explorando:
		_mensagem.text = "Arraste para explorar.\nO tempo de voo continua correndo."
	elif partida.nave.combustivel == 0:
		_mensagem.text = "À deriva. Ainda é possível chegar à Terra."
	elif partida.nave.condicao != partida.nave.Condicao.POUSADA:
		_mensagem.text = "Arraste para corrigir."
	else:
		_mensagem.text = "Arraste e solte para lançar.\nCírculo cancela. Prévia estimada."
	var avisos := PackedStringArray()
	for id_corpo in partida.proximos:
		if id_corpo == partida.nave.corpo_apoio:
			continue
		var tipo: String = partida.proximos[id_corpo]
		avisos.append(("! Perigo: " if tipo in ["sun", "asteroid"] else "+ Próximo: ") + id_corpo)
	_alerta.text = "  ".join(avisos)
	var alvo: Vector2 = partida.nivel.corpos[-1].position
	var na_tela: Vector2 = partida.nave.get_canvas_transform() * alvo
	var tamanho := get_viewport().get_visible_rect().size
	var direcao := ""
	if na_tela.y < 0:
		direcao += "↑"
	elif na_tela.y > tamanho.y:
		direcao += "↓"
	if na_tela.x < 0:
		direcao += "←"
	elif na_tela.x > tamanho.x:
		direcao += "→"
	_destino.text = "Terra %s · %d m" % [direcao, partida.nave.global_position.distance_to(alvo)]
