extends Camera2D

var partida: Node
var _contato := -1
var _toques: Dictionary[int, Vector2] = {}
var _ultima_posicao := Vector2.ZERO
var _eventos_aguardando_interface: Dictionary[int, bool] = {}
var _zoom_antes_exploracao := Vector2.ONE
var _exploracao_anterior := false
const ZOOM_ARRASTE_MAXIMO := 0.85
const ZOOM_PERTO := 1.65
const SUAVIZACAO_ZOOM := 6.0


static func calcular_zoom_arraste(intensidade: float, base: float) -> float:
	return base * lerpf(ZOOM_PERTO, ZOOM_ARRASTE_MAXIMO, clampf(intensidade, 0.0, 1.0))


func _configuracao() -> Dictionary:
	return partida.nivel.dados_autorais.get("camera", {})


func _zoom_voo() -> Vector2:
	return Vector2.ONE * calcular_zoom_arraste(0.0, float(_configuracao().get("zoom", 1.0)))


func _mostrar_mapa() -> void:
	var configuracao := _configuracao()
	if not configuracao.has("overview"):
		return
	var vista: Dictionary = configuracao.overview
	var tamanho := Vector2(vista["size"][0], vista["size"][1])
	var viewport := get_viewport_rect().size
	var area_util := Rect2(Vector2(12, 70), (viewport - Vector2(24, 180)).max(Vector2(60, 60)))
	zoom = Vector2.ONE * minf(area_util.size.x / tamanho.x, area_util.size.y / tamanho.y)
	var centro := Vector2(vista.position[0], vista.position[1]) + tamanho / 2.0
	global_position = centro + (viewport / 2.0 - area_util.get_center()) / zoom


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	partida.estado_alterado.connect(_cancelar)
	partida.reiniciada.connect(apresentar)
	get_viewport().size_changed.connect(_ao_redimensionar)
	apresentar()


func apresentar() -> void:
	_cancelar()
	zoom = _zoom_voo()
	_zoom_antes_exploracao = zoom
	global_position = partida.nave.global_position
	partida.nave.controle_permitido = partida.estado == partida.Estado.JOGANDO and not partida.explorando
	partida.nave.atualizar_entrada()


func _process(delta: float) -> void:
	if not partida.explorando:
		global_position = partida.nave.global_position
		if partida.estado == partida.Estado.JOGANDO and not get_tree().paused:
			var intensidade: float = partida.nave.entrada.gesto.obter_intensidade()
			var alvo := calcular_zoom_arraste(intensidade, float(_configuracao().get("zoom", 1.0)))
			zoom = zoom.lerp(Vector2.ONE * alvo, 1.0 - exp(-SUAVIZACAO_ZOOM * maxf(0.0, delta)))


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if _toques.has(event.index):
			if event is InputEventScreenTouch and event.canceled:
				_encerrar_arraste()
				return
			var evento_id := event.get_instance_id()
			_eventos_aguardando_interface[evento_id] = true
			_cancelar_evento_consumido.call_deferred(evento_id)


func _unhandled_input(event: InputEvent) -> void:
	_eventos_aguardando_interface.erase(event.get_instance_id())
	if not partida.explorando or partida.estado != partida.Estado.JOGANDO:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		aplicar_zoom(1.15 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 1.15)
		get_viewport().set_input_as_handled()
	elif event is InputEventMagnifyGesture:
		aplicar_zoom(event.factor)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch:
		if event.pressed and not event.canceled and _toques.size() < 2:
			_toques[event.index] = event.position
		elif not event.pressed or event.canceled:
			_toques.erase(event.index)
		if event.canceled or not event.pressed:
			if event.index == _contato:
				_encerrar_arraste()
		elif _contato == -1:
			_contato = event.index
			_ultima_posicao = event.position
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and _toques.has(event.index) and _toques.size() == 2:
		var pontos := _toques.values()
		var distancia: float = pontos[0].distance_to(pontos[1])
		_toques[event.index] = event.position
		pontos = _toques.values()
		if distancia > 1.0:
			aplicar_zoom(pontos[0].distance_to(pontos[1]) / distancia)
		_ultima_posicao = _toques.get(_contato, event.position)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and event.index == _contato:
		_toques[event.index] = event.position
		global_position -= (event.position - _ultima_posicao) / zoom
		_ultima_posicao = event.position
		get_viewport().set_input_as_handled()


func _cancelar() -> void:
	_encerrar_arraste()
	if partida.explorando:
		if not _exploracao_anterior:
			_zoom_antes_exploracao = zoom
			_mostrar_mapa()
	elif _exploracao_anterior:
		zoom = _zoom_antes_exploracao
	_exploracao_anterior = partida.explorando


func _encerrar_arraste() -> void:
	_contato = -1
	_toques.clear()
	_ultima_posicao = Vector2.ZERO
	_eventos_aguardando_interface.clear()


func _ao_redimensionar() -> void:
	_encerrar_arraste()
	if partida.explorando:
		_mostrar_mapa()


func _cancelar_evento_consumido(evento_id: int) -> void:
	if _eventos_aguardando_interface.has(evento_id):
		_encerrar_arraste()


func _notification(what: int) -> void:
	if what in [NOTIFICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_WM_WINDOW_FOCUS_OUT, NOTIFICATION_EXIT_TREE]:
		_encerrar_arraste()


func aplicar_zoom(fator: float) -> void:
	if not partida.explorando or partida.estado != partida.Estado.JOGANDO or not is_finite(fator) or fator <= 0:
		return
	zoom = Vector2.ONE * clampf(zoom.x * fator, 0.05, 4.0)
