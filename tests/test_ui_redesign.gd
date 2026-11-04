extends SceneTree

var verificacoes := 0
var falhas := 0

func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)

func _initialize() -> void:
	_executar.call_deferred()

func acomodar() -> void:
	for i in 6:
		await process_frame

func _executar() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(180, 320)
	var suporte := SubViewportContainer.new()
	root.add_child(suporte)
	suporte.add_child(viewport)
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	jogo.ativar_audio = false
	viewport.add_child(jogo)
	await acomodar()
	var menu: Control = jogo.interface_atual
	var splash: Control = menu.get_node("Splash")
	conferir(splash.size == Vector2(180, 320) and splash.find_children("*", "TextureRect", true, false).size() == 2, "Splash apresenta as duas marcas")
	splash.free()
	var acoes: HBoxContainer = menu.get_node("Margem/Rolagem/VBoxContainer/Acoes")
	var titulo: Label = menu.get_node("Margem/Rolagem/VBoxContainer/Titulo")
	conferir(titulo.get_theme_font("font").resource_path.ends_with("orbt-pixel.fnt") and not menu.get_node("Margem/Rolagem/VBoxContainer/Narrativa").visible, "Título usa fonte bitmap sem subtítulo")
	for altura in [240, 320, 390]:
		viewport.size.y = altura
		await acomodar()
		var area := Rect2(Vector2.ZERO, Vector2(viewport.size))
		conferir(acoes.get_child_count() == 3 and acoes.get_children().all(func(b): return area.encloses(b.get_global_rect())), "Três ações cabem em 180x%d" % altura)
		var jogar: Button = acoes.get_child(0)
		conferir(jogar.size.x > acoes.get_child(1).size.x and jogar.size.y > acoes.get_child(1).size.y, "Jogar é maior que as ações secundárias")
		conferir(jogar.get_theme_stylebox("normal").bg_color != jogar.get_theme_stylebox("pressed").bg_color and jogar.get_theme_stylebox("normal").bg_color != jogar.get_theme_stylebox("hover").bg_color, "Hover e pressed têm estados distintos")
	var itens: Array = jogo.get_node("GerenciadorDeNivel").itens
	jogo.progresso.concluir(itens[0].id, itens)
	jogo.get_node("GerenciadorDeNivel").itens = []
	jogo.mostrar_selecao()
	await acomodar()
	var selecao: Control = jogo.interface_atual
	conferir(selecao.cartoes.columns == 4, "Seleção usa quatro colunas")
	conferir(selecao.cartoes.get_child_count() == itens.size(), "Abrir seleção relê o catálogo sem depender da lista em memória")
	conferir(not selecao.find_children("*", "Button", true, false).any(func(b): return b.text.contains("Atualizar")), "Seleção não oferece atualização manual")
	for i in 3:
		var fase: Button = selecao.cartoes.get_child(i).get_child(2)
		conferir(fase.icon != null and not fase.accessibility_name.is_empty(), "Fase tem ícone e descrição acessível")
	conferir(selecao.cartoes.get_child(2).get_child(2).disabled, "Fase bloqueada continua indisponível")
	conferir(jogo.iniciar_fase(itens[1].id), "Fase disponível mantém abertura normal")
	await acomodar()
	jogo.mundo_atual.partida.set_physics_process(false)
	var hud: CanvasLayer
	for filho in jogo.mundo_atual.get_children():
		if filho is CanvasLayer and filho.has_method("_alternar_pausa"):
			hud = filho
	conferir(hud._pausa.text.is_empty() and hud._pausa.icon != null, "Pausa usa apenas ícone durante o jogo")
	conferir(hud._mensagem.visible and hud._mensagem.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Ajuda inicial aparece sem capturar gestos")
	hud._process(6.1)
	conferir(not hud._mensagem.visible, "Ajuda desaparece após seis segundos")
	var partida: Node = jogo.mundo_atual.partida
	var saldo: int = partida.nave.combustivel
	var tempo: float = partida.tempo_restante
	hud._pausa.pressed.emit()
	hud._process(0)
	conferir(hud._dialogo_pausa.visible and not hud._raiz.visible and paused, "Pausa abre diálogo e interrompe simulação")
	conferir(hud._dialogo_pausa.find_children("*", "Button", true, false).size() == 3, "Diálogo tem exatamente três ações")
	for altura in [240, 320, 390]:
		viewport.size.y = altura
		await acomodar()
		var segura := Rect2(8, 16, 164, altura - 32)
		preload("res://src/Visual/area_segura_menu.gd").aplicar(hud._dialogo_pausa._margem, 8, viewport.get_screen_transform() * segura)
		await acomodar()
		conferir(hud._dialogo_pausa.find_children("*", "Button", true, false).all(func(b): return segura.encloses(b.get_global_rect())), "Três ações da pausa respeitam recortes em 180x%d" % altura)
	hud._dialogo_pausa._continuar.pressed.emit()
	hud._process(0)
	conferir(not paused and not hud._dialogo_pausa.visible and partida.nave.combustivel == saldo and partida.tempo_restante == tempo, "Continuar preserva combustível e tempo")
	conferir(not hud._mensagem.visible, "Continuar não repete a ajuda já encerrada")
	partida.pausar()
	hud._process(0)
	hud._dialogo_pausa._resetar.pressed.emit()
	hud._process(0)
	conferir(not paused and partida.estado == partida.Estado.JOGANDO and partida.nave.combustivel == partida.nivel.combustivel_inicial, "Resetar inicia nova tentativa")
	conferir(not hud._topo.get_global_rect().has_point(Vector2(90, 195)) and not hud._rolagem_rodape.get_global_rect().has_point(Vector2(90, 195)), "HUD deixa o centro livre")
	partida.finalizar(true, "Chegada à Terra")
	hud._process(0)
	conferir(hud._dialogo_conclusao.visible and not hud._raiz.visible and not hud._dialogo_pausa.visible, "Conclusão substitui o HUD pelo diálogo de vitória")
	for altura in [240, 320, 390]:
		viewport.size.y = altura
		await acomodar()
		var segura := Rect2(8, 16, 164, altura - 32)
		preload("res://src/Visual/area_segura_menu.gd").aplicar(hud._dialogo_conclusao._margem, 8, viewport.get_screen_transform() * segura)
		await acomodar()
		conferir(hud._dialogo_conclusao.find_children("*", "Button", true, false).filter(func(b): return b.is_visible_in_tree()).all(func(b): return segura.encloses(b.get_global_rect())), "Diálogo de vitória respeita recortes em 180x%d" % altura)
	hud._dialogo_conclusao._resetar.pressed.emit()
	hud._process(0)
	conferir(partida.estado == partida.Estado.JOGANDO and hud._raiz.visible and not hud._dialogo_conclusao.visible, "Repetir fecha o diálogo e reinicia a fase")
	partida.finalizar(true, "Chegada à Terra")
	hud._process(0)
	hud._dialogo_conclusao._menu.pressed.emit()
	await acomodar()
	conferir(jogo.interface_atual.find_children("*", "Button", true, false).size() == 3, "Voltar da vitória abre o menu com somente três ações")
	jogo.queue_free()
	await acomodar()
	suporte.queue_free()
	print("Redesign UI: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas else 0)
