extends SceneTree
const Catalogo = preload("res://src/Campanha/catalogo.gd")
const Carregador = preload("res://src/Nivel/carregador_fase.gd")
const Cena = preload("res://src/Nivel/Nivel.tscn")
const Rotas = preload("res://tests/rotas_nivel3.gd")
const Progresso = preload("res://src/Campanha/progresso_sessao.gd")
const Selecao = preload("res://src/Campanha/selecao_fases.gd")
const Titulo = preload("res://src/Nivel/titulo_fase.gd")
const RECURSOS := [[5,30,0],[3,25,0],[3,25,0],[4,25,0],[4,25,1],[5,25,0],[4,25,0],[4,25,1],[3,25,0],[3,25,0],
	[4,25,0],[3,25,0],[4,20,0],[4,20,1],[5,25,0],[4,25,0],[3,25,0],[6,25,1],[4,25,0],[6,25,1],
	[3,25,0],[3,25,0],[4,25,0],[4,25,0],[3,20,1],[3,20,0],[4,25,0],[4,25,1],[4,20,1],[5,25,1]]
var verificacoes := 0
var falhas := 0
func conferir(ok: bool, mensagem: String) -> void:
	verificacoes += 1
	if not ok:
		falhas += 1
		push_error(mensagem)
func _initialize() -> void:
	executar.call_deferred()

func executar() -> void:
	var catalogo := Catalogo.carregar("res://Recursos/Niveis.json")
	conferir(catalogo.itens.size()==30 and catalogo.erros.is_empty(),"Três níveis de dez fases")
	for i in catalogo.itens.size():
		var item: Dictionary = catalogo.itens[i]
		var resultado := Carregador.carregar(item.arquivo)
		conferir(resultado.nivel!=null,item.id+": "+str(resultado.erros))
		if resultado.nivel==null: continue
		var f: NivelRes = resultado.nivel
		conferir(f.ordem==i+1 and f.combustivel_inicial==RECURSOS[i][0] and f.tempo_voo==RECURSOS[i][1],item.id+": ordem e recursos oficiais")
		conferir(f.combustiveis.size()==RECURSOS[i][2] and f.combustiveis.all(func(t:Dictionary):return t.amount==1),item.id+": disponibilidade exata de tanques +1")
		conferir(f.quantidade_estrelas()==3 and f.quantidade_estrelas("blue")==1,item.id+": estrelas douradas e azul opcionais")
		conferir(f.corpos.all(func(b:Dictionary):return b.type!="asteroid" or (b.visual_radius<=14 and b.mass==0)),item.id+": apenas asteroides pequenos sem gravidade")
		conferir(f.dados_autorais.has("nebula")==((i+1) in [23,24,25,26,27,29,30]),item.id+": nebulosa somente onde prevista")
	var progresso := Progresso.new()
	progresso.configurar(catalogo.itens)
	var selecao := Selecao.new()
	selecao.itens = catalogo.itens
	selecao.progresso = progresso
	root.add_child(selecao)
	conferir(selecao.find_child("Meta11",true,false).get_child(1).text == "0/30", "Seleção mostra meta de 30 para o nível 2")
	conferir(selecao.find_child("Meta21",true,false).get_child(1).text == "0/60", "Seleção mostra meta acumulada de 60 para o nível 3")
	selecao.free()
	for i in range(20):
		progresso.concluir_com_estrelas(catalogo.itens[i].id,catalogo.itens,3)
	conferir(progresso.pode_abrir(catalogo.itens[20].id),"Nível 3 abre após o requisito do segundo")
	for rota in Rotas.ROTAS:
		var f: NivelRes = Carregador.carregar("res://Recursos/Fases/"+rota.id+".json").nivel
		if f==null: continue
		var mundo = Cena.instantiate()
		mundo.nivel_res=f
		root.add_child(mundo)
		mundo.partida.set_physics_process(false)
		var resultado := Rotas.executar(mundo.partida,rota.get("coleta",rota.etapas))
		conferir(resultado.venceu,rota.id+": rota completa possível "+str(resultado.resumo))
		conferir(resultado.douradas==3 and mundo.partida.quantidade_coletada("blue")==1,rota.id+": todas as estrelas alcançáveis")
		conferir(resultado.tanques==RECURSOS[f.ordem-1][2],rota.id+": tanque acessível no desvio validado")
		conferir(mundo.partida.tempo_restante>0,rota.id+": oxigênio suficiente")
		if f.ordem in [21,22,26,28,29,30]:
			conferir(resultado.saltos>= (2 if f.ordem in [28,30] else 1),rota.id+": portais fazem parte da rota")
		conferir(progresso.concluir_com_coletas(f.id,catalogo.itens,3,1),rota.id+": conclusão da fase registrada na sequência")
		mundo.free()
		if f.ordem in [25,29,30]:
			var sem_tanque: NivelRes = Carregador.carregar("res://Recursos/Fases/"+rota.id+".json").nivel
			sem_tanque.combustiveis=[]
			var tentativa = Cena.instantiate()
			tentativa.nivel_res=sem_tanque
			root.add_child(tentativa)
			tentativa.partida.set_physics_process(false)
			conferir(not Rotas.executar(tentativa.partida,rota.etapas).venceu,rota.id+": rota de escalas exige a carga coletável")
			tentativa.free()
	conferir(progresso.concluidas.size()==30 and progresso.total_estrelas()==90,"Campanha inteira registra 30 fases e 90 douradas")
	var dados: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://Recursos/Fases/nevoa_cega.json"))
	for invalido in [null,{}, {"visibility_radius":0},{"visibility_radius":301},{"visibility_radius":"90"}]:
		dados.nebula=invalido
		conferir(Carregador.validar(dados).nivel==null,"Nebulosa inválida rejeitada")
	var titulo := Titulo.new()
	titulo.titulo="O Grande Retorno"
	root.add_child(titulo)
	conferir(titulo.modulate.a==1,"Título aparece totalmente visível")
	await create_timer(2.05).timeout
	conferir(is_instance_valid(titulo) and titulo.modulate.a>0 and titulo.modulate.a<1,"Título desaparece gradualmente após leitura")
	await create_timer(0.65).timeout
	conferir(not is_instance_valid(titulo),"Título libera a visão completamente")
	print("Campanha 30: %d verificações, %d falhas." % [verificacoes,falhas])
	quit(1 if falhas else 0)
