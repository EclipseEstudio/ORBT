extends SceneTree
const C = preload("res://src/Nivel/carregador_fase.gd")
const F = preload("res://src/Nave/simulacao_voo.gd")
const Cena = preload("res://src/Nivel/Nivel.tscn")
const Documento = preload("res://addons/orbt_editor/documento.gd")
var verificacoes := 0
var falhas := 0
func verificar(ok: bool, texto: String):
	verificacoes+=1
	if not ok:
		falhas+=1
		printerr(texto)
func _initialize(): executar.call_deferred()
func executar():
	var dados=JSON.parse_string(FileAccess.get_file_as_string("res://Recursos/Fases/demo_portais.json"))
	var r=C.validar(dados)
	verificar(r.nivel!=null,"Demo válida")
	if r.nivel==null: printerr(r.erros); quit(1); return
	for alvo in ["inexistente","portal_a","terra"]:
		var errado=dados.duplicate(true)
		errado.bodies[0].target_id=alvo
		verificar(C.validar(errado).nivel==null,"Destino inválido rejeitado")
	var errado=dados.duplicate(true)
	errado.bodies[1].exit_degrees=90
	errado.bounds["size"]=[500,100]
	verificar(C.validar(errado).nivel==null,"Saída fora dos limites rejeitada")
	errado=dados.duplicate(true)
	errado.bodies[0].rotation={"degrees_per_second":30}
	verificar(C.validar(errado).nivel==null,"Portal móvel rejeitado")
	errado=dados.duplicate(true)
	errado.goal.position=[220,0]
	verificar(C.validar(errado).nivel==null,"Saída sobreposta rejeitada")
	var resultado=F.passo(Vector2.ZERO,Vector2(800,0),0.1,r.nivel.corpos,r.nivel.fisica,r.nivel.limites,8)
	verificar(resultado.get("teleported",false),"Contato rápido atravessa portal")
	verificar(resultado.position.distance_to(Vector2(220.01,0))<0.001,"Saída fora do destino")
	verificar(resultado.velocity==Vector2(800,0),"Módulo preservado e direção da saída aplicada")
	var segundo=F.passo(resultado.position,resultado.velocity,1.0/60,r.nivel.corpos,r.nivel.fisica,r.nivel.limites,8)
	verificar(not segundo.get("teleported",false),"Sem teleporte repetido na saída")
	var doc=Documento.new()
	verificar(doc.abrir("res://Recursos/Fases/demo_portais.json").is_empty(),"Editor abre demo")
	doc.editar(["bodies",0,"id"],"entrada")
	verificar(doc.dados.bodies[1].target_id=="entrada" and doc.validar().nivel!=null,"Renomear preserva par")
	var nivel=Cena.instantiate()
	nivel.nivel_res=r.nivel
	root.add_child(nivel)
	await process_frame
	var p=nivel.partida
	p.set_physics_process(false)
	nivel.camera._process(2)
	var nave=nivel.get_node("Nave")
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	nave.entrada.gesto.iniciar(0,Vector2(90,140))
	nave.entrada.gesto.mover(0,Vector2(10,140))
	var antes=var_to_str(nave.corpos)
	var previa=nave.prever_trajetoria()
	nave.entrada.cancelar()
	var saltos=0
	for ponto in previa:
		if not ponto.is_finite(): saltos+=1
	verificar(saltos==1,"Prévia separa trechos no salto")
	verificar(var_to_str(nave.corpos)==antes,"Prévia não altera mundo")
	verificar(nave.solicitar_impulso(nave._ultimo_pedido+1,Vector2(80,0)),"Lançamento aceito")
	var teleportou=false
	for i in range(120):
		var pos:Vector2=nave.global_position
		p.avancar(1.0/60)
		if nave.global_position.x-pos.x>100:
			teleportou=true
			verificar(nave.combustivel==4,"Portal não cobra combustível")
			verificar(p.tempo_restante<29.6,"Portal não reinicia tempo")
			p.pausar()
			var parada:Vector2=nave.global_position
			p.avancar(1)
			verificar(nave.global_position==parada,"Pausa após salto")
			p.retomar()
		if p.estado!=p.Estado.JOGANDO: break
	verificar(teleportou and p.estado==p.Estado.CONCLUIDA,"Rota atravessa portal e vence")
	verificar(previa[-1].distance_to(nave.global_position)<0.001,"Prévia equivale ao voo após portal")
	p.reiniciar()
	verificar(nave.global_position==Vector2.ZERO and nave.tempo_simulacao==0 and nave.combustivel==5,"Reinício restaura tentativa")
	root.remove_child(nivel)
	nivel.free()
	print("Portais: %d verificações, %d falhas." % [verificacoes,falhas])
	quit(1 if falhas else 0)
