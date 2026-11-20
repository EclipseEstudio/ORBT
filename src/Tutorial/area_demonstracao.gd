extends Control
## Animação ilustrativa: os toques não comandam a nave da campanha.

const Tema = preload("res://src/Visual/tema_visual.gd")
const Icones = preload("res://src/Visual/icones_ui.gd")
const NAVE = preload("res://Recursos/Sprites/Identidade/nave_detalhada.png")
const RAIO_CANCELAMENTO := 10.0
enum Modo { DEMONSTRAR_LANCAMENTO, DEMONSTRAR_CANCELAMENTO, POUSO, COMBUSTIVEL, GIRO, SOL, ORBITA, FAIXA_POUSO, PORTAL, NEBULOSA }

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
	if modo == Modo.DEMONSTRAR_LANCAMENTO or modo == Modo.DEMONSTRAR_CANCELAMENTO:
		_desenhar_gesto()
	else:
		_desenhar_recurso()


func _desenhar_gesto() -> void:
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


func _desenhar_recurso() -> void:
	var inicio := size * Vector2(0.14, 0.65)
	var centro := size * 0.5
	var fim := size * Vector2(0.86, 0.30)
	var tempo := fmod(_tempo, 4.0)
	var chegada := clampf(tempo / 1.2, 0.0, 1.0)
	var saida := clampf((tempo - 2.1) / 1.4, 0.0, 1.0)
	var nave := inicio
	match modo:
		Modo.POUSO, Modo.FAIXA_POUSO:
			var contato := centro + Vector2(-17, 0)
			var decolagem := inicio - Vector2(0, size.y * 0.4)
			draw_circle(centro, 13, Color("304f70"))
			draw_arc(centro, 15, 0.75 * PI, 1.25 * PI, 18, Tema.SUCESSO if modo == Modo.FAIXA_POUSO else Tema.DESTAQUE, 2)
			draw_polyline(PackedVector2Array([inicio, contato, decolagem]), Color("587593"))
			nave = inicio.lerp(contato, chegada).lerp(decolagem, saida)
		Modo.COMBUSTIVEL:
			var tanque := size * Vector2(0.48, 0.76)
			var fim_coleta := clampf((tempo - 1.2) / 1.6, 0.0, 1.0)
			draw_polyline(PackedVector2Array([inicio, tanque, fim]), Color("587593"))
			if tempo < 1.2:
				draw_texture_rect(Icones.obter("combustivel"), Rect2(tanque - Vector2(7, 7), Vector2(14, 14)), false, Tema.SUCESSO)
			elif tempo < 2.6:
				draw_string(Tema.FONTE, tanque + Vector2(-7, -12), "+1", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Tema.SUCESSO)
			nave = inicio.lerp(tanque, chegada).lerp(fim, fim_coleta)
		Modo.GIRO:
			draw_circle(centro, 19, Color("304f70"))
			draw_arc(centro, 24, PI, TAU - 0.4, 24, Tema.DESTAQUE, 1)
			var direcao := Vector2.from_angle(PI + minf(tempo / 2.3, 1.0) * (PI - 0.4))
			nave = centro + direcao * (22 + 35 * clampf((tempo - 2.3) / 1.3, 0.0, 1.0))
		Modo.SOL:
			var sol := centro + Vector2(0, 15)
			draw_circle(sol, 16, Tema.PERIGO)
			draw_arc(sol, 26, 0, TAU, 32, Tema.ERRO, 1)
			var caminho := PackedVector2Array()
			for indice in 21:
				var fracao := indice / 20.0
				caminho.append(Vector2(lerpf(inicio.x, fim.x, fracao), sol.y - 12 - sin(fracao * PI) * 25))
			draw_polyline(caminho, Color("587593"))
			nave = caminho[mini(int(tempo * 5.5), 20)]
		Modo.ORBITA:
			draw_circle(centro, 7, Color("304f70"))
			draw_arc(centro, 24, 0, TAU, 32, Color("587593"), 1)
			var angulo := 1.8 + minf(tempo, 2.3) * 1.5
			var radial := Vector2.from_angle(angulo)
			var apoio := centro + radial * 24
			draw_circle(apoio, 7, Tema.DESTAQUE)
			nave = inicio.lerp(apoio, chegada) + radial.orthogonal() * 35 * clampf((tempo - 2.3) / 1.3, 0.0, 1.0)
		Modo.PORTAL:
			var entrada := size * Vector2(0.34, 0.65)
			var destino := size * Vector2(0.66, 0.47)
			draw_circle(entrada, 9, Color("050513"))
			draw_arc(entrada, 9, 0, TAU, 24, Color("b393ff"), 2)
			draw_circle(destino, 9, Color("d6f4ff"))
			draw_arc(destino, 12, 0, TAU, 24, Tema.DESTAQUE, 1)
			nave = inicio.lerp(entrada, chegada) if tempo < 1.2 else destino.lerp(fim, clampf((tempo - 1.2) / 1.6, 0.0, 1.0))
		Modo.NEBULOSA:
			nave = inicio.lerp(fim, tempo / 4.0)
			draw_rect(Rect2(Vector2(1, 1), size - Vector2(2, 2)), Color("4f437a"))
			draw_circle(nave, 22, Tema.FUNDO)
			var obstaculo := centro + Vector2(0, 5)
			if obstaculo.distance_to(nave) < 15:
				draw_circle(obstaculo, 6, Color("68788d"))
			var direcao := (fim - inicio).normalized()
			var seta := nave + direcao * 17
			var lado := direcao.orthogonal() * 3
			draw_colored_polygon(PackedVector2Array([seta + direcao * 3, seta - direcao * 3 - lado, seta - direcao * 3 + lado]), Tema.SUCESSO)
	draw_texture_rect(NAVE, Rect2(nave - Vector2(8, 8), Vector2(16, 16)), false)
