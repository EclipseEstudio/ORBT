extends SceneTree

const Area = preload("res://src/Visual/area_segura_menu.gd")
var verificacoes := 0
var falhas := 0

func _initialize() -> void:
	_executar.call_deferred()

func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)

func acomodar() -> void:
	for i in range(4):
		await process_frame

func _executar() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(180, 240)
	var suporte := SubViewportContainer.new()
	root.add_child(suporte)
	suporte.add_child(viewport)
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	jogo.ativar_audio = false
	viewport.add_child(jogo)
	await acomodar()
	var menu = jogo.interface_atual
	var segura := Rect2(8, 16, 164, 208)
	var fisica: Rect2 = viewport.get_screen_transform() * segura
	Area.aplicar(menu.get_node("Margem"), 8, fisica)
	menu._exibir_aviso("Checkpoint incompatível. ".repeat(8))
	await acomodar()
	var rolagem: ScrollContainer = menu.get_node("Margem/Rolagem")
	var coluna = rolagem.get_child(0)
	conferir(segura.encloses(rolagem.get_global_rect()), "Menu respeita recortes simulados nas quatro bordas")
	conferir(rolagem.get_v_scroll_bar().visible and not rolagem.get_h_scroll_bar().visible, "Diagnóstico longo usa apenas rolagem vertical")
	var reiniciar: Button = coluna.get_node("DescartarCheckpoint")
	rolagem.ensure_control_visible(reiniciar)
	await acomodar()
	conferir(rolagem.get_global_rect().encloses(reiniciar.get_global_rect()), "Reiniciar fica acessível ao rolar diagnóstico longo")
	var configuracoes: Button = coluna.get_node("Configuracoes")
	rolagem.ensure_control_visible(configuracoes)
	await acomodar()
	conferir(rolagem.get_global_rect().encloses(configuracoes.get_global_rect()), "Configurações continuam acessíveis no menu curto")
	configuracoes.pressed.emit()
	var tela = menu.get_node("TelaConfiguracoes")
	Area.aplicar(tela._margem, 0, fisica)
	await acomodar()
	var scroll: ScrollContainer = tela._margem.get_child(0)
	conferir(segura.encloses(scroll.get_global_rect()), "Configurações respeitam área segura")
	for nome in ["musica", "efeitos", "Voltar"]:
		var controle: Control = tela.find_child(nome, true, false)
		scroll.ensure_control_visible(controle)
		await acomodar()
		conferir(scroll.get_global_rect().encloses(controle.get_global_rect()), nome + ": controle alcançável por rolagem")
	tela.find_child("Voltar", true, false).pressed.emit()
	await acomodar()
	coluna.get_node("Creditos").pressed.emit()
	var creditos = menu.get_node("TelaCreditos")
	Area.aplicar(creditos._margem, 0, fisica)
	await acomodar()
	var voltar: Button = creditos.find_child("Voltar", true, false)
	conferir(segura.encloses(voltar.get_global_rect()), "Voltar dos créditos permanece na área segura")
	viewport.size = Vector2i(180, 390)
	await acomodar()
	conferir(Rect2(0, 0, 180, 390).encloses(voltar.get_global_rect()), "Créditos se adaptam ao redimensionamento")
	creditos.free()
	conferir(jogo.iniciar_fase("teste_001"), "Abre fase para verificar configurações na pausa")
	await acomodar()
	var partida = jogo.mundo_atual.partida
	var hud: CanvasLayer
	for filho in jogo.mundo_atual.get_children():
		if filho is CanvasLayer and filho.has_method("_abrir_configuracoes"):
			hud = filho
	partida.set_physics_process(false)
	partida.pausar()
	var saldo: int = partida.nave.combustivel
	for altura in [240, 390]:
		viewport.size = Vector2i(180, altura)
		await acomodar()
		var recorte := Rect2(8, 16, 164, altura - 32)
		var recorte_fisico: Rect2 = viewport.get_screen_transform() * recorte
		Area.aplicar(hud._raiz, 0, recorte_fisico)
		hud._abrir_configuracoes()
		var tela_pausa = hud.find_child("TelaConfiguracoes", true, false)
		Area.aplicar(tela_pausa._margem, 0, recorte_fisico)
		await acomodar()
		conferir(tela_pausa.get_global_rect().is_equal_approx(Rect2(0, 0, 180, altura)), "Fundo da configuração em pausa cobre viewport inteiro: %d" % altura)
		conferir(tela_pausa._margem.get_global_rect().is_equal_approx(recorte), "Área segura aplicada uma única vez na pausa: %d" % altura)
		var quantidade := hud.get_child_count()
		hud._abrir_configuracoes()
		conferir(hud.get_child_count() == quantidade, "Abrir configurações novamente não duplica a tela")
		var retorno: Button = tela_pausa.find_child("Voltar", true, false)
		tela_pausa._margem.get_child(0).ensure_control_visible(retorno)
		await acomodar()
		conferir(recorte.encloses(retorno.get_global_rect()), "Voltar da configuração pausada cabe na área segura")
		retorno.pressed.emit()
		await acomodar()
		conferir(paused and partida.estado == partida.Estado.PAUSADO and partida.nave.combustivel == saldo, "Fechar configurações preserva pausa e combustível")
		conferir(hud._raiz.get_global_rect().is_equal_approx(recorte), "Fechar configurações mantém área segura do HUD")
	paused = false
	suporte.queue_free()
	await process_frame
	print("Áreas dos menus: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas else 0)
