@tool
extends EditorPlugin
## Executado no EditorNode real, incluindo ativação/desativação pela API oficial.

const Painel = preload("res://addons/orbt_editor/painel.gd")
var verificacoes := 0
var falhas := 0
var continuou := false


func _enter_tree() -> void:
	_executar.call_deferred()


func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)


func paineis() -> Array:
	return EditorInterface.get_editor_main_screen().get_children().filter(func(no: Node): return no.get_script() == Painel)


func _executar() -> void:
	# A interface termina de abrir depois de _enter_tree dos plugins.
	await get_tree().create_timer(3.0).timeout
	conferir(paineis().size() == 1, "Inicialização cria um painel")
	for ciclo in range(2):
		for painel in paineis():
			painel.persistir_sessao = false
		EditorInterface.set_plugin_enabled("orbt_editor", false)
		await get_tree().process_frame
		conferir(paineis().is_empty(), "Desativação libera painel")
		EditorInterface.set_plugin_enabled("orbt_editor", true)
		await get_tree().process_frame
		conferir(paineis().size() == 1, "Reativação não duplica painel")
		conferir(not paineis()[0].documento.dados.is_empty(), "Reativação restaura documento utilizável")
	if paineis().size() == 1:
		var painel = paineis()[0]
		painel.persistir_sessao = false
		painel.documento.abrir("res://Recursos/Fases/teste_001.json")
		painel.documento.editar(["name"], "Teste de edição")
		painel._solicitar(func(): continuou = true)
		conferir(painel._confirmacao.visible and not continuou, "Abertura com edição pede decisão")
		painel._confirmacao.canceled.emit()
		painel._confirmacao.hide()
		conferir(not painel._pendente.is_valid() and painel.documento.modificado(), "Cancelar mantém alterações")
		painel._solicitar(func(): continuou = true)
		painel._confirmacao.custom_action.emit("descartar")
		conferir(continuou, "Descartar permite continuar")
		continuou = false
		painel.documento.caminho = "res://.godot/editor-plugin-salvar.json"
		painel._solicitar(func(): continuou = true)
		painel._confirmacao.hide()
		painel._confirmacao.confirmed.emit()
		conferir(continuou and not painel.documento.modificado(), "Salvar antes de continuar preserva fase")
		painel.documento.abrir("res://Recursos/Fases/teste_001.json")
		painel._mostrar_propriedades()
		EditorInterface.set_main_screen_editor("ORBT Fases")
		EditorInterface.distraction_free_mode = true
		await get_tree().process_frame
		painel.mapa.enquadrar()
		await get_tree().create_timer(1.0).timeout
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			var captura := EditorInterface.get_base_control().get_viewport().get_texture().get_image()
			conferir(captura.save_png("res://.godot/editor-orbt.png") == OK, "Captura do editor real")
	print("Plugin: %d verificações, %d falhas." % [verificacoes, falhas])
	get_tree().quit(0 if falhas == 0 else 1)
