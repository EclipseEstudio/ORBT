extends Control

const Tema = preload("res://src/Visual/tema_visual.gd")
const TelaConfiguracoes = preload("res://src/Configuracoes/tela_configuracoes.gd")
const TelaCreditos = preload("res://src/MenuPrincipal/tela_creditos.gd")
const Narrativa = preload("res://src/Narrativa/narrativa.gd")
const AreaSegura = preload("res://src/Visual/area_segura_menu.gd")
const Icones = preload("res://src/Visual/icones_ui.gd")
const Fundo = preload("res://src/Visual/fundo_menu.gd")
const Splash = preload("res://src/MenuPrincipal/splash.gd")
var _acoes: HBoxContainer


func _ready() -> void:
	theme = Tema.criar()
	var fundo := Fundo.new()
	add_child(fundo)
	move_child(fundo, 0)
	$Margem/Rolagem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	$Margem/Rolagem.follow_focus = true
	get_viewport().size_changed.connect(_area_segura)
	_area_segura()
	var texto := Label.new()
	texto.name = "Narrativa"
	texto.text = ""
	texto.hide()
	texto.tooltip_text = Narrativa.INTRODUCAO
	texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texto.add_theme_font_size_override("font_size", 8)
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$Margem/Rolagem/VBoxContainer.add_child(texto)
	$Margem/Rolagem/VBoxContainer.move_child(texto, 0)
	var coluna: VBoxContainer = $Margem/Rolagem/VBoxContainer
	coluna.alignment = BoxContainer.ALIGNMENT_BEGIN
	var titulo := Label.new()
	titulo.name = "Titulo"
	titulo.text = "ORBT"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_override("font", preload("res://Recursos/Fontes/orbt-pixel.fnt"))
	titulo.add_theme_font_size_override("font_size", 40)
	titulo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	titulo.add_theme_color_override("font_color", Tema.DESTAQUE)
	coluna.add_child(titulo)
	coluna.move_child(titulo, 0)
	var espaco := Control.new()
	espaco.mouse_filter = Control.MOUSE_FILTER_IGNORE
	espaco.custom_minimum_size.y = 80
	espaco.size_flags_vertical = Control.SIZE_EXPAND_FILL
	coluna.add_child(espaco)
	_acoes = HBoxContainer.new()
	_acoes.name = "Acoes"
	_acoes.alignment = BoxContainer.ALIGNMENT_CENTER
	_acoes.add_theme_constant_override("separation", 5)
	coluna.add_child(_acoes)
	var jogar: Button = coluna.get_node("Button")
	jogar.reparent(_acoes)
	jogar.text = "Jogar"
	jogar.custom_minimum_size = Vector2(76, 42)
	jogar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	Icones.aplicar(jogar, "jogar", "Jogar: escolher fase", false)
	Tema.destacar(jogar)
	if not Splash.exibido:
		Splash.exibido = true
		var splash := Splash.new()
		splash.name = "Splash"
		add_child(splash)

func _area_segura() -> void:
	AreaSegura.aplicar($Margem, 8, AreaSegura.fisica())

func _process(_delta: float) -> void:
	if OS.has_feature("android"):
		_area_segura()

func configurar_acoes() -> void:
	var jogo = GLOBAL.controlador_jogo
	if jogo == null:
		return
	var configuracoes := Button.new()
	configuracoes.name = "Configuracoes"
	configuracoes.text = "Configurações"
	configuracoes.custom_minimum_size = Vector2(32, 32)
	configuracoes.add_theme_font_size_override("font_size", 12)
	_acoes.add_child(configuracoes)
	configuracoes.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	Icones.aplicar(configuracoes, "config", "Configurações")
	configuracoes.pressed.connect(func():
		if not has_node("TelaConfiguracoes"):
			var tela := TelaConfiguracoes.new()
			tela.name = "TelaConfiguracoes"
			tela.preferencias = jogo.preferencias
			add_child(tela))
	var creditos := Button.new()
	creditos.name = "Creditos"
	creditos.text = "Créditos"
	creditos.custom_minimum_size = Vector2(32, 32)
	creditos.add_theme_font_size_override("font_size", 12)
	_acoes.add_child(creditos)
	creditos.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	Icones.aplicar(creditos, "info", "Créditos")
	creditos.pressed.connect(func():
		if not has_node("TelaCreditos"):
			var tela := TelaCreditos.new()
			tela.name = "TelaCreditos"
			add_child(tela))


func _on_button_pressed() -> void:
	GLOBAL.controlador_jogo.mostrar_selecao.call_deferred()
