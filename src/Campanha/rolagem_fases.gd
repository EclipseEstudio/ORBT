extends ScrollContainer
## O arraste começa também sobre cartões, sem abrir a fase ao soltar.

const LIMIAR := 6.0
var _contato := -2
var _inicio := Vector2.ZERO
var _rolagem_inicial := 0
var _arrastando := false

func _ready() -> void:
	var barra := get_v_scroll_bar()
	for estado in ["scroll", "scroll_focus", "grabber", "grabber_highlight", "grabber_pressed"]:
		var estilo := StyleBoxFlat.new()
		estilo.bg_color = Color("30435a") if estado.begins_with("scroll") else Color("87b6d9")
		estilo.content_margin_left = 1.5
		estilo.content_margin_right = 1.5
		barra.add_theme_stylebox_override(estado, estilo)
	var vazio := ImageTexture.create_from_image(Image.create_empty(1, 1, false, Image.FORMAT_RGBA8))
	for icone in ["increment", "increment_highlight", "increment_pressed", "decrement", "decrement_highlight", "decrement_pressed"]:
		barra.add_theme_icon_override(icone, vazio)

func _input(evento: InputEvent) -> void:
	if not is_visible_in_tree() or evento.device == InputEvent.DEVICE_ID_EMULATION:
		return
	if evento is InputEventScreenTouch:
		if evento.pressed and not evento.canceled:
			_iniciar(evento.index, evento.position)
		elif evento.index == _contato:
			_encerrar()
	elif evento is InputEventScreenDrag and evento.index == _contato:
		_mover(evento.position)
	elif evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT:
		if evento.pressed:
			_iniciar(-1, evento.position)
		elif _contato == -1:
			_encerrar()
	elif evento is InputEventMouseMotion and _contato == -1:
		_mover(evento.position)

func _iniciar(contato: int, ponto: Vector2) -> void:
	if _contato != -2 or not get_global_rect().has_point(ponto):
		return
	if get_v_scroll_bar().visible and get_v_scroll_bar().get_global_rect().has_point(ponto):
		return
	_contato = contato
	_inicio = ponto
	_rolagem_inicial = scroll_vertical
	_arrastando = false

func _mover(ponto: Vector2) -> void:
	var deslocamento := ponto.y - _inicio.y
	if not _arrastando and absf(deslocamento) >= LIMIAR:
		_arrastando = true
		# BaseButton cancela o clique ao receber o início de rolagem.
		_notificar_cartoes(self, NOTIFICATION_SCROLL_BEGIN)
	if _arrastando:
		scroll_vertical = _rolagem_inicial - roundi(deslocamento)
		get_viewport().set_input_as_handled()

func _notificar_cartoes(no: Node, notificacao: int) -> void:
	for filho in no.get_children():
		if filho is BaseButton:
			filho.notification(notificacao)
		_notificar_cartoes(filho, notificacao)

func _encerrar() -> void:
	if _arrastando:
		_notificar_cartoes(self, NOTIFICATION_SCROLL_END)
		get_viewport().set_input_as_handled()
	_contato = -2
	_arrastando = false

func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_WINDOW_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED]:
		_encerrar()
