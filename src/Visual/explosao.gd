extends Node2D
## Fragmentos com velocidades e rotação próprias; efeito apenas visual.

const DURACAO := 0.8
const CORES := [Color("d2e8f5"), Color("93bfdc"), Color("597f9f"), Color("334963"), Color("b2dcf2")]
var tempo := 0.0
var fragmentos: Array[Dictionary] = []

func _ready() -> void:
	z_index = 8
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(36):
		var direcao := Vector2.RIGHT.rotated(rng.randf_range(0, TAU))
		fragmentos.append({
			"velocidade": direcao * rng.randf_range(18, 80),
			"giro": rng.randf_range(-8, 8),
			"angulo": rng.randf_range(0, TAU),
			"tamanho": Vector2(rng.randi_range(1, 3), rng.randi_range(1, 4)),
			"vida": rng.randf_range(0.35, DURACAO),
			"cor": CORES[i % CORES.size()]
		})

func _process(delta: float) -> void:
	tempo += delta
	if tempo >= DURACAO:
		queue_free()
	else:
		queue_redraw()

func _draw() -> void:
	# Clarão breve, com bordas quadradas, seguido por detritos que desaceleram.
	if tempo < 0.12:
		var brilho := 1.0 - tempo / 0.12
		draw_rect(Rect2(Vector2(-7, -3), Vector2(14, 6)), Color(0.8, 0.92, 1.0, brilho))
		draw_rect(Rect2(Vector2(-3, -7), Vector2(6, 14)), Color(0.8, 0.92, 1.0, brilho))
	for fragmento in fragmentos:
		if tempo >= fragmento.vida:
			continue
		var deslocamento: Vector2 = fragmento.velocidade * (1.0 - exp(-2.5 * tempo)) / 2.5
		var cor: Color = fragmento.cor
		cor.a = clampf((fragmento.vida - tempo) / 0.2, 0, 1)
		draw_set_transform(deslocamento.round(), fragmento.angulo + fragmento.giro * tempo)
		draw_rect(Rect2(-fragmento.tamanho / 2.0, fragmento.tamanho), cor)
	draw_set_transform(Vector2.ZERO)
