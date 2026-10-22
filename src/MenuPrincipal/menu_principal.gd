extends Control


func _on_button_pressed() -> void:
	if not GLOBAL.controlador_jogo.iniciar_fase("teste_001"):
		$VBoxContainer/Button.text = "Fase indisponível"
		$VBoxContainer/Button.tooltip_text = "\n".join(GLOBAL.gerendiador_de_nivel.erros)
		var diagnostico := Label.new()
		diagnostico.text = $VBoxContainer/Button.tooltip_text
		diagnostico.custom_minimum_size.x = 160
		diagnostico.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		diagnostico.add_theme_font_size_override("font_size", 9)
		$VBoxContainer.add_child(diagnostico)
		$VBoxContainer/Button.disabled = true
