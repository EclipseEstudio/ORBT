extends SceneTree

const Tema = preload("res://src/Visual/tema_visual.gd")
const Bussola = preload("res://src/Visual/bussola_terra.gd")
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
	var tema := Tema.criar()
	conferir(tema.default_font == Tema.FONTE and tema.default_font_size == 8, "Tema usa Press Start 2P a 8 px")
	for letra in "áàâãéêíóôõúçÁÉÍÓÚÇ":
		conferir(Tema.FONTE.has_char(letra.unicode_at(0)), "Fonte contém acento: " + letra)
	conferir(Tema.FONTE.get_string_size("Configurações", HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x <= 140, "Configurações cabe em painel de 180 px")
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
	jogo.interface_atual.get_node("Splash").free()
	jogo.interface_atual.get_node("Margem/Rolagem/VBoxContainer/Acoes/Configuracoes").pressed.emit()
	var configuracoes: Control = jogo.interface_atual.get_node("TelaConfiguracoes")
	conferir(configuracoes.has_node("Fundo") and configuracoes.find_child("Painel", true, false) is PanelContainer, "Configurações compartilham fundo e painel com borda")
	var voltar: Button = configuracoes.find_child("Voltar", true, false)
	conferir(voltar.text.is_empty() and voltar.icon_alignment == HORIZONTAL_ALIGNMENT_CENTER and voltar.size_flags_horizontal == Control.SIZE_SHRINK_CENTER, "Voltar é um botão de ícone centralizado")
	configuracoes.free()
	conferir(jogo.iniciar_fase("teste_001"), "Abre fase para verificar HUD e gestos")
	await acomodar()
	var mundo = jogo.mundo_atual
	var partida = mundo.partida
	partida.set_physics_process(false)
	mundo.camera._process(2)
	mundo.camera.set_process(false)
	mundo.camera.force_update_scroll()
	var nave = partida.nave
	var hud: CanvasLayer
	for filho in mundo.get_children():
		if filho.has_method("_alternar_pausa"):
			hud = filho
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	hud._process(0)
	await acomodar()
	conferir(hud._raiz.has_node("BussolaTerra") and hud._bussola.is_visible_in_tree(), "Bússola existe e aparece durante a partida")
	conferir(hud._fase.text == "01", "Topo mostra somente o número da fase")
	for botao in [hud._explorar, hud._pausa]:
		conferir(botao.text.is_empty() and botao.icon_alignment == HORIZONTAL_ALIGNMENT_CENTER and botao.size == Vector2(28, 28), "HUD tem botões de ícone de tamanho fixo")
	for altura in [240, 320, 390]:
		viewport.size.y = altura
		await acomodar()
		hud._process(0)
		await acomodar()
		var area := Rect2(Vector2.ZERO, Vector2(viewport.size))
		conferir(area.encloses(hud._base_status.get_global_rect()) and is_equal_approx(hud._indicadores.size.x, 168), "Combustível e barra ocupam base útil em %d px" % altura)
		conferir(not hud._rolagem_rodape.get_global_rect().intersects(hud._base_status.get_global_rect()), "Ajuda e exploração não cobrem combustível ou oxigênio em %d px" % altura)
	for zoom in [0.25, 1.0, 4.0]:
		mundo.camera.zoom = Vector2.ONE * zoom
		mundo.camera.force_update_scroll()
		hud._process(0)
		var tela_nave: Vector2 = nave.get_global_transform_with_canvas().origin
		var tela_terra: Vector2 = nave.get_canvas_transform() * Vector2(nave.corpos[-1].position)
		conferir(hud._bussola.direcao.is_equal_approx(Bussola.calcular_direcao(tela_nave, tela_terra)), "Direção acompanha câmera com zoom %.2f" % zoom)
		var tela_ponteiro: Vector2 = hud._bussola.get_global_transform_with_canvas() * hud._bussola.centro
		conferir(is_equal_approx(tela_ponteiro.distance_to(tela_nave), Bussola.DISTANCIA), "Distância da bússola em pixels permanece fixa")
	partida.pausar()
	hud._process(0)
	conferir(not hud._bussola.is_visible_in_tree(), "Pausa oculta bússola")
	partida.retomar()
	hud._process(0)
	conferir(hud._bussola.is_visible_in_tree(), "Retomar mostra bússola")
	partida.finalizar(true, "Terra")
	hud._process(0)
	conferir(not hud._bussola.is_visible_in_tree(), "Resultado oculta bússola")
	partida.reiniciar()
	mundo.camera._process(2)
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	var mira: Node2D = nave.get_node("Indicadores/Mira")
	conferir(mira.pontos_forca().is_empty(), "Sem toque não há linha de força")
	nave.entrada.gesto.iniciar(0, Vector2(60, 100))
	nave.entrada.gesto.mover(0, Vector2(80, 120))
	conferir(mira.pontos_forca() == PackedVector2Array([Vector2(60, 100), Vector2(80, 120)]) and not mira.forca_saturada(), "Linha liga toque inicial ao dedo, sem depender da câmera")
	nave.entrada.gesto.mover(0, Vector2(60, 220))
	conferir(mira.forca_saturada() and mira.pontos_forca()[1] == Vector2(60, 220), "Saturação mantém extremidade no dedo além do limite")
	var guia: PackedVector2Array = nave.obter_guia_mira()
	conferir(guia.size() == 2 and is_equal_approx((nave.get_canvas_transform() * guia[0]).distance_to(nave.get_canvas_transform() * guia[1]), 60), "Linha de força preserva guia fixa")
	nave.entrada.cancelar()
	conferir(mira.pontos_forca().is_empty(), "Cancelar remove linha de força")
	# Gesto real pela entrada: repetir a liberação não cria outro impulso.
	var saldo: int = nave.combustivel
	for pressionado in [true, false, false]:
		var toque := InputEventScreenTouch.new()
		toque.index = 2
		toque.pressed = pressionado
		toque.position = Vector2(90, 100) if pressionado else Vector2(90, 180)
		nave.entrada._unhandled_input(toque)
	partida.avancar(1.0 / 60)
	conferir(nave.combustivel == saldo - 1 and not nave.tem_impulso_pendente(), "Um gesto consome exatamente uma carga, mesmo com liberação repetida")
	# Deriva isolada de colisões: apenas o oxigênio pode encerrar a tentativa.
	nave.corpos = []
	nave.global_position = Vector2.ZERO
	nave.velocidade = Vector2.RIGHT * 10
	nave.limites = Rect2(-1000, -1000, 2000, 2000)
	nave.combustivel = 0
	nave.condicao = nave.Condicao.A_DERIVA
	nave.atualizar_entrada()
	partida.tempo_restante = 0.05
	partida.avancar(0.02)
	conferir(partida.estado == partida.Estado.JOGANDO and nave.global_position.x > 0 and is_equal_approx(partida.tempo_restante, 0.03), "Sem combustível a nave avança e consome oxigênio")
	partida.pausar()
	partida.retomar()
	partida.avancar(0.02)
	conferir(partida.estado == partida.Estado.JOGANDO and nave.combustivel == 0, "Retomar não derrota nave à deriva")
	partida.avancar(0.02)
	conferir(partida.estado == partida.Estado.PERDIDA and partida.motivo == "Oxigênio esgotado" and is_zero_approx(partida.tempo_restante), "Deriva termina quando o oxigênio chega a zero")
	hud._process(0)
	conferir(not hud._bussola.is_visible_in_tree(), "Derrota oculta bússola")
	partida.reiniciar()
	mundo.camera._process(2)
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	partida.temporizador_ativo = true
	partida.tempo_restante = 0.001
	nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2.UP * 80)
	partida.avancar(0.02)
	conferir(is_zero_approx(partida.tempo_restante) and partida.estado == partida.Estado.PERDIDA and partida.motivo == "Oxigênio esgotado", "Novo impulso não recarrega o saldo quase esgotado")
	suporte.queue_free()
	await process_frame
	print("HUD e voo: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas else 0)
