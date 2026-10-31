extends SceneTree
const C = preload("res://src/Nivel/carregador_fase.gd")
const F = preload("res://src/Nave/simulacao_voo.gd")
const Cena = preload("res://src/Nivel/Nivel.tscn")
const Persistencia = preload("res://src/Campanha/checkpoint_persistente.gd")
var verificacoes := 0
var falhas := 0
func verificar(ok: bool, texto: String):
	verificacoes += 1
	if not ok:
		falhas += 1
		printerr(texto)
func _initialize(): executar.call_deferred()
func executar():
	var dados = JSON.parse_string(FileAccess.get_file_as_string("res://Recursos/Fases/demo_orbitas.json"))
	var r = C.validar(dados)
	verificar(r.nivel != null, "Demonstração válida")
	if r.nivel == null: quit(1); return
	var corpo = r.nivel.corpos[0]
	verificar(F.posicao_corpo(corpo, 3).distance_to(Vector2(30,310)) < 0.001, "Quarto de volta")
	verificar(F.posicao_corpo(corpo, 12).distance_to(corpo.position) < 0.001, "Volta completa")
	var v = (F.posicao_corpo(corpo, 0.001)-corpo.position)/0.001
	verificar(v.distance_to(F.velocidade_corpo(corpo,0)) < 0.02, "Velocidade tangencial")
	for campo in ["center", "period_seconds", "clockwise"]:
		var invalido = dados.duplicate(true)
		invalido.bodies[0].orbit[campo] = "inválido"
		verificar(C.validar(invalido).nivel == null, "Rejeitar " + campo)
	var nivel = Cena.instantiate()
	nivel.nivel_res=r.nivel
	root.add_child(nivel)
	await process_frame
	var p = nivel.partida
	p.set_physics_process(false)
	nivel.camera._process(2.0)
	var nave = nivel.get_node("Nave")
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	for i in range(60): p.avancar(1.0/60)
	verificar(nave.condicao == nave.Condicao.POUSADA, "Permanece pousada")
	verificar(nave.global_position.distance_to(F.posicao_corpo(corpo,nave.tempo_simulacao)+nave.posicao_relativa)<0.001,"Transportada pelo apoio")
	p._registrar_checkpoint()
	var checkpoint = p._checkpoint.duplicate(true)
	var disco = Persistencia.new()
	disco.dados=checkpoint.duplicate(true)
	for campo in ["posicao", "posicao_relativa"]:
		var ponto: Vector2 = disco.dados[campo]
		disco.dados[campo]=[ponto.x,ponto.y]
	disco.dados.content_version=1
	verificar(not disco.validar(r.nivel).is_empty(), "Checkpoint aceita posição orbital")
	p.pausar()
	var t: float = nave.tempo_simulacao
	p.avancar(2)
	verificar(nave.tempo_simulacao==t,"Pausa congela órbita")
	p.retomar()
	var heranca: Vector2 = nave.velocidade_apoio()
	var origem: Vector2 = nave.global_position
	var mundo_antes = var_to_str(nave.corpos)
	nave.entrada.gesto.iniciar(0,Vector2(90,140))
	nave.entrada.gesto.mover(0,Vector2(90,220))
	var previa = nave.prever_trajetoria()
	nave.entrada.cancelar()
	verificar(var_to_str(nave.corpos)==mundo_antes,"Prévia preserva mundo")
	verificar(nave.solicitar_impulso(nave._ultimo_pedido+1,Vector2(0,-80)),"Decolagem aceita")
	nave.aplicar_pedidos()
	verificar(nave.velocidade.distance_to(heranca+Vector2(0,-80))<0.001,"Herança na decolagem")
	for i in range(3): p.avancar(1.0/60)
	verificar(previa.size()>1 and previa[1].distance_to(nave.global_position)<0.001,"Prévia equivale ao voo orbital")
	verificar(r.nivel.corpos[0].position==Vector2(90,250),"Dados autorais preservados")
	p.pausar()
	verificar(p.restaurar_checkpoint(),"Restaurar checkpoint")
	verificar(absf(nave.tempo_simulacao-checkpoint.tempo_simulacao)<0.00001 and nave.global_position.distance_to(origem)<0.001,"Restaura fase orbital e apoio")
	p.reiniciar()
	verificar(nave.tempo_simulacao==0 and nave.corpos[0].position==Vector2(90,250),"Reiniciar restaura órbita")
	# Um obstáculo atravessa uma nave parada durante o passo.
	var perigo={"id":"movel","type":"asteroid","position":Vector2(20,0),"orbit":{"center":[0,0],"period_seconds":1.0},"collision_radius":0.2,"danger_radius":0.2}
	var hit=F.varrer(Vector2(20,1),Vector2(20,1),Vector2.ZERO,1.0/60,[perigo],Rect2(-100,-100,200,200),0.2)
	verificar(not hit.contact.is_empty(),"Varredura relativa detecta perigo móvel")
	root.remove_child(nivel)
	nivel.free()
	print("Órbitas: %d verificações, %d falhas." % [verificacoes,falhas])
	quit(1 if falhas else 0)
