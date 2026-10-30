extends CanvasLayer

const Tema = preload("res://src/Visual/tema_visual.gd")
const Indicadores = preload("res://src/Visual/indicadores.gd")
const TelaConfiguracoes = preload("res://src/Configuracoes/tela_configuracoes.gd")
const Narrativa = preload("res://src/Narrativa/narrativa.gd")
var _indicadores: Control

var partida: Node
var preferencias: RefCounted
var proxima_fase := ""
var _status: Label
var _mensagem: Label
var _alerta: Label
var _destino: Label
var _pausa: Button
var _explorar: Button
var _checkpoint: Button
var _configuracoes: Button
var _reiniciar: Button
var _proxima: Button
var _menu: Button
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
	_status = rotulo(linha, "", 9)
	_status.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var fundo_status := StyleBoxFlat.new()
	fundo_status.bg_color = Tema.FUNDO
	fundo_status.set_content_margin_all(1)
	_status.add_theme_stylebox_override("normal", fundo_status)
	var espaco := Control.new()
	espaco.mouse_filter = Control.MOUSE_FILTER_IGNORE
	espaco.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	linha.add_child(espaco)
	_pausa = botao(linha, "Pausar", _alternar_pausa)
	_pausa.size_flags_horizontal = Control.SIZE_SHRINK_END
	_indicadores = Indicadores.new()
	_indicadores.custom_minimum_size.x = 65
	_indicadores.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
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
	_reiniciar = botao(acoes, "Reiniciar", partida.reiniciar)
	_checkpoint = botao(base, "Voltar ao último pouso", partida.restaurar_checkpoint)
	_checkpoint.visible = false
	if preferencias != null:
		_configuracoes = botao(base, "Configurações", _abrir_configuracoes)
		_configuracoes.visible = false
	if partida.campanha_permitida:
		_proxima = botao(base, "Próxima fase", func(): partida.proxima_solicitada.emit.call_deferred())
		_proxima.visible = false
		_menu = botao(base, "Menu principal", func(): partida.menu_solicitado.emit.call_deferred())
		_menu.visible = false
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


static func direcao_alvo(na_tela: Vector2, viewport: Rect2, status: Rect2) -> String:
	var direcao := ""
	if na_tela.y < viewport.position.y or status.has_point(na_tela):
		direcao += "↑"
	elif na_tela.y > viewport.end.y:
		direcao += "↓"
	if na_tela.x < viewport.position.x:
		direcao += "←"
	elif na_tela.x > viewport.end.x:
		direcao += "→"
	return direcao


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

func _abrir_configuracoes() -> void:
	if partida.estado != partida.Estado.PAUSADO or preferencias == null or _raiz.has_node("TelaConfiguracoes"):
		return
	var tela := TelaConfiguracoes.new()
	tela.name = "TelaConfiguracoes"
	tela.preferencias = preferencias
	_raiz.add_child(tela)


func _dica_tutorial() -> String:
	var gesto = partida.nave.entrada.gesto
	if gesto.contato_ativo != -1:
		if gesto.saiu_da_zona_morta:
			return "Solte para lançar: custa 1.\nVolte ao círculo para cancelar."
		return "Arraste para mirar.\nVolte ao círculo para cancelar."
	if partida.nave.combustivel < partida.nivel.combustivel_inicial:
		return "Cada impulso custa 1.\nPousar não recarrega combustível."
	var dica := str(partida.nivel.dados_autorais.get("tutorial", "")).strip_edges()
	return "Toque e segure para mirar.\n" + dica if not dica.is_empty() else "Toque e segure para mirar.\nArraste e solte para lançar."


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
	_explorar.visible = partida.estado == partida.Estado.JOGANDO
	_reiniciar.text = "Repetir" if partida.estado == partida.Estado.CONCLUIDA else "Reiniciar"
	_checkpoint.visible = partida.estado == partida.Estado.PERDIDA
	if _proxima != null:
		_proxima.visible = partida.estado == partida.Estado.CONCLUIDA and not proxima_fase.is_empty()
	if _menu != null:
		_menu.visible = partida.estado == partida.Estado.PAUSADO
	if _configuracoes != null:
		_configuracoes.visible = partida.estado == partida.Estado.PAUSADO
	if partida.estado == partida.Estado.PAUSADO:
		_mensagem.text = "Partida pausada.\nToque em Retomar para continuar."
	elif partida.estado == partida.Estado.CONCLUIDA and partida.campanha_permitida:
		_mensagem.text = Narrativa.chegada(proxima_fase.is_empty())
	elif partida.estado in [partida.Estado.PERDIDA, partida.Estado.CONCLUIDA]:
		_mensagem.text = partida.motivo + "\nEscolha como continuar."
	elif partida.explorando:
		_mensagem.text = "Arraste para explorar.\nO tempo de voo continua correndo."
	elif partida.nave.combustivel == 0:
		_mensagem.text = "À deriva. Ainda é possível chegar à Terra."
	elif partida.nivel.id == "teste_001":
		_mensagem.text = _dica_tutorial()
	elif partida.nave.condicao in [partida.nave.Condicao.EM_VOO, partida.nave.Condicao.A_DERIVA]:
		_mensagem.text = "Arraste para corrigir."
	else:
		var dica := str(partida.nivel.dados_autorais.get("tutorial", "")).strip_edges()
		_mensagem.text = dica if not dica.is_empty() else "Arraste e solte para lançar.\nCírculo cancela. Prévia estimada."
	var avisos := PackedStringArray()
	for id_corpo in partida.proximos:
		if id_corpo == partida.nave.corpo_apoio:
			continue
		var tipo: String = partida.proximos[id_corpo]
		avisos.append(("! Perigo: " if tipo in ["sun", "asteroid"] else "+ Próximo: ") + id_corpo)
	_alerta.text = "  ".join(avisos)
	if not partida.aviso_salvamento.is_empty():
		_alerta.text += "\n" + partida.aviso_salvamento
	var alvo: Vector2 = partida.nivel.corpos[-1].position
	var na_tela: Vector2 = partida.nave.get_canvas_transform() * alvo
	var direcao := direcao_alvo(na_tela, get_viewport().get_visible_rect(), _status.get_global_rect())
	_destino.text = "Terra %s · %d m" % [direcao, partida.nave.global_position.distance_to(alvo)]
