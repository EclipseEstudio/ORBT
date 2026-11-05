extends Node2D
## O estado da partida é a única fonte da coleta, inclusive ao voltar ao pouso.

const Icones = preload("res://src/Visual/icones_ui.gd")
const OURO := Color("ffc845")
var partida: Node
var _brilhos: Array[Dictionary] = []
var _tempo := 0.0


func _ready() -> void:
	z_index = 3
	partida.estrela_coletada.connect(_ao_coletar)
	partida.reiniciada.connect(func():
		_brilhos.clear()
		queue_redraw())


func _ao_coletar(id: String) -> void:
	for estrela in partida.nivel.estrelas:
		if estrela.id == id:
			_brilhos.append({"posicao": estrela.position, "tempo": 0.0})
			break
	queue_redraw()


func _process(delta: float) -> void:
	if partida.estado != partida.Estado.JOGANDO:
		return
	_tempo += delta
	for brilho in _brilhos:
		brilho.tempo += delta
	_brilhos = _brilhos.filter(func(brilho: Dictionary): return brilho.tempo < 0.45)
	queue_redraw()


func _draw() -> void:
	if not is_instance_valid(partida):
		return
	var textura := Icones.obter("estrela")
	for indice in range(partida.nivel.estrelas.size()):
		var estrela: Dictionary = partida.nivel.estrelas[indice]
		if partida.estrelas_coletadas.has(estrela.id):
			continue
		var posicao: Vector2 = estrela.position
		var pulso := 0.5 + 0.5 * sin(_tempo * 3.0 + indice)
		draw_circle(posicao, estrela.radius + 2.0, Color(1.0, 0.65, 0.15, 0.08 + pulso * 0.08))
		draw_texture_rect(textura, Rect2(posicao - Vector2(6, 6), Vector2(12, 12)), false, OURO)
	for brilho in _brilhos:
		var fracao: float = brilho.tempo / 0.45
		var cor := Color(OURO, 1.0 - fracao)
		for direcao in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
			var ponto: Vector2 = brilho.posicao + direcao * (5 + fracao * 13)
			draw_rect(Rect2(ponto.round(), Vector2(2, 2)), cor)
