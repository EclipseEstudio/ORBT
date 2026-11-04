extends SceneTree

var verificacoes := 0
var falhas := 0

func conferir(ok: bool, mensagem: String) -> void:
	verificacoes += 1
	if not ok:
		falhas += 1
		push_error(mensagem)

func _initialize() -> void:
	_executar.call_deferred()

func acomodar() -> void:
	for i in 6:
		await process_frame

func _executar() -> void:
	var suporte := SubViewportContainer.new()
	root.add_child(suporte)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(180, 320)
	suporte.add_child(viewport)
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	jogo.ativar_audio = false
	viewport.add_child(jogo)
	await acomodar()
	jogo.iniciar_fase("teste_001")
	await acomodar()
	var nivel = jogo.mundo_atual
	var partida = nivel.partida
	partida.set_physics_process(false)
	var hud: CanvasLayer
	for filho in nivel.get_children():
		if filho.has_method("_alternar_pausa"):
			hud = filho
	var nave = partida.nave
	for cenario in ["ultimo_impulso", "sem_combustivel", "deriva", "colisao", "limites", "tempo"]:
		partida.reiniciar()
		nivel.camera._process(2)
		var causa := "Combustível esgotado"
		match cenario:
			"ultimo_impulso":
				nave.combustivel = 1
				nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2(0, -80))
				partida.avancar(1.0 / 60)
			"sem_combustivel":
				nave.combustivel = 0
				partida.avancar(0)
			"deriva":
				nave.condicao = nave.Condicao.A_DERIVA
				causa = "Nave à deriva"
				partida.avancar(0)
			"colisao":
				causa = "Colisão com perigo"
				partida.resolver_contato({"kind": "body", "body": {"type": "asteroid"}})
			"limites":
				causa = "Fora dos limites"
				partida.resolver_contato({"kind": "bounds"})
			"tempo":
				causa = "Tempo esgotado"
				nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2(0, -80))
				partida.avancar(1.0 / 60)
				partida.tempo_restante = 0
				partida.avancar(0)
		hud._process(0)
		conferir(partida.estado == partida.Estado.PERDIDA and not nave.simulacao_ativa, cenario + ": encerra simulação")
		conferir(hud._dialogo_derrota.visible and not hud._raiz.visible and not hud._dialogo_pausa.visible and not hud._dialogo_conclusao.visible, cenario + ": mostra apenas diálogo de fim")
		conferir(hud._dialogo_derrota._motivo.text == causa, cenario + ": mostra causa exata")
		var posicao: Vector2 = nave.global_position
		partida.avancar(10)
		conferir(nave.global_position == posicao, cenario + ": não continua voando")
		for altura in [240, 320, 390]:
			viewport.size.y = altura
			await acomodar()
			var segura := Rect2(8, 16, 164, altura - 32)
			preload("res://src/Visual/area_segura_menu.gd").aplicar(hud._dialogo_derrota._margem, 8, viewport.get_screen_transform() * segura)
			await acomodar()
			conferir(hud._dialogo_derrota.find_children("*", "Button", true, false).all(func(b): return segura.encloses(b.get_global_rect())), cenario + ": ações cabem na área segura em %d" % altura)
		hud._dialogo_derrota._resetar.pressed.emit()
		hud._process(0)
		conferir(partida.estado == partida.Estado.JOGANDO and not hud._dialogo_derrota.visible and partida.motivo.is_empty(), "Repetir limpa o fim de jogo")
	partida.finalizar(false, "Colisão com perigo. ".repeat(12))
	hud._process(0)
	await acomodar()
	conferir(hud._dialogo_derrota._rolagem_motivo.get_v_scroll_bar().visible, "Motivo longo pode ser lido por rolagem")
	hud._dialogo_derrota._continuar.pressed.emit()
	hud._process(0)
	conferir(partida.estado == partida.Estado.JOGANDO and not hud._dialogo_derrota.visible, "Último pouso recupera tentativa e fecha diálogo")
	partida.finalizar(false, "Fora dos limites")
	hud._process(0)
	hud._dialogo_derrota._menu.pressed.emit()
	await acomodar()
	conferir(jogo.interface_atual.has_node("Margem/Rolagem/VBoxContainer/Acoes"), "Voltar ao menu fecha fim de jogo")
	suporte.queue_free()
	await process_frame
	print("Fim de jogo: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas else 0)
