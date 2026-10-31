extends SceneTree
const F = preload("res://src/Nave/simulacao_voo.gd")
const C = preload("res://src/Nivel/carregador_fase.gd")
const Cena = preload("res://src/Nivel/Nivel.tscn")
const Disco = preload("res://src/Campanha/checkpoint_persistente.gd")
var verificacoes := 0
var falhas := 0
func verificar(ok: bool, texto: String):
	verificacoes += 1
	if not ok:
		falhas += 1
		printerr(texto)
func _initialize(): executar.call_deferred()
func executar():
	var dados = JSON.parse_string(FileAccess.get_file_as_string("res://Recursos/Fases/demo_rotacao.json"))
	var r = C.validar(dados)
	verificar(r.nivel != null, "Demo válida")
	if r.nivel == null: quit(1); return
	var corpo: Dictionary = r.nivel.corpos[0]
	verificar(absf(F.rotacao_corpo(corpo,3)-PI/2)<0.00001,"Rotação após três segundos")
	verificar(F.pouso_seguro(corpo,Vector2.UP,0),"Pouso na faixa inicial")
	verificar(not F.pouso_seguro(corpo,Vector2.DOWN,0),"Pouso fora da faixa")
	verificar(F.pouso_seguro(corpo,Vector2.RIGHT,3),"Faixa acompanha rotação")
	verificar(F.pouso_seguro(corpo,Vector2.RIGHT.rotated(deg_to_rad(-45)),0),"Borda inclusiva")
	var estatico = corpo.duplicate(true)
	estatico.erase("landing_zone")
	verificar(F.pouso_seguro(estatico,Vector2.DOWN,0),"Sem faixa permite qualquer ponto")
	for configuracao in [{"rotation":{"degrees_per_second":NAN}},{"rotation":{"degrees_per_second":361}},{"landing_zone":{"center_degrees":0,"half_width_degrees":0}},{"landing_zone":"invalido"}]:
		var errado = dados.duplicate(true)
		for campo in configuracao: errado.bodies[0][campo]=configuracao[campo]
		verificar(C.validar(errado).nivel==null,"Rejeitar configuração inválida")
	var errado = dados.duplicate(true)
	errado.goal.landing_zone={"center_degrees":0,"half_width_degrees":45}
	verificar(C.validar(errado).nivel==null,"Faixa exclusiva de apoio")
	var nivel=Cena.instantiate()
	nivel.nivel_res=r.nivel
	root.add_child(nivel)
	await process_frame
	var p=nivel.partida
	p.set_physics_process(false)
	nivel.camera._process(2.0)
	var nave=nivel.get_node("Nave")
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	p.reiniciar()
	nivel.camera._process(2.0)
	var relativo: Vector2=nave.posicao_relativa
	for i in range(60): p.avancar(1.0/60)
	verificar(nave.posicao_relativa.distance_to(relativo.rotated(PI/6))<0.001,"Nave transportada pela superfície")
	verificar(absf(angle_difference(nave.global_rotation,nave.posicao_relativa.angle()+PI/2))<0.001,"Orientação acompanha apoio")
	verificar(nave.velocidade_apoio().distance_to(F.velocidade_corpo(corpo,nave.tempo_simulacao)+F.velocidade_superficie(corpo,nave.posicao_relativa))<0.001,"Herança soma órbita e superfície")
	p._registrar_checkpoint()
	var cp=p._checkpoint.duplicate(true)
	var disco=Disco.new()
	disco.dados=cp.duplicate(true)
	for campo in ["posicao","posicao_relativa"]:
		var ponto:Vector2=disco.dados[campo]
		disco.dados[campo]=[ponto.x,ponto.y]
	disco.dados.content_version=1
	verificar(not disco.validar(r.nivel).is_empty(),"Checkpoint giratório válido")
	p.pausar()
	p.avancar(1)
	verificar(nave.posicao_relativa==cp.posicao_relativa,"Pausa congela superfície")
	verificar(p.restaurar_checkpoint(),"Restaura checkpoint")
	nivel.camera._process(2.0)
	for i in range(60): p.avancar(1.0/60)
	verificar(nave.posicao_relativa.distance_to(cp.posicao_relativa.rotated(PI/6))<0.001,"Continua rotação após recuperar")
	var heranca:Vector2=nave.velocidade_apoio()
	var impulso:Vector2=nave.posicao_relativa.normalized()*80
	verificar(nave.solicitar_impulso(nave._ultimo_pedido+1,impulso),"Decolagem aceita")
	nave.aplicar_pedidos()
	verificar(nave.velocidade.distance_to(heranca+impulso)<0.001,"Decolagem herda giro")
	p.reiniciar()
	p.resolver_contato({"kind":"body","body":corpo,"safe_landing":false})
	verificar(p.motivo=="Pouso fora da faixa segura" and p.estado==p.Estado.PERDIDA,"Contato inseguro encerra")
	p.reiniciar()
	verificar(nave.tempo_simulacao==0 and nave.posicao_relativa.distance_to(relativo)<0.001,"Reinício restaura giro")
	# Chegada na superfície inferior, fora do setor superior.
	var simples=corpo.duplicate(true)
	simples.erase("orbit")
	simples.position=Vector2.ZERO
	var hit=F.varrer(Vector2(0,50),Vector2(0,0),Vector2(0,-100),1.0/60,[simples],Rect2(-100,-100,200,200),8)
	verificar(not hit.contact.is_empty() and not hit.contact.safe_landing,"Integrador classifica contato angular")
	root.remove_child(nivel)
	nivel.free()
	print("Rotação: %d verificações, %d falhas." % [verificacoes,falhas])
	quit(1 if falhas else 0)
