extends SceneTree

const Documento = preload("res://addons/orbt_editor/documento.gd")
const Painel = preload("res://addons/orbt_editor/painel.gd")
var verificacoes := 0
var falhas := 0
var arquivo := "res://.godot/editor-estrelas-%d.json" % OS.get_process_id()
var previa := "res://.godot/editor-estrelas-previa-%d.json" % OS.get_process_id()
var rascunho := "res://.godot/editor-estrelas-rascunho-%d.json" % OS.get_process_id()


func _initialize() -> void:
	_executar.call_deferred()


func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)


func clicar(mapa: Control, ponto: Vector2, pressionado: bool) -> void:
	var evento := InputEventMouseButton.new()
	evento.button_index = MOUSE_BUTTON_LEFT
	evento.pressed = pressionado
	evento.position = mapa.tela(ponto)
	mapa._gui_input(evento)


func _executar() -> void:
	var doc := Documento.new()
	doc.dados = {
		"schema_version": 1, "content_version": 1, "id": "editor_estrelas", "name": "Editor", "order": 1,
		"bounds": {"position": [-200, -200], "size": [800, 800]}, "initial_fuel": 5, "flight_timeout": 30,
		"physics": {"gravity_constant": 0, "softening": 8},
		"ship": {"radius": 8, "mass": 1, "dead_zone": 10, "max_drag": 80, "max_impulse": 80},
		"start": {"position": [0, 0]}, "bodies": [],
		"goal": {"id": "terra", "position": [300, 0], "mass": 0, "visual_radius": 14,
			"collision_radius": 14, "capture_radius": 16, "danger_radius": 0, "proximity_radius": 45}
	}
	doc.limpar_historico()
	conferir(doc.salvar(arquivo).is_empty(), "Editor salva fase legada sem stars")
	doc.inserir_estrela(Vector2(60, 80))
	conferir(doc.selecao == -3 and doc.objeto(-3).id == "estrela_1" and doc.modificado(), "Inserir cria estrela opcional e a seleciona")
	conferir(doc.desfazer() and not doc.dados.has("stars") and not doc.modificado(), "Desfazer inserção restaura fase legada intacta")
	conferir(doc.refazer() and doc.selecao == -3 and doc.dados.stars.size() == 1, "Refazer restaura estrela e seleção")
	doc.inserir_estrela(Vector2(140, 80))
	conferir(doc.selecao == -4 and doc.objeto(-4).id == "estrela_2", "Segunda estrela ganha ID e seleção independentes")
	doc.selecionar(-3)
	conferir(doc.duplicar(Vector2(40, 40)), "Duplicar aceita estrela selecionada")
	var id_copia: String = doc.objeto(doc.selecao).id
	conferir(doc.selecao == -5 and id_copia != "estrela_1" and doc.objeto(-5).position == [100.0, 120.0], "Cópia tem ID único e deslocamento")
	doc.mover(-5, Vector2(160, 120))
	conferir(doc.objeto(-3).position == [60.0, 80.0] and doc.objeto(-5).position == [160.0, 120.0], "Mover cópia preserva estrela original")
	doc.editar(["stars", 2, "radius"], 9)
	conferir(doc.validar().nivel.estrelas[2].radius == 9, "Propriedade de estrela usa carregador comum")
	doc.excluir()
	conferir(doc.selecao == -2 and doc.dados.stars.size() == 2, "Excluir remove somente estrela selecionada")
	conferir(doc.desfazer() and doc.selecao == -5 and doc.objeto(-5).id == id_copia, "Desfazer exclusão recupera identidade, propriedades e seleção")
	conferir(doc.refazer() and doc.dados.stars.size() == 2, "Refazer exclusão preserva demais estrelas")
	doc.selecionar(-3)
	doc.iniciar_grupo()
	doc.mover(-3, Vector2(65, 85))
	doc.mover(-3, Vector2(70, 90))
	doc.inserir_estrela(Vector2(180, 80))
	conferir(doc.desfazer() and doc.dados.stars.size() == 2 and doc.objeto(-3).position == [70.0, 90.0], "Inserir durante arraste encerra seu grupo antes da inserção")
	conferir(doc.desfazer() and doc.objeto(-3).position == [60.0, 80.0], "Arraste inteiro desfaz em um passo")
	doc.inserir_estrela(Vector2(NAN, 0))
	conferir(doc.dados.stars.size() == 2, "Inserção com posição inválida preserva o documento")
	conferir(doc.salvar(arquivo).is_empty(), "Fase com estrelas salva pelo editor")
	var outro := Documento.new()
	conferir(outro.abrir(arquivo).is_empty() and outro.dados == JSON.parse_string(JSON.stringify(doc.dados, "", true, true)) and not outro.modificado(), "Reabrir preserva todos os dados e estado salvo")
	conferir(outro.exportar_teste(previa).is_empty() and Documento.Carregador.carregar(previa).nivel.estrelas.size() == 2, "Prévia do editor inclui estrelas no carregador de produção")

	var painel := Painel.new()
	painel.persistir_sessao = false
	root.add_child(painel)
	await process_frame
	conferir(painel.documento.abrir(arquivo).is_empty(), "Painel abre fase com estrelas")
	painel.documento.selecionar(-2)
	painel.mapa.escala = 1
	painel.mapa.centro = Vector2.ZERO
	clicar(painel.mapa, Vector2(60, 80), true)
	conferir(painel.documento.selecao == -3 and painel._lista.get_selected_items() == PackedInt32Array([2]), "Selecionar estrela no mapa seleciona a mesma estrela na lista")
	var movimento := InputEventMouseMotion.new()
	movimento.position = painel.mapa.tela(Vector2(80, 100))
	painel.mapa._gui_input(movimento)
	clicar(painel.mapa, Vector2(80, 100), false)
	conferir(painel.documento.objeto(-3).position == [80.0, 100.0], "Arraste no mapa move estrela")
	conferir(painel.documento.desfazer() and painel.documento.objeto(-3).position == [60.0, 80.0], "Desfazer pelo documento recupera arraste do mapa")
	painel._lista.item_selected.emit(3)
	conferir(painel.documento.selecao == -4 and painel._lista.get_selected_items() == PackedInt32Array([3]), "Selecionar estrela na lista atualiza documento e lista")
	var nomes: Array = []
	for campo in painel._propriedades.get_children():
		if campo is Label:
			nomes.append(campo.text)
	conferir("id" in nomes and "radius" in nomes and "position.x" in nomes and "mass" not in nomes, "Estrela exibe propriedades próprias sem física de planetas")
	conferir(not painel._duplicar.disabled, "Ação duplicar fica disponível para estrelas")
	painel.documento.excluir()
	conferir(painel.documento.selecao == -2 and painel._lista.item_count == 3, "Exclusão atualiza lista e seleção do painel")
	conferir(painel._propriedades.get_child(0).text == "id", "Exclusão atualiza propriedades para a fase")
	painel.persistir_sessao = true
	painel.caminho_rascunho = rascunho
	painel.documento.selecionar(-3)
	painel.guardar_rascunho()
	painel.queue_free()
	await process_frame
	painel = Painel.new()
	painel.caminho_rascunho = rascunho
	root.add_child(painel)
	conferir(painel.documento.selecao == -3 and painel.documento.dados.stars.size() == 1, "Rascunho restaura estrela selecionada e exclusão ainda não salva")
	# Dados malformados de um rascunho não podem quebrar o desenho do mapa.
	var sessao := {"dados": painel.documento.dados.duplicate(true), "selecao": -3}
	sessao.dados.stars = "estrela"
	var fluxo := FileAccess.open(rascunho, FileAccess.WRITE)
	fluxo.store_string(JSON.stringify(sessao))
	fluxo.close()
	conferir(not painel._restaurar(), "Rascunho rejeita estrutura de estrelas não editável")
	painel.persistir_sessao = false
	painel.queue_free()
	await process_frame
	for caminho in [arquivo, previa, rascunho]:
		DirAccess.remove_absolute(caminho)
	print("Editor estrelas: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas else 0)
