extends Control

const Tema = preload("res://src/Visual/tema_visual.gd")
const AreaSegura = preload("res://src/Visual/area_segura_menu.gd")
var _margem: MarginContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	theme = Tema.criar()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var fundo := ColorRect.new()
	fundo.color = Color("0b1423")
	add_child(fundo)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margem := MarginContainer.new()
	_margem = margem
	add_child(margem)
	margem.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for lado in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margem.add_theme_constant_override(lado, 12)
	var coluna := VBoxContainer.new()
	margem.add_child(coluna)
	var titulo := Label.new()
	titulo.text = "Créditos"
	titulo.add_theme_font_size_override("font_size", 14)
	coluna.add_child(titulo)
	var rolagem := ScrollContainer.new()
	rolagem.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rolagem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	coluna.add_child(rolagem)
	var texto := Label.new()
	texto.name = "Texto"
	texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.add_theme_font_size_override("font_size", 10)
	texto.text = "ORBT\nEclipse Estudio\n\nColaboradores do repositório\nMiguel Alves Cordeiro Braz\nRubensAugustoMM\n\nMotor\nGodot Engine — licença MIT\n\nArte\nSprites de identidade gerados com OpenAI ImageGen. Nenhuma licença pública adicional declarada.\n\nÁudio\nTrilhas e efeitos sintetizados para ORBT, sem amostras de terceiros. Licença pública não declarada.\n\nPropulsão\nEfeito em pixel art desenhado em código para ORBT, sem imagens de terceiros. Licença pública não declarada.\n\nFases\nCinco mapas adaptados do protótipo dev-macb/orbt."
	rolagem.add_child(texto)
	var voltar := Button.new()
	voltar.name = "Voltar"
	voltar.text = "Voltar"
	voltar.custom_minimum_size.y = 36
	coluna.add_child(voltar)
	voltar.pressed.connect(queue_free)
	get_viewport().size_changed.connect(_area_segura)
	_area_segura()

func _area_segura() -> void:
	AreaSegura.aplicar(_margem, 0, AreaSegura.fisica())

func _process(_delta: float) -> void:
	if OS.has_feature("android"):
		_area_segura()
