class_name GerenciadorCorposEstelares extends Node2D

const CenaCorpo = preload("res://src/CorpoEstelar/CorpoEstelar.tscn")


static func criar(dados: Dictionary) -> Node2D:
	var corpo = CenaCorpo.instantiate()
	corpo.dados = dados.duplicate(true)
	return corpo
