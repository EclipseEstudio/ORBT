extends Control

const AreaSegura = preload("res://src/Nivel/interface_partida.gd")
signal fase_escolhida(id: String)
signal voltar
signal recarregar
var itens: Array = []
var progresso: RefCounted
var erros: Array = []
var cartoes: VBoxContainer
var mensagem: Label
var _margem: MarginContainer
var _ocupada := false
var _segura := Rect2()
var _transformacao := Transform2D()
var _nota: Label
var _tentar_salvar: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var fundo := ColorRect.new()
	fundo.color = Color("0b1423")
	fundo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fundo)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_margem = MarginContainer.new()
	add_child(_margem)
	_margem.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for lado in ["left", "top", "right", "bottom"]:
		_margem.add_theme_constant_override("margin_" + lado, 8)
	var coluna := VBoxContainer.new()
	_margem.add_child(coluna)
	_rotulo(coluna, "Campanha", 18)
	_nota = _rotulo(coluna, progresso.descricao() if progresso != null else "", 9)
	mensagem = _rotulo(coluna, "", 10)
	var rolagem := ScrollContainer.new()
	rolagem.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rolagem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	coluna.add_child(rolagem)
	cartoes = VBoxContainer.new()
	cartoes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rolagem.add_child(cartoes)
	_tentar_salvar = _botao(coluna, "Tentar salvar novamente", func():
		progresso.salvar()
		_nota.text = progresso.descricao()
		_tentar_salvar.visible = progresso.salvamento_pendente(), 40)
	_botao(coluna, "Atualizar lista", func(): recarregar.emit(), 28)
	_botao(coluna, "Voltar ao menu", func(): voltar.emit(), 40)
	atualizar(itens, erros)
	get_viewport().size_changed.connect(_area_segura)
	_area_segura()


func _rotulo(pai: Node, texto: String, fonte: int) -> Label:
	var rotulo := Label.new()
	rotulo.text = texto
	rotulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rotulo.add_theme_font_size_override("font_size", fonte)
	pai.add_child(rotulo)
	return rotulo


func _botao(pai: Node, texto: String, acao: Callable, altura: int) -> Button:
	var botao := Button.new()
	botao.text = texto
	botao.custom_minimum_size.y = altura
	botao.add_theme_font_size_override("font_size", 11)
	botao.pressed.connect(acao)
	pai.add_child(botao)
	return botao


func atualizar(novos: Array, diagnosticos: Array) -> void:
	itens = novos
	erros = diagnosticos
	if not is_instance_valid(cartoes):
		return
	_ocupada = false
	_nota.text = progresso.descricao() if progresso != null else ""
	_tentar_salvar.visible = progresso != null and progresso.salvamento_pendente()
	for filho in cartoes.get_children():
		cartoes.remove_child(filho)
		filho.queue_free()
	mensagem.text = "\n".join(erros) if not erros.is_empty() else ("Nenhuma fase cadastrada." if itens.is_empty() else "Escolha uma fase")
	for item in itens:
		var cartao := VBoxContainer.new()
		cartao.add_theme_constant_override("separation", 3)
		cartoes.add_child(cartao)
		_rotulo(cartao, "%02d · %s" % [item.ordem, item.nome], 12)
		var estado: String = progresso.estado(item.id)
		_rotulo(cartao, estado, 10)
		var botao := _botao(cartao, "Repetir" if estado == "Concluída" else "Jogar", func(): escolher(item.id), 48)
		botao.disabled = not progresso.pode_abrir(item.id)
		if botao.disabled:
			botao.text = "Bloqueada"


func escolher(id: String) -> void:
	if _ocupada:
		return
	if progresso == null or not progresso.pode_abrir(id) or not itens.any(func(item: Dictionary): return item.id == id):
		mensagem.text = "Fase bloqueada ou indisponível."
		return
	_ocupada = true
	mensagem.text = "Abrindo fase…"
	# Esperar a GUI encerrar o toque antes de instalar o novo mundo.
	fase_escolhida.emit.call_deferred(id)


func falhou(texto: String) -> void:
	_ocupada = false
	mensagem.text = texto


func _area_segura() -> void:
	var viewport := get_viewport().get_visible_rect()
	_segura = Rect2(DisplayServer.get_display_safe_area()) if OS.has_feature("android") else Rect2()
	_transformacao = get_viewport().get_screen_transform()
	var area := AreaSegura.area_segura_logica(_segura, _transformacao, viewport)
	_margem.offset_left = area.position.x
	_margem.offset_top = area.position.y
	_margem.offset_right = area.end.x - viewport.end.x
	_margem.offset_bottom = area.end.y - viewport.end.y


func _process(_delta: float) -> void:
	if OS.has_feature("android") and (_segura != Rect2(DisplayServer.get_display_safe_area()) or _transformacao != get_viewport().get_screen_transform()):
		_area_segura()
