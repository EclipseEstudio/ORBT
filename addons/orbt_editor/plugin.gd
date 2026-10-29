@tool
extends EditorPlugin

const Painel = preload("res://addons/orbt_editor/painel.gd")
var painel: Control


func _enter_tree() -> void:
	painel = Painel.new()
	EditorInterface.get_editor_main_screen().add_child(painel)
	painel.testar_solicitado.connect(_testar)
	_make_visible(false)


func _exit_tree() -> void:
	if is_instance_valid(painel):
		painel.guardar_rascunho()
		painel.testar_solicitado.disconnect(_testar)
		painel.get_parent().remove_child(painel)
		painel.queue_free()
	painel = null


func _has_main_screen() -> bool:
	return true


func _get_plugin_name() -> String:
	return "ORBT Fases"


func _make_visible(ativo: bool) -> void:
	if is_instance_valid(painel):
		painel.visible = ativo


func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("Edit", "EditorIcons")


func _testar() -> void:
	if EditorInterface.is_playing_scene():
		painel._diagnostico.text = "Encerre a execução atual antes de iniciar outro teste."
		return
	var erros: Array[String] = painel.documento.exportar_teste("res://.godot/orbt-editor-preview.json")
	if not erros.is_empty():
		painel._diagnostico.text = "\n".join(erros)
		return
	EditorInterface.play_custom_scene("res://addons/orbt_editor/teste.tscn")
