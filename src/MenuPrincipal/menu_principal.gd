extends Control

const Tema = preload("res://src/Visual/tema_visual.gd")
const TelaConfiguracoes = preload("res://src/Configuracoes/tela_configuracoes.gd")
const TelaCreditos = preload("res://src/MenuPrincipal/tela_creditos.gd")
const Narrativa = preload("res://src/Narrativa/narrativa.gd")
const AreaSegura = preload("res://src/Visual/area_segura_menu.gd")


func _ready() -> void:
	theme = Tema.criar()
	$Margem/Rolagem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	$Margem/Rolagem.follow_focus = true
	get_viewport().size_changed.connect(_area_segura)
	_area_segura()
	var texto := Label.new()
	texto.name = "Narrativa"
	texto.text = Narrativa.INTRODUCAO
	texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texto.add_theme_font_size_override("font_size", 9)
	$Margem/Rolagem/VBoxContainer.add_child(texto)
	$Margem/Rolagem/VBoxContainer.move_child(texto, 0)

func _area_segura() -> void:
	AreaSegura.aplicar($Margem, 8, AreaSegura.fisica())

func _process(_delta: float) -> void:
	if OS.has_feature("android"):
		_area_segura()

func configurar_checkpoint() -> void:
	var jogo = GLOBAL.controlador_jogo
	if jogo == null:
		return
	var coluna: VBoxContainer = $Margem/Rolagem/VBoxContainer
	var configuracoes := Button.new()
	configuracoes.name = "Configuracoes"
	configuracoes.text = "Configurações"
	configuracoes.custom_minimum_size = Vector2(120, 48)
	configuracoes.add_theme_font_size_override("font_size", 12)
	coluna.add_child(configuracoes)
	configuracoes.pressed.connect(func():
		if not has_node("TelaConfiguracoes"):
			var tela := TelaConfiguracoes.new()
			tela.name = "TelaConfiguracoes"
			tela.preferencias = jogo.preferencias
			add_child(tela))
	var creditos := Button.new()
	creditos.name = "Creditos"
	creditos.text = "Créditos"
	creditos.custom_minimum_size = Vector2(120, 48)
	creditos.add_theme_font_size_override("font_size", 12)
	coluna.add_child(creditos)
	creditos.pressed.connect(func():
		if not has_node("TelaCreditos"):
			var tela := TelaCreditos.new()
			tela.name = "TelaCreditos"
			add_child(tela))
	var checkpoint_disponivel: bool = jogo.checkpoint_disponivel()
	if checkpoint_disponivel:
		var continuar := Button.new()
		continuar.name = "Continuar"
		continuar.text = "Continuar"
		continuar.custom_minimum_size = Vector2(120, 48)
		continuar.add_theme_font_size_override("font_size", 12)
		coluna.add_child(continuar)
		continuar.pressed.connect(func():
			if not jogo.continuar_checkpoint():
				_exibir_aviso(jogo.checkpoint.aviso))
	if not jogo.checkpoint.aviso.is_empty():
		_exibir_aviso(jogo.checkpoint.aviso, checkpoint_disponivel)

func _exibir_aviso(texto: String, permitir_continuar := false) -> void:
	var coluna: VBoxContainer = $Margem/Rolagem/VBoxContainer
	coluna.get_node("Narrativa").hide()
	var continuar := coluna.get_node_or_null("Continuar") as Button
	if continuar != null and not permitir_continuar:
		continuar.hide()
	var aviso := coluna.get_node_or_null("AvisoCheckpoint") as Label
	if aviso == null:
		aviso = Label.new()
		aviso.name = "AvisoCheckpoint"
		aviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		aviso.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		aviso.add_theme_font_size_override("font_size", 9)
		coluna.add_child(aviso)
	aviso.text = texto
	if permitir_continuar:
		return
	if coluna.get_node_or_null("DescartarCheckpoint") == null:
		var descartar := Button.new()
		descartar.name = "DescartarCheckpoint"
		descartar.text = "Reiniciar fase"
		descartar.custom_minimum_size = Vector2(120, 48)
		descartar.add_theme_font_size_override("font_size", 12)
		coluna.add_child(descartar)
		descartar.pressed.connect(func():
			if GLOBAL.controlador_jogo.checkpoint.limpar():
				GLOBAL.controlador_jogo.mostrar_selecao.call_deferred()
			else:
				aviso.text = GLOBAL.controlador_jogo.checkpoint.aviso)


func _on_button_pressed() -> void:
	GLOBAL.controlador_jogo.mostrar_selecao.call_deferred()
