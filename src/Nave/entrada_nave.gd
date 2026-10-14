extends Node
## Mouse usa a emulação de toque da Godot; há apenas um caminho de entrada.

signal impulso_solicitado(impulso: Vector2)
signal gesto_cancelado
signal mira_encerrada

const Gesto = preload("res://src/Nave/gesto_mira.gd")

@export_range(0.0, 100.0) var zona_morta := 10.0
@export_range(1.0, 500.0) var arraste_maximo := 80.0
@export_range(1.0, 1000.0) var impulso_maximo := 80.0

var habilitada := true:
	set(valor):
		if habilitada == valor:
			return
		habilitada = valor
		if not valor:
			cancelar()

var gesto := Gesto.new()
var ultimo_gesto := 0
var _tem_foco := true
var _eventos_aguardando_interface: Dictionary[int, bool] = {}


func _ready() -> void:
	gesto.zona_morta = zona_morta
	gesto.arraste_maximo = arraste_maximo
	gesto.impulso_maximo = impulso_maximo
	get_viewport().size_changed.connect(cancelar)


func configurar(parametros: Dictionary) -> void:
	cancelar()
	zona_morta = parametros.dead_zone
	arraste_maximo = parametros.max_drag
	impulso_maximo = parametros.max_impulse
	gesto.zona_morta = zona_morta
	gesto.arraste_maximo = arraste_maximo
	gesto.impulso_maximo = impulso_maximo


func _input(event: InputEvent) -> void:
	# Uma liberação/arraste capturada pela interface também deve encerrar a mira.
	# A decisão espera a GUI; nenhum impulso é produzido antes dela.
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if gesto.contato_ativo != -1 and event.index == gesto.contato_ativo:
			if event is InputEventScreenTouch and event.canceled:
				encerrar_mira()
				return
			var evento_id := event.get_instance_id()
			_eventos_aguardando_interface[evento_id] = true
			_cancelar_evento_consumido.call_deferred(evento_id)


func _unhandled_input(event: InputEvent) -> void:
	_eventos_aguardando_interface.erase(event.get_instance_id())
	if not pode_controlar():
		return
	if event is InputEventScreenTouch:
		if event.canceled:
			if event.index == gesto.contato_ativo:
				encerrar_mira()
		elif event.pressed:
			if gesto.iniciar(event.index, event.position):
				get_viewport().set_input_as_handled()
		elif event.index == gesto.contato_ativo:
			var impulso := gesto.soltar(event.index, event.position)
			get_viewport().set_input_as_handled()
			if impulso != Vector2.ZERO:
				ultimo_gesto += 1
				impulso_solicitado.emit(impulso)
			else:
				encerrar_mira()
	elif event is InputEventScreenDrag and event.index == gesto.contato_ativo:
		gesto.mover(event.index, event.position)
		get_viewport().set_input_as_handled()
		if gesto.contato_ativo == -1:
			encerrar_mira()


func pode_controlar() -> bool:
	return habilitada and _tem_foco and is_inside_tree() and can_process()


func cancelar() -> void:
	encerrar_mira()
	gesto_cancelado.emit()


func encerrar_mira() -> void:
	gesto.cancelar()
	_eventos_aguardando_interface.clear()
	mira_encerrada.emit()


func _cancelar_evento_consumido(evento_id: int) -> void:
	if _eventos_aguardando_interface.has(evento_id):
		encerrar_mira()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_WM_WINDOW_FOCUS_OUT:
			_tem_foco = false
			cancelar()
		NOTIFICATION_APPLICATION_FOCUS_IN, NOTIFICATION_APPLICATION_RESUMED, NOTIFICATION_WM_WINDOW_FOCUS_IN:
			_tem_foco = true
		NOTIFICATION_PAUSED, NOTIFICATION_DISABLED, NOTIFICATION_EXIT_TREE:
			cancelar()
