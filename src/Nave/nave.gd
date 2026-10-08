extends RigidBody2D

@export var torque := 100.0      # Aumentado: torques físicos em Godot exigem valores altos
@export var torque_damping := 200.0
@export var impulso := 10.0
@export var limite_angulo := 0.05
@export var zona_morta := 10.0

@onready var rcs_direito := $RCSDireito
@onready var rcs_esquerdo := $RCSEsquerdo
@onready var animation_player := $AnimationPlayer

var pressionado := false
var posicao_inicial_touch : Vector2
var posicao_atual_touch : Vector2
var vetor_forca : Vector2


func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		posicao_atual_touch = event.position
		
	if event is InputEventScreenTouch:
		if event.pressed and not pressionado:
			posicao_inicial_touch = event.position
			posicao_atual_touch = event.position 
			pressionado = true
		elif not event.pressed and pressionado:
			var posicao_final_touch = event.position
			pressionado = false 
			vetor_forca = posicao_inicial_touch - posicao_final_touch
	

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var diferenca_atual = posicao_inicial_touch - posicao_atual_touch
	if diferenca_atual.length() < zona_morta:
		return

	if pressionado:
		var direcao_alvo = diferenca_atual 
		
		var direcao_atual_do_corpo = Vector2.UP.rotated(global_rotation)
		var angulo = direcao_atual_do_corpo.angle_to(direcao_alvo) 
		
		if angulo > limite_angulo:
			rcs_esquerdo.emitting = true
		elif angulo < -1*limite_angulo: 
			rcs_direito.emitting = true
		else:
			rcs_direito.emitting = false
			rcs_esquerdo.emitting = false

		var torque_necessario = (angulo * torque) - (state.angular_velocity * torque_damping)
		state.apply_torque(torque_necessario)
	elif not pressionado and vetor_forca != Vector2.ZERO:
		state.apply_central_impulse(vetor_forca)
		vetor_forca = Vector2.ZERO
		rcs_direito.emitting = false
		rcs_esquerdo.emitting = false
		animation_player.play("fogo")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	animation_player.play("default")
