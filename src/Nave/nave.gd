extends Node2D
## Estado físico da nave. A mesma simulação discreta alimenta o voo e a prévia.

signal impulso_aplicado(gesto_id: int)
signal contato_detectado(contato: Dictionary)
signal combustivel_alterado(saldo: int)
signal condicao_alterada

enum Condicao { POUSADA, EM_VOO, A_DERIVA }
const Fisica = preload("res://src/Nave/simulacao_voo.gd")

@onready var rcs_direito: GPUParticles2D = $RCSDireito
@onready var rcs_esquerdo: GPUParticles2D = $RCSEsquerdo
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var entrada = $Entrada

var condicao := Condicao.EM_VOO
var velocidade := Vector2.ZERO
var combustivel := 5
var massa := 1.0
var raio := 8.0
var corpo_apoio := ""
var posicao_relativa := Vector2.ZERO
var origem_decolagem := ""
var corpos: Array = []
var fisica: Dictionary = {"gravity_constant": 1.0, "softening": 8.0}
var limites := Rect2(-100000, -100000, 200000, 200000)
var simulacao_automatica := true
var simulacao_ativa := true
var controle_permitido := true
var _pedidos: Array[Dictionary] = []
var _ultimo_pedido := -1


func _ready() -> void:
	entrada.impulso_solicitado.connect(_preparar_impulso)
	entrada.gesto_cancelado.connect(cancelar_pedidos)
	animation_player.play("default")


func configurar(nivel: NivelRes) -> void:
	cancelar_pedidos()
	corpos = nivel.corpos.duplicate(true)
	fisica = nivel.fisica.duplicate(true)
	limites = nivel.limites
	massa = nivel.parametros_nave.mass
	raio = nivel.parametros_nave.radius
	combustivel = nivel.combustivel_inicial
	entrada.configurar(nivel.parametros_nave)
	origem_decolagem = ""
	# IDs continuam monotônicos para rejeitar eventos atrasados da tentativa anterior.
	entrada.ultimo_gesto = maxi(entrada.ultimo_gesto, _ultimo_pedido)
	simulacao_ativa = true
	controle_permitido = true
	var apoio := nivel.obter_corpo(nivel.inicio.body_id)
	var normal := Vector2.RIGHT.rotated(deg_to_rad(nivel.inicio.angle_degrees))
	global_position = apoio.position + normal * (apoio.collision_radius + raio)
	pousar(apoio)
	combustivel_alterado.emit(combustivel)
	animation_player.play("default")
	atualizar_entrada()


func _preparar_impulso(impulso: Vector2) -> void:
	solicitar_impulso(entrada.ultimo_gesto, impulso)


func solicitar_impulso(gesto_id: int, impulso: Vector2) -> bool:
	if gesto_id <= _ultimo_pedido or not simulacao_ativa or not entrada.pode_controlar():
		return false
	if combustivel <= _pedidos.size() or not impulso.is_finite() or impulso.is_zero_approx() or impulso.length() > entrada.impulso_maximo + 0.001:
		return false
	_ultimo_pedido = gesto_id
	_pedidos.append({"id": gesto_id, "impulso": impulso})
	return true


func cancelar_pedidos() -> void:
	_pedidos.clear()
	if is_node_ready():
		rcs_direito.emitting = false
		rcs_esquerdo.emitting = false


func atualizar_entrada() -> void:
	entrada.habilitada = controle_permitido and simulacao_ativa and combustivel > 0


func _physics_process(delta: float) -> void:
	if simulacao_automatica:
		avancar(delta)


func aplicar_pedidos() -> void:
	if not simulacao_ativa or get_tree().paused:
		return
	var pedidos := _pedidos.duplicate()
	_pedidos.clear()
	for pedido in pedidos:
		if not entrada.pode_controlar() or combustivel <= 0:
			break
		if condicao == Condicao.POUSADA:
			velocidade = Vector2.ZERO
			origem_decolagem = corpo_apoio
			corpo_apoio = ""
			posicao_relativa = Vector2.ZERO
		velocidade += pedido.impulso / massa
		combustivel -= 1
		condicao = Condicao.A_DERIVA if combustivel == 0 else Condicao.EM_VOO
		animation_player.play("fogo")
		combustivel_alterado.emit(combustivel)
		impulso_aplicado.emit(pedido.id)
		condicao_alterada.emit()
	atualizar_entrada()


func avancar(delta: float) -> Dictionary:
	if not simulacao_ativa or get_tree().paused:
		return {}
	aplicar_pedidos()
	_atualizar_orientacao(delta)
	if condicao == Condicao.POUSADA:
		return {}
	var resultado := Fisica.passo(global_position, velocidade, delta, corpos, fisica, limites, raio, origem_decolagem)
	global_position = resultado.position
	velocidade = resultado.velocity
	if not resultado.contact.is_empty():
		contato_detectado.emit(resultado.contact)
	return resultado.contact


func pousar(corpo: Dictionary) -> void:
	var normal: Vector2 = (global_position - corpo.position).normalized()
	if normal.is_zero_approx():
		normal = Vector2.UP
	posicao_relativa = normal * (corpo.collision_radius + raio)
	global_position = corpo.position + posicao_relativa
	global_rotation = normal.angle() + PI / 2.0
	corpo_apoio = corpo.id
	origem_decolagem = ""
	velocidade = Vector2.ZERO
	condicao = Condicao.POUSADA
	condicao_alterada.emit()


func parar() -> void:
	simulacao_ativa = false
	velocidade = Vector2.ZERO
	entrada.cancelar()
	atualizar_entrada()
	animation_player.play("default")


func prever_trajetoria() -> PackedVector2Array:
	var impulso: Vector2 = entrada.gesto.obter_impulso()
	if not entrada.pode_controlar() or impulso.is_zero_approx():
		return PackedVector2Array()
	var velocidade_inicial := Vector2.ZERO if condicao == Condicao.POUSADA else velocidade
	var origem := corpo_apoio if condicao == Condicao.POUSADA else origem_decolagem
	return Fisica.prever(global_position, velocidade_inicial + impulso / massa, corpos, fisica, limites, raio, origem, 180, 1.0 / Engine.physics_ticks_per_second)


func _atualizar_orientacao(delta: float) -> void:
	var direcao: Vector2 = entrada.gesto.obter_impulso()
	rcs_direito.emitting = false
	rcs_esquerdo.emitting = false
	if direcao.is_zero_approx() or condicao == Condicao.POUSADA:
		return
	var angulo := Vector2.UP.rotated(global_rotation).angle_to(direcao)
	rcs_esquerdo.emitting = angulo > 0.05
	rcs_direito.emitting = angulo < -0.05
	global_rotation = rotate_toward(global_rotation, direcao.angle() + PI / 2.0, 5.0 * delta)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"fogo":
		animation_player.play("default")
