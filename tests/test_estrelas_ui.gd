extends SceneTree

const Carregador = preload("res://src/Nivel/carregador_fase.gd")
const Progresso = preload("res://src/Campanha/progresso_sessao.gd")
const Selecao = preload("res://src/Campanha/selecao_fases.gd")
var verificacoes := 0
var falhas := 0


func _initialize() -> void:
	_executar.call_deferred()


func conferir(ok: bool, mensagem: String) -> void:
	verificacoes += 1
	if not ok:
		falhas += 1
		push_error(mensagem)


func acomodar() -> void:
	for i in 6:
		await process_frame


func _executar() -> void:
	var suporte := SubViewportContainer.new()
	root.add_child(suporte)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(180, 320)
	suporte.add_child(viewport)
	var itens: Array = []
	for indice in 20:
		itens.append({"id": "fase_%d" % indice, "nome": "Fase %d" % indice, "ordem": indice + 1, "estrelas": 3, "azuis": 1})
	var progresso := Progresso.new()
	progresso.configurar(itens)
	progresso.concluir_com_estrelas(itens[0].id, itens, 2)
	var selecao := Selecao.new()
	selecao.progresso = progresso
	selecao.itens = itens
	viewport.add_child(selecao)
	await acomodar()
	conferir(selecao._colecao.text == "0/20" and selecao._colecao.modulate.is_equal_approx(Color("57b9ff")), "Cabeçalho mostra apenas estrelas azuis descobertas")
	conferir(selecao.obter_cartao(0).get_node("Estrelas").get_child_count() == 3, "Cartão apresenta três estrelas douradas")
	conferir(selecao.obter_cartao(0).get_child(2).accessibility_name.contains("Estrelas: 2/3") and selecao.obter_cartao(0).find_child("Azuis", true, false) == null, "Cartão mantém recorde dourado e oculta segredo azul")
	for altura in [240, 320, 390]:
		viewport.size.y = altura
		await acomodar()
		var area := Rect2(Vector2.ZERO, Vector2(viewport.size))
		conferir(area.encloses(selecao._colecao.get_global_rect()) and selecao._colecao.get_line_count() == 1, "Coleção cabe em uma linha no cabeçalho em 180x%d" % altura)
		conferir(not selecao.rolagem.get_h_scroll_bar().visible, "Vinte fases com estrelas mantêm largura em 180x%d" % altura)
		var ultimo: Button = selecao.obter_cartao(19).get_child(2)
		selecao.rolagem.ensure_control_visible(ultimo)
		await acomodar()
		conferir(selecao.rolagem.get_global_rect().encloses(ultimo.get_global_rect()), "Fase vinte permanece alcançável em 180x%d" % altura)
	itens[0].estrelas = 256
	selecao.atualizar(itens, [])
	await acomodar()
	conferir(not selecao.rolagem.get_h_scroll_bar().visible and selecao.cartoes.size.x <= selecao.rolagem.size.x, "Fase do editor com muitas estrelas usa contador compacto sem alargar grade")
	selecao.free()
	var dados: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://Recursos/Fases/teste_001.json"))
	dados["stars"] = [{"id": "a", "position": [90, 180], "radius": 7}, {"id": "b", "position": [130, 140], "radius": 7}, {"id": "c", "position": [150, 90], "radius": 7}]
	var mundo = load("res://src/Nivel/Nivel.tscn").instantiate()
	mundo.nivel_res = Carregador.validar(dados).nivel
	mundo.progresso = progresso
	viewport.add_child(mundo)
	await acomodar()
	mundo.partida.set_physics_process(false)
	var hud: CanvasLayer
	for filho in mundo.get_children():
		if filho.has_method("_alternar_pausa"):
			hud = filho
	hud._process(0)
	conferir(hud._estrelas.text == "0/3" and hud._estrelas.is_visible_in_tree(), "HUD inicia com zero estrelas e explica confirmação")
	var visuais: Node2D
	for filho in mundo.get_children():
		if filho.get_script() == load("res://src/Visual/estrelas_coletaveis.gd"):
			visuais = filho
	conferir(is_instance_valid(visuais), "Mundo instancia estrelas visuais a partir da partida")
	mundo.partida._coletar_trecho(Vector2(90, 200), Vector2(90, 170))
	hud._process(0)
	conferir(hud._estrelas.text == "1/3" and visuais._brilhos.size() == 1, "Coleta atualiza contador e resposta visual")
	for altura in [240, 320, 390]:
		viewport.size.y = altura
		await acomodar()
		var area := Rect2(Vector2.ZERO, Vector2(viewport.size))
		conferir(area.encloses(hud._estrelas.get_global_rect()) and not hud._estrelas.get_global_rect().intersects(hud._status.get_global_rect()), "Contador cabe sem cobrir combustível em 180x%d" % altura)
	mundo.partida.aviso_salvamento = "Progresso novo ainda não foi salvo."
	mundo.partida.finalizar(true, "Terra")
	hud._process(0)
	var estrelas_resultado = hud._dialogo_conclusao._estrelas_resultado
	conferir(estrelas_resultado.get_child_count() == 4 and estrelas_resultado.get_child(0).modulate == Color("ffc845") and estrelas_resultado.get_child(1).modulate == Color("45516b") and not estrelas_resultado.get_child(3).visible, "Resultado mostra douradas e esconde azul não coletada")
	hud._dialogo_conclusao.exibir_estrelas(3, true)
	conferir(estrelas_resultado.get_child(2).modulate == Color("ffc845") and estrelas_resultado.get_child(3).visible and estrelas_resultado.get_child(3).modulate == Color("57b9ff"), "Resultado mostra a estrela azul conquistada")
	conferir(hud._dialogo_conclusao._motivo.text.begins_with("Progresso novo ainda não foi salvo.") and hud._dialogo_conclusao._motivo.is_visible_in_tree(), "Falha ao salvar fica visível no resultado com estrelas")
	for altura in [240, 320, 390]:
		viewport.size.y = altura
		await acomodar()
		var area := Rect2(Vector2.ZERO, Vector2(viewport.size))
		conferir(area.encloses(hud._dialogo_conclusao._motivo.get_global_rect()) and area.encloses(hud._dialogo_conclusao._menu.get_global_rect()) and area.encloses(estrelas_resultado.get_global_rect()), "Resultado com estrelas cabe em 180x%d" % altura)
	mundo.partida.reiniciar()
	hud._process(0)
	conferir(hud._estrelas.text == "0/3" and visuais._brilhos.is_empty(), "Repetição restaura estrelas e remove efeito anterior")
	suporte.queue_free()
	await process_frame
	print("Interface de estrelas: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas else 0)
