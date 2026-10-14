class_name GerenciadorDeNivel extends Node2D

const Carregador = preload("res://src/Nivel/carregador_fase.gd")
var nivel_packed := preload("res://src/Nivel/Nivel.tscn")
var caminho := "res://Recursos/Niveis.json"
var registro_niveis: Dictionary[String, NivelRes] = {}
var erros: Array[String] = []


func _ready() -> void:
	GLOBAL.gerendiador_de_nivel = self
	carregar_niveis()


func carregar_niveis() -> void:
	registro_niveis.clear()
	erros.clear()
	var json := JSON.new()
	if not FileAccess.file_exists(caminho) or json.parse(FileAccess.get_file_as_string(caminho)) != OK or not json.data is Dictionary:
		erros.append("Catálogo de fases ausente ou inválido")
		return
	for id_nivel in json.data:
		var arquivo = json.data[id_nivel]
		if not arquivo is String or not arquivo.begins_with("res://Recursos/Fases/") or ".." in arquivo:
			erros.append("%s: caminho de fase inválido" % id_nivel)
			continue
		var resultado := Carregador.carregar(arquivo)
		if resultado.nivel == null:
			erros.append_array(resultado.erros)
		elif resultado.nivel.id != id_nivel:
			erros.append("%s: ID diferente do arquivo" % id_nivel)
		else:
			registro_niveis[id_nivel] = resultado.nivel


func obter_nivel_res(id_nivel: String) -> NivelRes:
	return registro_niveis.get(id_nivel)


func obter_nivel_instancia(id_nivel: String) -> Node2D:
	var recurso := obter_nivel_res(id_nivel)
	if recurso == null:
		return null
	var instancia = nivel_packed.instantiate()
	instancia.nivel_res = recurso
	return instancia
