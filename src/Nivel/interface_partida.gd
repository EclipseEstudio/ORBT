extends CanvasLayer

const Tema = preload("res://src/Visual/tema_visual.gd")
const Bussola = preload("res://src/Visual/bussola_terra.gd")
const Indicadores = preload("res://src/Visual/indicadores.gd")
const TelaConfiguracoes = preload("res://src/Configuracoes/tela_configuracoes.gd")
const Narrativa = preload("res://src/Narrativa/narrativa.gd")
const AreaSeguraMenu = preload("res://src/Visual/area_segura_menu.gd")
const Icones = preload("res://src/Visual/icones_ui.gd")
const DialogoPausa = preload("res://src/Nivel/dialogo_pausa.gd")
const TituloFase = preload("res://src/Nivel/titulo_fase.gd")
const Tutorial = preload("res://src/Tutorial/tutorial_demonstrativo.gd")
const InstrumentosNebulosa = preload("res://src/Visual/instrumentos_nebulosa.gd")
const DURACAO_AJUDA := 6.0
var _ajuda_restante := DURACAO_AJUDA
var _dicas_ativas := true
var _dialogo_pausa: Control
var _dialogo_conclusao: Control
var _dialogo_derrota: Control
var _tempo_explosao := 0.0
var _indicadores: Control
var _fase: Label
var _estrelas: Label
var _icone_estrelas: TextureRect
var _bussola: Control
var _base_status: VBoxContainer

var partida: Node
var preferencias: RefCounted
var progresso: RefCounted
var proxima_fase := ""
var _status: Label
var _mensagem: Label
var _alerta: Label
var _pausa: Button
var _explorar: Button
var _zoom_controles: HBoxContainer
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


func rotulo(pai: Control, texto: String, tamanho := 8) -> Label:
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
	item.add_theme_font_size_override("font_size", 8)
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
	_fase = rotulo(linha, "%02d" % partida.nivel.ordem, 8)
	_fase.name = "Fase"
	_fase.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_fase.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_fase.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_explorar = botao(linha, "Explorar mapa", partida.alternar_exploracao)
	Icones.aplicar(_explorar, "olho", "Observar mapa")
	_explorar.size_flags_horizontal = Control.SIZE_SHRINK_END
	_pausa = botao(linha, "Pausar", _alternar_pausa)
	Icones.aplicar(_pausa, "pausa", "Pausar")
	_pausa.size_flags_horizontal = Control.SIZE_SHRINK_END
	_bussola = Bussola.new()
	_bussola.partida = partida
	_bussola.z_index = 2
	raiz.add_child(_bussola)
	_base_status = VBoxContainer.new()
	_base_status.name = "Recursos"
	_base_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(_base_status)
	_base_status.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_base_status.offset_left = 6
	_base_status.offset_right = -6
	_base_status.offset_top = -28
	_base_status.offset_bottom = -6
	var combustivel := HBoxContainer.new()
	combustivel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_base_status.add_child(combustivel)
	_icone_status(combustivel, "combustivel")
	_status = rotulo(combustivel, "", 8)
	_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_icone_estrelas = TextureRect.new()
	icones_configurar(_icone_estrelas, "estrela")
	_icone_estrelas.modulate = Color("ffc845")
	combustivel.add_child(_icone_estrelas)
	_estrelas = rotulo(combustivel, "", 8)
	_estrelas.name = "Estrelas"
	_estrelas.modulate = Color("ffc845")
	_indicadores = Indicadores.new()
	_indicadores.name = "Oxigenio"
	_base_status.add_child(_indicadores)
	_alerta = rotulo(topo, "", 8)
	_alerta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if partida.nivel.dados_autorais.has("nebula"):
		var instrumentos := InstrumentosNebulosa.new()
		instrumentos.partida = partida
		raiz.add_child(instrumentos)
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
	_mensagem = rotulo(base, "", 8)
	_mensagem.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_mensagem.custom_minimum_size.y = 0
	_mensagem.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	var estilo_ajuda := StyleBoxFlat.new()
	estilo_ajuda.bg_color = Color("070e21ee")
	estilo_ajuda.border_color = Tema.DESTAQUE
	estilo_ajuda.set_border_width_all(1)
	estilo_ajuda.set_content_margin_all(4)
	_mensagem.add_theme_stylebox_override("normal", estilo_ajuda)
	var acoes := HBoxContainer.new()
	acoes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	base.add_child(acoes)
	_zoom_controles = HBoxContainer.new()
	acoes.add_child(_zoom_controles)
	for fator in [0.8, 1.25]:
		var controle := botao(_zoom_controles, "-" if fator < 1 else "+", func(): get_parent().camera.aplicar_zoom(fator))
		controle.accessibility_name = "Diminuir zoom" if fator < 1 else "Aumentar zoom"
		controle.custom_minimum_size.x = 32
	_reiniciar = botao(acoes, "Reiniciar", partida.reiniciar)
	Icones.aplicar(_reiniciar, "reiniciar", "Reiniciar")
	_checkpoint = botao(base, "Voltar ao\núltimo pouso", partida.restaurar_checkpoint)
	_checkpoint.visible = false
	if preferencias != null:
		_configuracoes = botao(base, "Configurações", _abrir_configuracoes)
		_configuracoes.visible = false
	if partida.campanha_permitida:
		_proxima = botao(base, "Próxima fase", func(): partida.proxima_solicitada.emit.call_deferred())
		_proxima.visible = false
		_menu = botao(base, "Menu de fases", func(): partida.selecao_solicitada.emit.call_deferred())
		_menu.visible = false
	_ajustar_rodape.call_deferred()
	get_viewport().size_changed.connect(_atualizar_area_segura)
	_atualizar_area_segura()
	_dialogo_pausa = DialogoPausa.new()
	_dialogo_pausa.name = "DialogoPausa"
	_dialogo_pausa.modo_pausa = true
	_dialogo_pausa.continuar.connect(partida.retomar)
	_dialogo_pausa.resetar.connect(partida.reiniciar)
	_dialogo_pausa.texto_menu = "Menu de fases"
	_dialogo_pausa.menu.connect(func(): partida.selecao_solicitada.emit.call_deferred())
	add_child(_dialogo_pausa)
	_dialogo_pausa.hide()
	_dialogo_conclusao = DialogoPausa.new()
	_dialogo_conclusao.name = "DialogoConclusao"
	_dialogo_conclusao.modo_conclusao = true
	_dialogo_conclusao.cor_titulo = Tema.SUCESSO
	_dialogo_conclusao.titulo = "CAMPANHA CONCLUÍDA" if partida.campanha_permitida and proxima_fase.is_empty() else "FASE CONCLUÍDA"
	_dialogo_conclusao.texto_primario = "Próximo"
	_dialogo_conclusao.texto_secundario = "Repetir"
	_dialogo_conclusao.mostrar_primario = partida.campanha_permitida and not proxima_fase.is_empty()
	_dialogo_conclusao.continuar.connect(func(): partida.proxima_solicitada.emit.call_deferred())
	_dialogo_conclusao.resetar.connect(partida.reiniciar)
	_dialogo_conclusao.menu.connect(func(): partida.selecao_solicitada.emit.call_deferred())
	add_child(_dialogo_conclusao)
	_dialogo_conclusao.hide()
	_dialogo_derrota = DialogoPausa.new()
	_dialogo_derrota.name = "DialogoDerrota"
	_dialogo_derrota.titulo = "FIM DE JOGO"
	_dialogo_derrota.cor_titulo = Tema.ERRO
	_dialogo_derrota.texto_primario = "Último pouso"
	_dialogo_derrota.texto_secundario = "Repetir"
	_dialogo_derrota.continuar.connect(partida.restaurar_checkpoint)
	_dialogo_derrota.resetar.connect(partida.reiniciar)
	_dialogo_derrota.menu.connect(func(): partida.menu_solicitado.emit.call_deferred())
	add_child(_dialogo_derrota)
	_dialogo_derrota.hide()
	partida.perdida.connect(func(_causa): _tempo_explosao = 0.85)
	_apresentar_fase.call_deferred()

func _icone_status(pai: Control, nome: String) -> void:
	var icone := TextureRect.new()
	icones_configurar(icone, nome)
	pai.add_child(icone)

func icones_configurar(icone: TextureRect, nome: String) -> void:
	icone.texture = Icones.obter(nome)
	icone.custom_minimum_size = Vector2(10, 12)
	icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icone.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icone.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ajustar_rodape() -> void:
	if not is_instance_valid(_conteudo_rodape):
		return
	var jogando: bool = partida.estado == partida.Estado.JOGANDO
	_rolagem_rodape.mouse_filter = Control.MOUSE_FILTER_IGNORE if jogando else Control.MOUSE_FILTER_STOP
	var altura := _conteudo_rodape.get_combined_minimum_size().y
	if not jogando:
		var disponivel := maxf(28, _raiz.size.y - _topo.get_rect().end.y - 42)
		altura = minf(altura, disponivel)
	_rolagem_rodape.offset_bottom = -36
	_rolagem_rodape.offset_top = -altura - 36


static func area_segura_logica(area_fisica: Rect2, transformacao: Transform2D, viewport: Rect2) -> Rect2:
	return AreaSeguraMenu.logica(area_fisica, transformacao, viewport)


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
	var global := get_node_or_null("/root/GLOBAL")
	if global != null and is_instance_valid(global.controlador_jogo):
		tela.acao_resetar = global.controlador_jogo.resetar_progresso
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


func _process(delta: float) -> void:
	var pausado: bool = partida.estado == partida.Estado.PAUSADO
	var concluida: bool = partida.estado == partida.Estado.CONCLUIDA
	var perdida: bool = partida.estado == partida.Estado.PERDIDA
	_raiz.visible = not pausado and not concluida and not perdida
	if perdida:
		_tempo_explosao = maxf(0.0, _tempo_explosao - delta)
	if perdida and _tempo_explosao <= 0.0 and not _dialogo_derrota.visible:
		var motivo: String = partida.motivo
		if not partida.aviso_salvamento.is_empty():
			motivo += "\n" + partida.aviso_salvamento
		_dialogo_derrota.exibir_motivo(motivo)
		_dialogo_derrota.abrir()
	elif not perdida:
		_dialogo_derrota.hide()
	if concluida and not _dialogo_conclusao.visible:
		_dialogo_conclusao.exibir_estrelas(partida.quantidade_coletada("gold"), partida.quantidade_coletada("blue") > 0)
		_dialogo_conclusao.exibir_motivo(partida.aviso_salvamento)
		_dialogo_conclusao.abrir()
	elif not concluida:
		_dialogo_conclusao.hide()
	if pausado and not _dialogo_pausa.visible:
		_dialogo_pausa.abrir()
	elif not pausado and _dialogo_pausa.visible:
		_dialogo_pausa.hide()
		_pausa.grab_focus()
	var mostrar_dicas: bool = preferencias == null or preferencias.dicas
	if mostrar_dicas and not _dicas_ativas:
		_ajuda_restante = DURACAO_AJUDA
		if not has_node("TituloFase"):
			_criar_dica.call_deferred()
	_dicas_ativas = mostrar_dicas
	if partida.estado == partida.Estado.JOGANDO and mostrar_dicas:
		_ajuda_restante = maxf(0, _ajuda_restante - delta)
	if OS.has_feature("android") and (_area_fisica != Rect2(DisplayServer.get_display_safe_area()) or _transformacao_tela != get_viewport().get_screen_transform()):
		_atualizar_area_segura()
	_status.text = str(partida.nave.combustivel)
	_status.tooltip_text = "Combustível: %d" % partida.nave.combustivel
	_estrelas.text = "%d/%d" % [partida.quantidade_coletada("gold"), partida.nivel.quantidade_estrelas("gold")]
	_estrelas.tooltip_text = "Douradas: classificação e acesso aos conjuntos. Só valem ao chegar à Terra."
	_estrelas.accessibility_name = "Estrelas coletadas: " + _estrelas.text + ". Só valem ao chegar à Terra."
	_estrelas.visible = not partida.nivel.estrelas.is_empty()
	_icone_estrelas.visible = _estrelas.visible
	_indicadores.tempo = partida.tempo_restante
	_indicadores.duracao = partida.nivel.tempo_voo
	_indicadores.tooltip_text = "Oxigênio: %.1f s" % partida.tempo_restante
	_indicadores.accessibility_name = _indicadores.tooltip_text
	_indicadores.queue_redraw()
	_bussola.atualizar()
	_pausa.text = "Retomar" if partida.estado == partida.Estado.PAUSADO else ""
	_pausa.icon = Icones.obter("jogar" if partida.estado == partida.Estado.PAUSADO else "pausa")
	_pausa.tooltip_text = "Retomar" if partida.estado == partida.Estado.PAUSADO else "Pausar"
	_pausa.disabled = partida.estado in [partida.Estado.PERDIDA, partida.Estado.CONCLUIDA]
	_explorar.icon = Icones.obter("olho")
	_explorar.tooltip_text = "Voltar à nave" if partida.explorando else "Observar mapa"
	_explorar.accessibility_name = _explorar.tooltip_text
	_pausa.accessibility_name = _pausa.tooltip_text
	_explorar.disabled = partida.estado != partida.Estado.JOGANDO
	_explorar.visible = partida.estado == partida.Estado.JOGANDO
	_reiniciar.visible = partida.estado == partida.Estado.PERDIDA
	_zoom_controles.visible = partida.explorando and partida.estado == partida.Estado.JOGANDO
	_reiniciar.text = "" if partida.estado == partida.Estado.JOGANDO else ("Repetir" if partida.estado == partida.Estado.CONCLUIDA else "Reiniciar")
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
		var em_voo: bool = partida.nave.condicao in [partida.nave.Condicao.EM_VOO, partida.nave.Condicao.A_DERIVA]
		_mensagem.text = "Arraste para explorar.\n" + ("O oxigênio continua diminuindo." if em_voo else "Pousar interrompe o gasto de oxigênio.")
	elif partida.nave.combustivel == 0:
		_mensagem.text = "Sem combustível.\nÀ deriva até o oxigênio acabar."
	elif partida.nivel.id == "teste_001":
		_mensagem.text = _dica_tutorial()
	elif partida.nave.condicao in [partida.nave.Condicao.EM_VOO, partida.nave.Condicao.A_DERIVA]:
		_mensagem.text = "Arraste para corrigir."
	else:
		var dica := str(partida.nivel.dados_autorais.get("tutorial", "")).strip_edges()
		_mensagem.text = dica if not dica.is_empty() else "Arraste e solte para lançar.\nCírculo cancela. Linha indica direção."
	var jogando: bool = partida.estado == partida.Estado.JOGANDO
	_mensagem.visible = false
	_mensagem.modulate.a = clampf(_ajuda_restante / 0.4, 0, 1) if jogando else 1.0
	var avisos := PackedStringArray()
	var perigos := 0
	for id_corpo in partida.proximos:
		if id_corpo == partida.nave.corpo_apoio:
			continue
		var tipo: String = partida.proximos[id_corpo]
		if tipo in ["sun", "asteroid"]:
			perigos += 1
	if perigos > 0:
		avisos.append("Perigo próximo")
	_alerta.text = "  ".join(avisos)
	if not partida.aviso_salvamento.is_empty():
		_alerta.text += "\n" + partida.aviso_salvamento
	_alerta.visible = not _alerta.text.is_empty()
	_ajustar_rodape()


func _criar_dica() -> void:
	if has_node("DialogoDica"):
		return
	if preferencias != null and not preferencias.dicas:
		return
	var texto := str(partida.nivel.dados_autorais.get("tutorial", "")).strip_edges()
	if partida.estado != partida.Estado.JOGANDO:
		return
	if texto.is_empty():
		texto = "Arraste e solte para lançar. Volte ao círculo para cancelar."
	var dialogo := Control.new()
	dialogo.name = "DialogoDica"
	# A bússola usa z_index próprio e não deve atravessar o texto da dica.
	dialogo.z_index = 10
	dialogo.process_mode = Node.PROCESS_MODE_ALWAYS
	dialogo.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dialogo)
	dialogo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if partida.nivel.id == "teste_001":
		var tutorial := Tutorial.new()
		tutorial.fechada.connect(dialogo.queue_free)
		dialogo.add_child(tutorial)
		return
	var fundo := ColorRect.new()
	fundo.color = Color(0.015, 0.025, 0.06, 0.8)
	dialogo.add_child(fundo)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var centro := CenterContainer.new()
	dialogo.add_child(centro)
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var painel := PanelContainer.new()
	painel.theme = Tema.criar()
	painel.add_theme_stylebox_override("panel", Tema.painel())
	centro.add_child(painel)
	var coluna := VBoxContainer.new()
	coluna.custom_minimum_size.x = minf(180, get_viewport().get_visible_rect().size.x - 32)
	coluna.add_theme_constant_override("separation", 12)
	painel.add_child(coluna)
	var dica := rotulo(coluna, texto, Tema.TAMANHO_TEXTO_AJUDA)
	dica.custom_minimum_size.x = coluna.custom_minimum_size.x
	dica.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dica.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var linha := CenterContainer.new()
	coluna.add_child(linha)
	var confirmar := botao(linha, "OK", func():
		dialogo.queue_free()
		get_tree().paused = false
	)
	confirmar.custom_minimum_size = Vector2(64, 32)
	get_tree().paused = true
	confirmar.grab_focus()


func _apresentar_fase() -> void:
	partida.apresentando_fase = true
	var titulo := TituloFase.new()
	titulo.titulo = partida.nivel.nome
	titulo.ordem = partida.nivel.ordem
	add_child(titulo)
	titulo.terminou.connect(func():
		partida.apresentando_fase = false
		_criar_dica())
