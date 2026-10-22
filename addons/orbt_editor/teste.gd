extends Node
## Executa somente a cópia temporária; não passa pelo fluxo de campanha/progresso.

const Carregador = preload("res://src/Nivel/carregador_fase.gd")
const CenaNivel = preload("res://src/Nivel/Nivel.tscn")
var nivel: Node2D


func _ready() -> void:
	var resultado := Carregador.carregar("res://.godot/orbt-editor-preview.json")
	if resultado.nivel == null:
		var mensagem := Label.new()
		mensagem.text = "Teste bloqueado:\n" + "\n".join(resultado.erros)
		add_child(mensagem)
		return
	nivel = CenaNivel.instantiate()
	nivel.nivel_res = resultado.nivel
	add_child(nivel)
	var camada := CanvasLayer.new()
	camada.layer = 20
	add_child(camada)
	var voltar := Button.new()
	voltar.text = "Voltar ao editor"
	voltar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	voltar.offset_top = -28
	voltar.pressed.connect(func(): get_tree().quit())
	camada.add_child(voltar)
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
