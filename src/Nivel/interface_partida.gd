extends CanvasLayer

const Tema = preload("res://src/Visual/tema_visual.gd")
const Indicadores = preload("res://src/Visual/indicadores.gd")
const TelaConfiguracoes = preload("res://src/Configuracoes/tela_configuracoes.gd")
const Narrativa = preload("res://src/Narrativa/narrativa.gd")
const AreaSeguraMenu = preload("res://src/Visual/area_segura_menu.gd")
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
var _topo: VBoxContainer
var _conteudo_rodape: VBoxContainer
var _rolagem_rodape: ScrollContainer


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
	_topo = topo
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
	_rolagem_rodape = ScrollContainer.new()
	_rolagem_rodape.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_rolagem_rodape.follow_focus = true
	raiz.add_child(_rolagem_rodape)
	_rolagem_rodape.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_rolagem_rodape.offset_left = 6
	_rolagem_rodape.offset_right = -6
	_rolagem_rodape.offset_bottom = -6
	var base := VBoxContainer.new()
	_conteudo_rodape = base
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	base.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rolagem_rodape.add_child(base)
	base.minimum_size_changed.connect(_ajustar_rodape)
	_raiz.resized.connect(_ajustar_rodape)
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
	_ajustar_rodape.call_deferred()
	get_viewport().size_changed.connect(_atualizar_area_segura)
	_atualizar_area_segura()


func _ajustar_rodape() -> void:
	if not is_instance_valid(_conteudo_rodape):
		return
	var jogando: bool = partida.estado == partida.Estado.JOGANDO
	_rolagem_rodape.mouse_filter = Control.MOUSE_FILTER_IGNORE if jogando else Control.MOUSE_FILTER_STOP
	var altura := _conteudo_rodape.get_combined_minimum_size().y
	if not jogando:
		var disponivel := maxf(28, _raiz.size.y - _topo.get_rect().end.y - 12)
		altura = minf(altura, disponivel)
	_rolagem_rodape.offset_top = -altura - 6


static func area_segura_logica(area_fisica: Rect2, transformacao: Transform2D, viewport: Rect2) -> Rect2:
	return AreaSeguraMenu.logica(area_fisica, transformacao, viewport)


static func direcao_alvo(na_tela: Vector2, viewport: Rect2, topo: Array[Rect2], rodape := Rect2()) -> String:
	var direcao := ""
	if na_tela.y < viewport.position.y:
		direcao += "↑"
	elif na_tela.y >= viewport.end.y:
		direcao += "↓"
	elif topo.any(func(regiao: Rect2): return regiao.has_point(na_tela)):
		direcao += "↑"
	elif rodape.has_point(na_tela):
		direcao += "↓"
	if na_tela.x < viewport.position.x:
		direcao += "←"
	elif na_tela.x >= viewport.end.x:
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
	if partida.estado != partida.Estado.PAUSADO or preferencias == null or has_node("TelaConfiguracoes"):
		return
	var tela := TelaConfiguracoes.new()
	tela.name = "TelaConfiguracoes"
	tela.preferencias = preferencias
	# A tela calcula sua própria área segura a partir do viewport inteiro.
	# Ser filha da raiz já recuada do HUD aplicaria as margens duas vezes.
	add_child(tela)


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
	var alvo: Vector2 = partida.nave.corpos[-1].position
	var na_tela: Vector2 = partida.nave.get_canvas_transform() * alvo
	var regioes_topo: Array[Rect2] = []
	for controle in [_status, _indicadores, _pausa, _destino, _alerta]:
		if controle.is_visible_in_tree() and not (controle is Label and controle.text.is_empty()):
			regioes_topo.append(controle.get_global_rect())
	var area := _raiz.get_global_rect()
	var rodape := _rolagem_rodape.get_global_rect().intersection(area)
	var direcao := direcao_alvo(na_tela, area, regioes_topo, rodape)
	_destino.text = "Terra %s · %d m" % [direcao, partida.nave.global_position.distance_to(alvo)]
	_ajustar_rodape()
