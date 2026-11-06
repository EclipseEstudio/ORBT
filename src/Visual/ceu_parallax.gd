extends Control
## Três camadas sem colisão. Câmera e sensores alteram somente o desenho.
var camera: Camera2D
var inclinacao := Vector2.ZERO
var deslocamento := Vector2.ZERO
var animar := false
var _tempo := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(queue_redraw)

func atualizar_sensor(giro: Vector3, delta: float) -> void:
	# Integrar rad/s, limitar o movimento e recentralizar para conter deriva.
	if not giro.is_finite():
		return
	inclinacao += Vector2(-giro.y, giro.x) * minf(delta, 0.1)
	inclinacao = inclinacao.limit_length(0.7) * exp(-delta * 0.35)
	deslocamento = deslocamento.lerp(inclinacao * 14.0, 1.0 - exp(-delta * 8.0))

func _process(delta: float) -> void:
	_tempo += delta
	if OS.has_feature("android") or OS.has_feature("ios"):
		atualizar_sensor(Input.get_gyroscope(), delta)
	queue_redraw()

func _draw() -> void:
	if size.x <= 0 or size.y <= 0:
		return
	var sorteio := RandomNumberGenerator.new()
	sorteio.seed = 731
	for camada in range(3):
		var fator := 0.25 + camada * 0.45
		var offset := deslocamento * fator
		if is_instance_valid(camera):
			offset -= camera.global_position * (0.02 + camada * 0.035)
		if animar:
			offset += Vector2(_tempo * 0.4, _tempo * 0.15) * fator
		for indice in range(35 + camada * 10):
			var ponto := Vector2(sorteio.randf() * size.x, sorteio.randf() * size.y) + offset
			ponto = Vector2(fposmod(ponto.x, size.x), fposmod(ponto.y, size.y)).floor()
			var cor: Color = [Color("273451"), Color("596d91"), Color("b5d9ed")][camada]
			draw_rect(Rect2(ponto, Vector2.ONE), cor)
