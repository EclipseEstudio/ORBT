extends Line2D
## Histórico curto em coordenadas de mundo, sem participar da simulação.

const CAPACIDADE := 32
const INTERVALO := 1.0 / 30.0
const VELOCIDADE_MINIMA := 8.0
const LARGURA_TELA := 2.0

var partida: Node
var camera: Camera2D
var _buffer := PackedVector2Array()
var _inicio := 0
var _quantidade := 0
var _acumulado := 0.0


func _ready() -> void:
	name = "RastroNave"
	z_index = -1
	antialiased = false
	gradient = Gradient.new()
	gradient.set_color(0, Color(0.51, 0.94, 0.82, 0.0))
	gradient.set_color(1, Color("82f0d1"))
	_buffer.resize(CAPACIDADE)
	partida.estado_alterado.connect(limpar)
	partida.reiniciada.connect(limpar)
	partida.nave.trajeto_interrompido.connect(limpar)
	partida.nave.condicao_alterada.connect(_ao_mudar_condicao)


func limpar() -> void:
	clear_points()
	_inicio = 0
	_quantidade = 0
	_acumulado = 0.0


func _em_movimento() -> bool:
	var nave = partida.nave
	return partida.estado == partida.Estado.JOGANDO and nave.simulacao_ativa and nave.condicao in [nave.Condicao.EM_VOO, nave.Condicao.A_DERIVA] and nave.velocidade.length() >= VELOCIDADE_MINIMA


func _ao_mudar_condicao() -> void:
	if not _em_movimento():
		limpar()


func _process(_delta: float) -> void:
	width = LARGURA_TELA / maxf(0.001, camera.zoom.x)


func _physics_process(delta: float) -> void:
	if get_tree().paused or not _em_movimento():
		limpar()
		return
	_acumulado += delta
	if _quantidade > 0 and _acumulado < INTERVALO:
		return
	_acumulado = fmod(_acumulado, INTERVALO)
	var posicao: Vector2 = partida.nave.global_position
	if _quantidade > 0 and _buffer[(_inicio + _quantidade - 1) % CAPACIDADE].is_equal_approx(posicao):
		return
	if _quantidade == CAPACIDADE:
		_inicio = (_inicio + 1) % CAPACIDADE
	else:
		_quantidade += 1
	_buffer[(_inicio + _quantidade - 1) % CAPACIDADE] = posicao
	var ordenados := PackedVector2Array()
	ordenados.resize(_quantidade)
	for indice in _quantidade:
		ordenados[indice] = to_local(_buffer[(_inicio + indice) % CAPACIDADE])
	points = ordenados


func _notification(what: int) -> void:
	if what in [NOTIFICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_WM_WINDOW_FOCUS_OUT]:
		limpar()
