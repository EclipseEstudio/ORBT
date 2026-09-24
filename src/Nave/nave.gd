extends RigidBody2D

@export var torque := 100.0      # Aumentado: torques físicos em Godot exigem valores altos
@export var torque_damping := 100.0
@export var impulso := 10.0

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
	if pressionado:
		var direcao_alvo = posicao_inicial_touch - posicao_atual_touch
		
		if direcao_alvo == Vector2.ZERO:
			return
		var direcao_atual_do_corpo = Vector2.UP.rotated(global_rotation)
		var angulo = direcao_atual_do_corpo.angle_to(direcao_alvo) 
		var torque_necessario = (angulo * torque) - (state.angular_velocity * torque_damping)
		state.apply_torque(torque_necessario)
	elif not pressionado and vetor_forca != Vector2.ZERO:
		state.apply_central_impulse(vetor_forca)
		vetor_forca = Vector2.ZERO
		
