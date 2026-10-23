extends RefCounted
## Contrato e implementação em memória para testes; o serviço de disco herda esta base.

signal alterado
var concluidas: Dictionary = {}
var liberadas: Dictionary = {}


func descricao() -> String:
	return "Progresso de teste: vale somente nesta sessão."


func salvamento_pendente() -> bool:
	return false


func aviso_para_partida() -> String:
	return ""


func configurar(itens: Array) -> void:
	if not itens.is_empty():
		liberadas[itens[0].id] = true


func estado(id: String) -> String:
	if concluidas.has(id):
		return "Concluída"
	return "Disponível" if liberadas.has(id) else "Bloqueada"


func pode_abrir(id: String) -> bool:
	return liberadas.has(id) or concluidas.has(id)


func concluir(id: String, itens: Array) -> bool:
	if not pode_abrir(id) or concluidas.has(id):
		return false
	for indice in range(itens.size()):
		if itens[indice].id == id:
			concluidas[id] = true
			if indice + 1 < itens.size():
				liberadas[itens[indice + 1].id] = true
			alterado.emit()
			return true
	return false
