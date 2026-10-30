extends Control

const Tema = preload("res://src/Visual/tema_visual.gd")
const TelaConfiguracoes = preload("res://src/Configuracoes/tela_configuracoes.gd")


func _ready() -> void:
	theme = Tema.criar()

func configurar_checkpoint() -> void:
	var jogo = GLOBAL.controlador_jogo
	if jogo == null:
		return
	var coluna: VBoxContainer = $VBoxContainer
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
	if not jogo.checkpoint.dados.is_empty():
		var continuar := Button.new()
		continuar.text = "Continuar"
		continuar.custom_minimum_size = Vector2(120, 48)
		coluna.add_child(continuar)
		continuar.pressed.connect(func():
			if not jogo.continuar_checkpoint():
				_exibir_aviso(jogo.checkpoint.aviso))
	if not jogo.checkpoint.aviso.is_empty():
		_exibir_aviso(jogo.checkpoint.aviso)

func _exibir_aviso(texto: String) -> void:
	var coluna: VBoxContainer = $VBoxContainer
	var aviso := coluna.get_node_or_null("AvisoCheckpoint") as Label
	if aviso == null:
		aviso = Label.new()
		aviso.name = "AvisoCheckpoint"
		aviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		aviso.custom_minimum_size.x = 150
		coluna.add_child(aviso)
	aviso.text = texto
	if coluna.get_node_or_null("DescartarCheckpoint") == null:
		var descartar := Button.new()
		descartar.name = "DescartarCheckpoint"
		descartar.text = "Reiniciar fase"
		descartar.custom_minimum_size = Vector2(120, 48)
		coluna.add_child(descartar)
		descartar.pressed.connect(func():
			if GLOBAL.controlador_jogo.checkpoint.limpar():
				GLOBAL.controlador_jogo.mostrar_selecao.call_deferred()
			else:
				aviso.text = GLOBAL.controlador_jogo.checkpoint.aviso)


func _on_button_pressed() -> void:
	GLOBAL.controlador_jogo.mostrar_selecao.call_deferred()
