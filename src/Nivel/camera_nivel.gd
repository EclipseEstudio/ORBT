extends Camera2D

var partida: Node
var _contato := -1
var _ultima_posicao := Vector2.ZERO
var _abertura := 0.0
var _destino := Vector2.ZERO
var _eventos_aguardando_interface: Dictionary[int, bool] = {}


func _configuracao() -> Dictionary:
	return partida.nivel.dados_autorais.get("camera", {})


func _zoom_voo() -> Vector2:
	return Vector2.ONE * float(_configuracao().get("zoom", 1.0))


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
	_destino = partida.nivel.corpos[-1].position
	global_position = _destino
	_abertura = 1.2
	partida.nave.controle_permitido = false
	partida.nave.atualizar_entrada()


func _process(delta: float) -> void:
	if _abertura > 0:
		_abertura = maxf(0, _abertura - delta)
		global_position = _destino.lerp(partida.nave.global_position, 1.0 - _abertura / 1.2)
		if _abertura == 0 and partida.estado == partida.Estado.JOGANDO:
			partida.nave.controle_permitido = not partida.explorando
			partida.nave.atualizar_entrada()
	elif not partida.explorando:
		global_position = partida.nave.global_position


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if _contato != -1 and event.index == _contato:
			if event is InputEventScreenTouch and event.canceled:
				_encerrar_arraste()
				return
			var evento_id := event.get_instance_id()
			_eventos_aguardando_interface[evento_id] = true
			_cancelar_evento_consumido.call_deferred(evento_id)


func _unhandled_input(event: InputEvent) -> void:
	_eventos_aguardando_interface.erase(event.get_instance_id())
	if not partida.explorando or partida.estado != partida.Estado.JOGANDO or _abertura > 0:
		return
	if event is InputEventScreenTouch:
		if event.canceled or not event.pressed:
			if event.index == _contato:
				_encerrar_arraste()
		elif _contato == -1:
			_contato = event.index
			_ultima_posicao = event.position
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and event.index == _contato:
		global_position -= (event.position - _ultima_posicao) / zoom
		_ultima_posicao = event.position
		get_viewport().set_input_as_handled()


func _cancelar() -> void:
	_encerrar_arraste()
	zoom = _zoom_voo()
	if partida.explorando:
		_mostrar_mapa()
	if partida.estado != partida.Estado.JOGANDO or partida.explorando:
		_abertura = 0


func _encerrar_arraste() -> void:
	_contato = -1
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
