extends SceneTree
## Executado externamente contra o PCK, sem acessar recursos do checkout.

var verificacoes := 0
var falhas := 0


func _initialize() -> void:
	_executar.call_deferred()


func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)


func _executar() -> void:
	conferir(FileAccess.file_exists("res://Recursos/Niveis.json"), "Catálogo incluído no pacote")
	conferir(FileAccess.file_exists("res://Recursos/Fases/teste_001.json"), "JSON da fase incluído no pacote")
	conferir(not ResourceLoader.exists("res://tests/test_controles.gd"), "Testes excluídos da entrega")
	conferir(not DirAccess.dir_exists_absolute("res://Recursos/ModelosVisuais"), "Referências autorais excluídas da entrega")
	conferir(not DirAccess.dir_exists_absolute("res://tmp"), "Arquivos temporários excluídos da entrega")
	conferir(ProjectSettings.get_setting("display/window/handheld/orientation") == 1, "Orientação retrato incluída")
	var principal = load(ProjectSettings.get_setting("application/run/main_scene"))
	conferir(principal is PackedScene, "Cena principal resolvida no pacote")
	if principal == null:
		quit(1)
		return
	var jogo = principal.instantiate()
	root.add_child(jogo)
	await process_frame
	conferir(jogo.iniciar_fase("teste_001"), "Fase carrega usando apenas dados exportados")
	var nivel = jogo.mundo_atual
	if nivel.nivel_res == null:
		quit(1)
		return
	var partida = nivel.partida
	var nave = nivel.get_node("Nave")
	partida.set_physics_process(false)
	nivel.camera._process(2.0)
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	conferir(nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2(0, -80)), "Impulso aceito no pacote")
	for passo in range(180):
		partida.avancar(1.0 / 60)
	conferir(partida.estado == partida.Estado.CONCLUIDA and nave.combustivel == 4, "Rota exportada chega à Terra com uma cobrança")
	jogo.queue_free()
	await process_frame
	print("Exportação: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
