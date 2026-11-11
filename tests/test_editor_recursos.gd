extends SceneTree
## Autoria de tanques/nebulosa pelo documento, mapa e controles reais do painel.

const Documento = preload("res://addons/orbt_editor/documento.gd")
const Painel = preload("res://addons/orbt_editor/painel.gd")
var verificacoes := 0
var falhas := 0
var arquivo := "res://.godot/editor-recursos-%d.json" % OS.get_process_id()
var previa := arquivo + "-previa.json"
var rascunho := arquivo + "-rascunho.json"


func _initialize() -> void:
	_executar.call_deferred()


func conferir(ok: bool, mensagem: String) -> void:
	verificacoes += 1
	if not ok:
		falhas += 1
		push_error(mensagem)


func campo(painel: Control, rotulo: String) -> Control:
	var campos: Array = painel._propriedades.get_children()
	for i in range(campos.size() - 1):
		if campos[i] is Label and campos[i].text == rotulo:
			return campos[i + 1]
	return null


func clicar(mapa: Control, posicao: Vector2, pressionado: bool) -> void:
	var evento := InputEventMouseButton.new()
	evento.button_index = MOUSE_BUTTON_LEFT
	evento.position = mapa.tela(posicao)
	evento.pressed = pressionado
	mapa._gui_input(evento)


func base() -> RefCounted:
	var doc := Documento.new()
	doc.dados = {
		"schema_version": 1, "content_version": 1, "id": "editor_recursos", "name": "Recursos", "order": 1,
		"bounds": {"position": [-200, -200], "size": [800, 800]}, "initial_fuel": 5, "flight_timeout": 30,
		"physics": {"gravity_constant": 0, "softening": 8},
		"ship": {"radius": 8, "mass": 1, "dead_zone": 10, "max_drag": 80, "max_impulse": 80},
		"start": {"position": [0, 0]}, "bodies": [],
		"goal": {"id": "terra", "position": [300, 0], "mass": 0, "visual_radius": 14,
			"collision_radius": 14, "capture_radius": 16, "danger_radius": 0, "proximity_radius": 45}
	}
	doc.limpar_historico()
	return doc


func _executar() -> void:
	var doc := base()
	conferir(doc.salvar(arquivo).is_empty(), "Salva fase anterior sem tanques/nebulosa")
	doc.inserir_tanque(Vector2(60, 80))
	var primeiro: int = Documento.PRIMEIRO_TANQUE
	conferir(doc.selecao == primeiro and doc.objeto(primeiro).amount == 1 and doc.modificado(), "Inserção cria tanque +1 e o seleciona")
	conferir(doc.desfazer() and not doc.dados.has("fuel_pickups") and not doc.modificado(), "Desfazer inserção preserva JSON antigo sem campo adicional")
	conferir(doc.refazer() and doc.selecao == primeiro and doc.dados.fuel_pickups.size() == 1, "Refazer restaura tanque e seleção")
	doc.inserir_tanque(Vector2(140, 80))
	conferir(doc.objeto(primeiro).id != doc.objeto(primeiro - 1).id, "Tanques recebem IDs próprios")
	doc.inserir_estrela(Vector2(60, 160))
	conferir(doc.selecao == -3 and doc.objeto(-3).type == "gold" and doc.objeto(primeiro).amount == 1, "Estrela e tanque coexistem sem colisão de seleção")
	doc.selecionar(primeiro)
	conferir(doc.duplicar(Vector2(40, 40)), "Duplica tanque pelo fluxo comum")
	var copia: Dictionary = doc.objeto(doc.selecao)
	conferir(copia.id != doc.objeto(primeiro).id and copia.position == [100.0, 120.0] and copia.amount == 1, "Cópia preserva carga e ganha identidade/posição independentes")
	doc.iniciar_grupo()
	doc.mover(doc.selecao, Vector2(110, 120))
	doc.mover(doc.selecao, Vector2(120, 120))
	doc.terminar_grupo()
	conferir(doc.desfazer() and doc.objeto(doc.selecao).position == [100.0, 120.0], "Arraste inteiro de tanque desfaz em um passo")
	conferir(doc.refazer() and doc.objeto(doc.selecao).position == [120.0, 120.0], "Refazer recupera fim do arraste")
	doc.excluir()
	conferir(doc.selecao == -2 and doc.dados.fuel_pickups.size() == 2 and doc.dados.stars.size() == 1, "Exclusão de tanque preserva estrelas e outros tanques")
	conferir(doc.desfazer() and doc.objeto(doc.selecao).id == copia.id, "Desfazer exclusão restaura identidade e seleção do tanque")
	conferir(doc.refazer() and doc.dados.fuel_pickups.size() == 2, "Refazer exclusão remove só a cópia")
	doc.inserir_tanque(Vector2(NAN, 0))
	conferir(doc.dados.fuel_pickups.size() == 2, "Posição inválida não cria tanque")
	doc.editar(["fuel_pickups", 0, "amount"], 4)
	doc.editar(["fuel_pickups", 0, "radius"], 10.5)
	conferir(doc.validar().nivel.combustiveis[0].amount == 4, "Carga editada é aceita pelo carregador do jogo")
	doc.configurar_nebulosa(true)
	conferir(doc.dados.nebula.visibility_radius == 120, "Ativar nebulosa cria raio válido sem editar JSON")
	doc.editar(["nebula", "visibility_radius"], 145.5)
	doc.configurar_nebulosa(false)
	conferir(not doc.dados.has("nebula"), "Desativar remove o campo opcional do arquivo")
	conferir(doc.desfazer() and doc.dados.nebula.visibility_radius == 145.5, "Desfazer desativação recupera raio autoral")
	conferir(doc.refazer() and not doc.dados.has("nebula"), "Refazer desativação mantém demais dados")
	doc.desfazer()
	conferir(doc.salvar(arquivo).is_empty(), "Salva tanques e nebulosa no formato existente")
	var reaberto := Documento.new()
	conferir(reaberto.abrir(arquivo).is_empty() and reaberto.dados == JSON.parse_string(JSON.stringify(doc.dados, "", true, true)), "Reabertura conserva tanques, estrelas e nebulosa")
	conferir(not reaberto.modificado(), "Reabrir não cria alteração fantasma")
	conferir(doc.exportar_teste(previa).is_empty(), "Exporta cópia de teste com novos controles autorais")
	var nivel = Documento.Carregador.carregar(previa).nivel
	conferir(nivel != null and nivel.combustiveis.size() == 2 and nivel.dados_autorais.nebula.visibility_radius == 145.5, "Preview entrega tanques/nebulosa ao carregador comum")
	# Os limites dos arrays não podem fazer o último índice de estrela virar tanque.
	var cheio := base()
	cheio.dados["stars"] = []
	cheio.dados["fuel_pickups"] = []
	for i in Documento.LIMITE_COLETAVEIS:
		cheio.dados.stars.append({"id": "e%d" % i, "type": "gold", "position": [60, 80], "radius": 7})
		cheio.dados.fuel_pickups.append({"id": "t%d" % i, "position": [60, 120], "radius": 8, "amount": 1})
	cheio.inserir_estrela(Vector2.ZERO)
	cheio.inserir_tanque(Vector2.ZERO)
	conferir(cheio.dados.stars.size() == 256 and cheio.dados.fuel_pickups.size() == 256, "Inserções respeitam os limites do contrato")
	conferir(cheio.objeto(primeiro + 1).id == "e255" and cheio.objeto(primeiro).id == "t0", "256 estrelas não colidem com a seleção de tanques")
	cheio.selecionar(primeiro + 1)
	conferir(not cheio.duplicar(), "Duplicação respeita limite de estrelas")
	cheio.selecionar(primeiro)
	conferir(not cheio.duplicar(), "Duplicação respeita limite de tanques")
	# Exercita os controles do painel e os eventos do mapa, não apenas o documento.
	var painel := Painel.new()
	painel.persistir_sessao = false
	root.add_child(painel)
	await process_frame
	conferir(painel.documento.abrir(arquivo).is_empty(), "Painel abre fase com tanques/nebulosa")
	painel.documento.selecionar(-2)
	conferir(painel._lista.item_count == 5, "Lista inclui fase, Terra, estrela e dois tanques")
	painel.mapa.escala = 1
	painel.mapa.centro = Vector2.ZERO
	clicar(painel.mapa, Vector2(60, 80), true)
	conferir(painel.documento.selecao == primeiro and painel._lista.get_selected_items() == PackedInt32Array([3]), "Mapa seleciona tanque e sincroniza lista")
	var movimento := InputEventMouseMotion.new()
	movimento.position = painel.mapa.tela(Vector2(80, 100))
	painel.mapa._gui_input(movimento)
	clicar(painel.mapa, Vector2(80, 100), false)
	conferir(painel.documento.objeto(primeiro).position == [80.0, 100.0] and campo(painel, "Posição X").value == 80, "Arraste move tanque e atualiza coordenadas visíveis")
	conferir(painel.documento.desfazer() and painel.documento.objeto(primeiro).position == [60.0, 80.0], "Desfazer recupera tanque movido pelo mapa")
	painel._lista.item_selected.emit(4)
	conferir(painel.documento.selecao == primeiro - 1, "Lista seleciona o segundo tanque")
	conferir(campo(painel, "Carga de combustível") is SpinBox and campo(painel, "Massa") == null, "Tanque mostra carga, posição e raio em português sem propriedades de planeta")
	var quantidade: SpinBox = campo(painel, "Carga de combustível")
	conferir(quantidade.min_value == 1 and quantidade.max_value == 100 and quantidade.step == 1, "Quantidade limita cargas a inteiros de 1 a 100")
	quantidade.value = 3
	conferir(painel.documento.objeto(primeiro - 1).amount == 3 and painel.documento.validar().nivel != null, "Controle de quantidade altera tanque e mantém fase válida")
	var raio_tanque: SpinBox = campo(painel, "Raio de coleta")
	conferir(raio_tanque.min_value == 0.01 and raio_tanque.max_value == 1000, "Controle de raio do tanque respeita contrato")
	var botoes := painel.find_children("*", "Button", true, false)
	for botao in botoes:
		if botao.text == "Inserir tanque":
			painel.mapa.centro = Vector2(180, 120)
			botao.pressed.emit()
	conferir(painel.documento.dados.fuel_pickups.size() == 3 and painel.documento.objeto(painel.documento.selecao).position == [180.0, 120.0], "Botão cria tanque no centro visível e o seleciona")
	painel.documento.excluir()
	conferir(painel.documento.selecao == -2 and painel._propriedades.get_child(0).text == "Identificador", "Excluir tanque volta às propriedades da fase")
	var ativa: CheckBox = painel._propriedades.get_node("NebulosaAtiva")
	conferir(ativa.button_pressed, "Painel reconhece nebulosa carregada")
	ativa.button_pressed = false
	conferir(not painel.documento.dados.has("nebula") and not painel._propriedades.has_node("RaioNebulosa"), "Desativar na interface remove configuração e controle de raio")
	conferir(painel.documento.desfazer() and painel._propriedades.get_node("NebulosaAtiva").button_pressed, "Desfazer sincroniza checkbox e raio")
	var raio: SpinBox = painel._propriedades.get_node("RaioNebulosa")
	conferir(raio.min_value == 45 and raio.max_value == 300 and raio.value == 145.5, "Controle de nebulosa preserva raio e limites válidos")
	raio.value = 180.25
	conferir(painel.documento.dados.nebula.visibility_radius == 180.25, "Editar raio pela interface atualiza documento")
	raio.value = 0
	conferir(painel.documento.dados.nebula.visibility_radius == 45, "Controle não permite raio de visão abaixo do mínimo")
	painel.documento.selecionar(primeiro - 1)
	painel.persistir_sessao = true
	painel.caminho_rascunho = rascunho
	painel.guardar_rascunho()
	painel.queue_free()
	await process_frame
	painel = Painel.new()
	painel.caminho_rascunho = rascunho
	root.add_child(painel)
	conferir(painel.documento.selecao == primeiro - 1 and painel.documento.objeto(primeiro - 1).amount == 3 and painel.documento.dados.nebula.visibility_radius == 45, "Rascunho recupera tanque selecionado, alterações e nebulosa")
	var sessao := {"dados": painel.documento.dados.duplicate(true), "selecao": primeiro}
	sessao.dados.fuel_pickups = "invalido"
	var fluxo := FileAccess.open(rascunho, FileAccess.WRITE)
	fluxo.store_string(JSON.stringify(sessao))
	fluxo.close()
	conferir(not painel._restaurar(), "Rascunho malformado de tanques não chega ao mapa")
	sessao.dados.fuel_pickups = [{"id": "t", "position": [0, 0], "radius": 8, "amount": null}]
	fluxo = FileAccess.open(rascunho, FileAccess.WRITE)
	fluxo.store_string(JSON.stringify(sessao))
	fluxo.close()
	conferir(not painel._restaurar(), "Rascunho com carga não editável é rejeitado")
	sessao.dados.fuel_pickups = []
	sessao.dados.nebula = {"visibility_radius": "invalido"}
	fluxo = FileAccess.open(rascunho, FileAccess.WRITE)
	fluxo.store_string(JSON.stringify(sessao))
	fluxo.close()
	conferir(not painel._restaurar(), "Rascunho malformado de nebulosa é rejeitado")
	painel.persistir_sessao = false
	var tipos: OptionButton
	for controle in painel.find_children("*", "OptionButton", true, false):
		if controle.get_item_text(0) == "Planeta":
			tipos = controle
	conferir(tipos.get_item_text(1) == "Estação espacial" and tipos.get_item_text(2) == "Sol", "Ferramenta de inserção mostra tipos em português")
	tipos.select(1)
	painel.mapa.centro = Vector2(180, 120)
	for botao in painel.find_children("*", "Button", true, false):
		if botao.text == "Inserir corpo":
			botao.pressed.emit()
	conferir(painel.documento.objeto(painel.documento.selecao).type == "station" and painel.documento.validar().nivel != null, "Inserir Estação espacial preserva o tipo aceito pelo jogo")
	var tipo_corpo: OptionButton = campo(painel, "Tipo")
	tipo_corpo.select(3)
	tipo_corpo.item_selected.emit(3)
	conferir(painel.documento.objeto(painel.documento.selecao).type == "asteroid" and painel._lista.get_item_text(2).ends_with("Asteroide"), "Trocar tipo em português grava a chave original e atualiza a lista")
	painel.queue_free()
	await process_frame
	for caminho in [arquivo, previa, rascunho]:
		DirAccess.remove_absolute(caminho)
	print("Editor recursos: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas else 0)
