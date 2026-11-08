extends SceneTree
const Cena = preload("res://src/Nivel/Nivel.tscn")
const Carregador = preload("res://src/Nivel/carregador_fase.gd")
const Preferencias = preload("res://src/Configuracoes/preferencias.gd")
var falhas := 0

func _initialize() -> void:
	executar.call_deferred()

func quadro() -> void:
	for i in range(4): await process_frame
	await RenderingServer.frame_post_draw

func salvar(nome: String) -> void:
	await quadro()
	root.get_texture().get_image().save_png("res://.godot/campanha30-"+nome+".png")

func conferir(ok: bool, mensagem: String) -> void:
	if not ok:
		falhas += 1
		push_error(mensagem)

func executar() -> void:
	root.content_scale_size=Vector2i(180,320)
	root.size=Vector2i(540,960)
	var mundo = Cena.instantiate()
	mundo.nivel_res=Carregador.carregar("res://Recursos/Fases/portal_invisivel.json").nivel
	mundo.preferencias=Preferencias.new()
	mundo.preferencias.dicas=false
	root.add_child(mundo)
	await salvar("titulo")
	await create_timer(2.7).timeout
	var sondas := CanvasLayer.new()
	sondas.layer=6
	root.add_child(sondas)
	var dentro := ColorRect.new()
	dentro.color=Color.MAGENTA
	dentro.position=Vector2(86,156)
	dentro.size=Vector2(8,8)
	sondas.add_child(dentro)
	var fora := ColorRect.new()
	fora.color=Color.MAGENTA
	fora.position=Vector2(8,248)
	fora.size=Vector2(8,8)
	sondas.add_child(fora)
	await quadro()
	var imagem := root.get_texture().get_image()
	var centro := imagem.get_pixel(270,480)
	var oculto := imagem.get_pixel(36,756)
	conferir(centro.r>0.8 and centro.b>0.8,"Interior da visão permanece visível")
	conferir(oculto.r<0.2 and oculto.b<0.3,"Exterior é totalmente oculto no gameplay")
	mundo.partida.alternar_exploracao()
	await quadro()
	imagem=root.get_texture().get_image()
	oculto=imagem.get_pixel(36,756)
	conferir(oculto.r<0.2 and oculto.b<0.3,"Mapa também oculta o exterior")
	sondas.queue_free()
	await salvar("nebulosa-mapa")
	mundo.partida.alternar_exploracao()
	await salvar("nebulosa-voo")
	mundo.free()
	var jogo=load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso=false
	jogo.ativar_audio=false
	root.add_child(jogo)
	jogo.mostrar_selecao()
	await salvar("selecao")
	jogo.interface_atual.rolagem.scroll_vertical=2000
	await salvar("nivel3")
	print("Renderização campanha 30: %d falhas." % falhas)
	quit(1 if falhas else 0)
