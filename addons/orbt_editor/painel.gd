@tool
extends VBoxContainer

signal testar_solicitado
const Documento = preload("res://addons/orbt_editor/documento.gd")
const Mapa = preload("res://addons/orbt_editor/mapa.gd")
const RASCUNHO = "res://.godot/orbt-editor-sessao.json"
var documento := Documento.new()
var persistir_sessao := true
var caminho_rascunho := RASCUNHO
var mapa: Control
var _titulo: Label
var _lista: ItemList
var _propriedades: VBoxContainer
var _diagnostico: RichTextLabel
var _abrir: FileDialog
var _salvar: FileDialog
var _pendente: Callable
var _confirmacao: ConfirmationDialog
var _exclusao: ConfirmationDialog
var _jogar: Button


func _ready() -> void:
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	var barra := HFlowContainer.new()
	add_child(barra)
	_botao(barra, "Nova fase", func(): _solicitar(documento.novo))
	_botao(barra, "Abrir…", func(): _solicitar(func(): _abrir.popup_centered_ratio(0.7)))
	_botao(barra, "Salvar", _pedir_salvar)
	_botao(barra, "Salvar como…", func(): _salvar.popup_centered_ratio(0.7))
	_botao(barra, "Validar", _validar)
	_jogar = _botao(barra, "Testar fase", func(): testar_solicitado.emit())
	_titulo = Label.new()
	_titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_titulo.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	barra.add_child(_titulo)
	var ferramentas := HFlowContainer.new()
	add_child(ferramentas)
	var tipo := OptionButton.new()
	for texto in ["planet", "satellite", "sun", "asteroid"]:
		tipo.add_item(texto)
	ferramentas.add_child(tipo)
	_botao(ferramentas, "Inserir corpo", func():
		documento.inserir(tipo.get_item_text(tipo.selected), mapa.centro)
		_mostrar_propriedades())
	_botao(ferramentas, "Excluir selecionado…", func():
		if documento.selecao >= 0:
			_exclusao.dialog_text = "Excluir %s? Se for o apoio inicial, será preciso corrigir start.body_id antes de salvar ou testar." % documento.objeto(documento.selecao).id
			_exclusao.popup_centered())
	_botao(ferramentas, "Enquadrar mapa", func(): mapa.enquadrar())
	var dica := Label.new()
	dica.text = "Arraste: mover • Roda: zoom • Botão central: navegar"
	ferramentas.add_child(dica)
	var divisao := HSplitContainer.new()
	divisao.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(divisao)
	var lateral := VBoxContainer.new()
	lateral.custom_minimum_size.x = 320
	divisao.add_child(lateral)
	_lista = ItemList.new()
	_lista.custom_minimum_size.y = 140
	lateral.add_child(_lista)
	_lista.item_selected.connect(func(indice: int):
		documento.selecionar(indice - 2))
	var rolagem := ScrollContainer.new()
	rolagem.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lateral.add_child(rolagem)
	_propriedades = VBoxContainer.new()
	_propriedades.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rolagem.add_child(_propriedades)
	var visual := VBoxContainer.new()
	visual.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	divisao.add_child(visual)
	var legenda := HFlowContainer.new()
	visual.add_child(legenda)
	mapa = Mapa.new()
	mapa.documento = documento
	mapa.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mapa.custom_minimum_size = Vector2(240, 240)
	visual.add_child(mapa)
	var nomes := {"visual_radius": "Visual", "collision_radius": "Colisão", "capture_radius": "Captura", "proximity_radius": "Proximidade", "danger_radius": "Perigo"}
	for campo in nomes:
		var caixa := CheckBox.new()
		caixa.text = nomes[campo]
		caixa.button_pressed = true
		caixa.add_theme_color_override("font_color", Mapa.CORES[campo])
		caixa.toggled.connect(func(ativo: bool):
			mapa.regioes[campo] = ativo
			mapa.queue_redraw())
		legenda.add_child(caixa)
	_diagnostico = RichTextLabel.new()
	_diagnostico.custom_minimum_size.y = 115
	_diagnostico.selection_enabled = true
	visual.add_child(_diagnostico)
	_abrir = _dialogo(FileDialog.FILE_MODE_OPEN_FILE)
	_abrir.file_selected.connect(_carregar)
	_salvar = _dialogo(FileDialog.FILE_MODE_SAVE_FILE)
	_salvar.file_selected.connect(_gravar)
	_confirmacao = ConfirmationDialog.new()
	_confirmacao.title = "Alterações não salvas"
	_confirmacao.dialog_text = "Salvar as alterações antes de continuar?"
	_confirmacao.ok_button_text = "Salvar"
	_confirmacao.cancel_button_text = "Cancelar"
	_confirmacao.add_button("Descartar", false, "descartar")
	_confirmacao.confirmed.connect(_pedir_salvar)
	_confirmacao.canceled.connect(func(): _pendente = Callable())
	_confirmacao.custom_action.connect(func(_acao: StringName):
		_confirmacao.hide()
		_continuar())
	add_child(_confirmacao)
	_exclusao = ConfirmationDialog.new()
	_exclusao.title = "Excluir corpo"
	_exclusao.confirmed.connect(func():
		documento.excluir()
		_mostrar_propriedades())
	add_child(_exclusao)
	_salvar.canceled.connect(func(): _pendente = Callable())
	documento.alterado.connect(_atualizar)
	documento.selecao_alterada.connect(_mostrar_propriedades)
	if not persistir_sessao or not _restaurar():
		documento.abrir(Documento.EXEMPLO)
	_atualizar()
	_mostrar_propriedades()
	mapa.enquadrar.call_deferred()


func _botao(pai: Node, texto: String, acao: Callable) -> Button:
	var botao := Button.new()
	botao.text = texto
	botao.pressed.connect(acao)
	pai.add_child(botao)
	return botao


func _dialogo(modo: FileDialog.FileMode) -> FileDialog:
	var dialogo := FileDialog.new()
	dialogo.file_mode = modo
	dialogo.access = FileDialog.ACCESS_RESOURCES
	dialogo.filters = PackedStringArray(["*.json ; Fase JSON"])
	dialogo.current_dir = "res://Recursos/Fases"
	add_child(dialogo)
	return dialogo


func _solicitar(acao: Callable) -> void:
	_pendente = acao
	if documento.modificado():
		_confirmacao.popup_centered()
	else:
		_continuar()


func _continuar() -> void:
	var acao := _pendente
	_pendente = Callable()
	if acao.is_valid():
		acao.call()
	_mostrar_propriedades()


func _carregar(arquivo: String) -> void:
	var erros := documento.abrir(arquivo)
	if not erros.is_empty():
		_diagnostico.text = "Não foi possível abrir:\n" + "\n".join(erros)
		return
	_mostrar_propriedades()
	mapa.enquadrar()


func _pedir_salvar() -> void:
	if documento.caminho.is_empty():
		_salvar.current_file = str(documento.dados.id) + ".json"
		_salvar.popup_centered_ratio(0.7)
	else:
		_gravar(documento.caminho)


func _gravar(arquivo: String) -> void:
	var erros := documento.salvar(arquivo)
	if not erros.is_empty():
		_diagnostico.text = "Não foi possível salvar:\n" + "\n".join(erros)
		_pendente = Callable()
		return
	_continuar()
	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().scan()


func _atualizar() -> void:
	if not is_instance_valid(_lista):
		return
	_titulo.text = ("● " if documento.modificado() else "") + (documento.caminho if not documento.caminho.is_empty() else "Nova fase")
	_lista.clear()
	_lista.add_item("Fase · " + str(documento.dados.get("name", "")))
	_lista.add_item("Terra · " + str(documento.dados.goal.id))
	for corpo in documento.dados.bodies:
		_lista.add_item(str(corpo.id) + " · " + str(corpo.type))
	_lista.select(documento.selecao + 2)
	mapa.queue_redraw()
	_validar()
	guardar_rascunho()


func _validar() -> void:
	var resultado := documento.validar()
	var linhas: Array[String] = []
	for erro in resultado.erros:
		linhas.append("ERRO · " + erro)
	for aviso in resultado.avisos:
		linhas.append("AVISO · " + aviso)
	if resultado.nivel != null:
		linhas.append("Dados válidos para teste. A validação não comprova que a rota tem solução.")
	_diagnostico.text = "\n".join(linhas)
	_jogar.disabled = resultado.nivel == null


func _mostrar_propriedades() -> void:
	if not is_instance_valid(_propriedades):
		return
	for filho in _propriedades.get_children():
		_propriedades.remove_child(filho)
		filho.queue_free()
	if documento.selecao == -2:
		for chave in ["id", "name", "schema_version", "content_version", "order", "initial_fuel", "flight_timeout", "bounds", "physics", "ship", "start", "tutorial", "notes"]:
			if documento.dados.has(chave):
				_campo([chave], documento.dados[chave], chave)
			elif chave == "initial_fuel":
				_campo([chave], 5, chave)
			elif chave in ["tutorial", "notes"]:
				_campo([chave], "", chave)
	else:
		var trilha: Array = ["goal"] if documento.selecao == -1 else ["bodies", documento.selecao]
		var orbita := CheckBox.new()
		orbita.text = "Movimento orbital"
		orbita.button_pressed = documento.objeto(documento.selecao).has("orbit")
		orbita.toggled.connect(func(ativo: bool):
			var corpo: Dictionary = documento.objeto(documento.selecao)
			if ativo:
				corpo["orbit"] = {"center": [corpo.position[0] - 60, corpo.position[1]], "period_seconds": 20.0, "clockwise": true}
			else:
				corpo.erase("orbit")
			documento.alterado.emit()
			_mostrar_propriedades())
		_propriedades.add_child(orbita)
		for campo in ["rotation", "landing_zone"]:
			if campo == "landing_zone" and documento.objeto(documento.selecao).get("type", "earth") not in ["planet", "satellite"]:
				continue
			var opcao := CheckBox.new()
			opcao.text = "Rotação do corpo" if campo == "rotation" else "Faixa segura de pouso"
			opcao.button_pressed = documento.objeto(documento.selecao).has(campo)
			opcao.toggled.connect(func(ativo: bool):
				var corpo: Dictionary = documento.objeto(documento.selecao)
				if ativo:
					corpo[campo] = {"degrees_per_second": 30.0, "initial_degrees": 0.0} if campo == "rotation" else {"center_degrees": -90.0, "half_width_degrees": 45.0}
				else:
					corpo.erase(campo)
				documento.alterado.emit()
				_mostrar_propriedades())
			_propriedades.add_child(opcao)
		for chave in documento.objeto(documento.selecao):
			if documento.selecao == -1 and chave == "type":
				continue
			_campo(trilha + [chave], documento.objeto(documento.selecao)[chave], chave)


func _campo(trilha: Array, valor: Variant, nome_campo: String) -> void:
	if valor is Dictionary:
		for chave in valor:
			_campo(trilha + [chave], valor[chave], nome_campo + "." + chave)
		return
	if valor is Array:
		for indice in range(valor.size()):
			_campo(trilha + [indice], valor[indice], nome_campo + (".x" if indice == 0 else ".y"))
		return
	var rotulo := Label.new()
	rotulo.text = nome_campo
	_propriedades.add_child(rotulo)
	if nome_campo == "type":
		var opcao := OptionButton.new()
		for tipo in ["planet", "satellite", "sun", "asteroid"]:
			opcao.add_item(tipo)
			if tipo == valor:
				opcao.selected = opcao.item_count - 1
		opcao.item_selected.connect(func(indice: int): documento.editar(trilha, opcao.get_item_text(indice)))
		_propriedades.add_child(opcao)
	elif valor is int or valor is float:
		var numero := SpinBox.new()
		numero.min_value = -1000000
		numero.max_value = 1000000
		numero.step = 1 if nome_campo in ["schema_version", "content_version", "order", "initial_fuel"] else 0.01
		numero.value = valor
		numero.editable = nome_campo != "schema_version"
		numero.value_changed.connect(func(novo: float): documento.editar(trilha, novo))
		_propriedades.add_child(numero)
	elif valor is bool:
		var caixa := CheckBox.new()
		caixa.button_pressed = valor
		caixa.toggled.connect(func(novo: bool): documento.editar(trilha, novo))
		_propriedades.add_child(caixa)
	elif valor is String:
		var entrada := LineEdit.new()
		entrada.text = valor
		entrada.text_changed.connect(func(novo: String): documento.editar(trilha, novo))
		_propriedades.add_child(entrada)


func guardar_rascunho() -> void:
	if not persistir_sessao or documento.dados.is_empty():
		return
	var arquivo := FileAccess.open(caminho_rascunho, FileAccess.WRITE)
	if arquivo != null:
		arquivo.store_string(JSON.stringify({"dados": documento.dados, "caminho": documento.caminho, "salvo": documento._salvo, "selecao": documento.selecao}, "", true, true))


func _restaurar() -> bool:
	if not FileAccess.file_exists(caminho_rascunho):
		return false
	var sessao = JSON.parse_string(FileAccess.get_file_as_string(caminho_rascunho))
	if not sessao is Dictionary or not sessao.get("dados") is Dictionary:
		return false
	# Um rascunho pode conter erros geométricos, mas precisa da estrutura editável.
	var dados: Dictionary = sessao.dados
	for chave in ["bounds", "physics", "ship", "start", "goal"]:
		if not dados.get(chave) is Dictionary:
			return false
	if not dados.get("bodies") is Array:
		return false
	documento.dados = dados.duplicate(true)
	documento.caminho = sessao.get("caminho", "")
	var texto_salvo = sessao.get("salvo", "")
	var salvo = JSON.parse_string(texto_salvo) if texto_salvo is String and not texto_salvo.is_empty() else null
	documento._salvo = JSON.stringify(salvo, "", true, true) if salvo is Dictionary else ""
	documento.selecao = clampi(int(sessao.get("selecao", -2)), -2, dados.bodies.size() - 1)
	return true
