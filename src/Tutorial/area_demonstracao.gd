extends Control
## Animação ilustrativa: os toques não comandam a nave da campanha.

const Tema = preload("res://src/Visual/tema_visual.gd")
const NAVE = preload("res://Recursos/Sprites/Identidade/nave_detalhada.png")
const RAIO_CANCELAMENTO := 10.0
enum Modo { DEMONSTRAR_LANCAMENTO, DEMONSTRAR_CANCELAMENTO }

var modo := Modo.DEMONSTRAR_LANCAMENTO
var _tempo := 0.0
var _foco := true


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	custom_minimum_size = Vector2(0, 64)


func configurar(novo_modo: int) -> void:
	modo = novo_modo
	_tempo = 0.0
	queue_redraw()


func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_WM_WINDOW_FOCUS_OUT]:
		_foco = false
	elif what in [NOTIFICATION_APPLICATION_FOCUS_IN, NOTIFICATION_APPLICATION_RESUMED, NOTIFICATION_WM_WINDOW_FOCUS_IN]:
		_foco = true


func _process(delta: float) -> void:
	if not _foco:
		return
	_tempo += delta
	queue_redraw()


func _draw() -> void:
	draw_style_box(Tema.painel(), Rect2(Vector2.ZERO, size))
	for i in 16:
		var estrela := Vector2(fmod(i * 37.0 + 11, maxf(1, size.x - 12)) + 6, fmod(i * 19.0 + 7, maxf(1, size.y - 12)) + 6)
		draw_rect(Rect2(estrela, Vector2.ONE), Color("35506a"))
	var nave := Vector2(size.x * 0.72, size.y * 0.70)
	var origem := Vector2(size.x * 0.28, size.y * 0.32)
	var ciclo := fmod(_tempo, 5.0)
	var alcance := minf(40, size.y * 0.42)
	var arraste := clampf((ciclo - 0.6) / 1.4, 0, 1)
	if modo == Modo.DEMONSTRAR_CANCELAMENTO:
		arraste *= 1.0 - clampf((ciclo - 2.6) / 1.0, 0, 1)
	var ativo := ciclo < 3.6
	var dedo := origem + Vector2.DOWN * alcance * arraste
	if modo == Modo.DEMONSTRAR_LANCAMENTO and ciclo >= 3.0:
		ativo = false
		nave += Vector2.UP * minf(size.y * 0.45, (ciclo - 3.0) * 40)
	if ativo:
		draw_arc(origem, RAIO_CANCELAMENTO, 0, TAU, 32, Tema.DESTAQUE, 1.0)
		draw_line(origem, dedo, Color("ffca70"), 1)
		var vetor := origem - dedo
		if vetor.length() > RAIO_CANCELAMENTO:
			var direcao := vetor.normalized()
			var ponta := nave + direcao * minf(28, vetor.length())
			draw_line(nave, ponta, Tema.DESTAQUE, 2)
			draw_line(ponta, ponta - direcao.rotated(0.6) * 5, Tema.DESTAQUE, 1)
			draw_line(ponta, ponta - direcao.rotated(-0.6) * 5, Tema.DESTAQUE, 1)
		draw_circle(dedo, 4, Color("ffca70"))
		draw_arc(dedo, 7, 0, TAU, 20, Color("ffca7088"), 1)
	# A seta representa a direção do impulso, sem prever a trajetória gravitacional.
	draw_texture_rect(NAVE, Rect2(nave - Vector2(12, 12), Vector2(24, 24)), false)
