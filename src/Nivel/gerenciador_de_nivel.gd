class_name GerenciadorDeNivel extends Node2D

const Carregador = preload("res://src/Nivel/carregador_fase.gd")
const Catalogo = preload("res://src/Campanha/catalogo.gd")
var nivel_packed := preload("res://src/Nivel/Nivel.tscn")
var caminho := "res://Recursos/Niveis.json"
var erros: Array[String] = []
var itens: Array = []


func _ready() -> void:
	GLOBAL.gerendiador_de_nivel = self
	carregar_niveis()


func carregar_niveis() -> void:
	erros.clear()
	var resultado := Catalogo.carregar(caminho)
	itens = resultado.itens
	erros.assign(resultado.erros)


func obter_nivel_res(id_nivel: String) -> NivelRes:
	erros.clear()
	for item in itens:
		if item.id != id_nivel:
			continue
		var resultado := Carregador.carregar(item.arquivo)
		if resultado.nivel == null:
			erros.assign(resultado.erros)
			return null
		if resultado.nivel.id != id_nivel:
			erros.append("%s: ID diferente do arquivo" % id_nivel)
			return null
		return resultado.nivel
	erros.append("Fase inexistente: " + id_nivel)
	return null


func obter_nivel_instancia(id_nivel: String) -> Node2D:
	var recurso := obter_nivel_res(id_nivel)
	if recurso == null:
		return null
	var instancia = nivel_packed.instantiate()
	instancia.nivel_res = recurso
	return instancia
