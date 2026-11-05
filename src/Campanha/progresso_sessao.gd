extends RefCounted
## Contrato e implementação em memória para testes; o serviço de disco herda esta base.

signal alterado
var concluidas: Dictionary = {}
var liberadas: Dictionary = {}
var melhores_estrelas: Dictionary = {}


func descricao() -> String:
	return "Progresso de teste: vale somente nesta sessão."


func salvamento_pendente() -> bool:
	return false


func aviso_para_partida() -> String:
	return ""


func configurar(itens: Array) -> void:
	if not itens.is_empty():
		liberadas[itens[0].id] = true
	# Uma campanha pode ganhar fases depois da conclusão da antiga última.
	for indice in range(itens.size() - 1):
		if concluidas.has(itens[indice].id):
			liberadas[itens[indice + 1].id] = true


func estado(id: String) -> String:
	if concluidas.has(id):
		return "Concluída"
	return "Disponível" if liberadas.has(id) else "Bloqueada"


func pode_abrir(id: String) -> bool:
	return liberadas.has(id) or concluidas.has(id)


func melhor_estrelas(id: String) -> int:
	return int(melhores_estrelas.get(id, 0))


func total_estrelas() -> int:
	var total := 0
	for quantidade in melhores_estrelas.values():
		total += int(quantidade)
	return total


func registrar_estrelas(id: String, quantidade: int) -> bool:
	# Só uma conclusão autoriza confirmar o recurso; repetir melhora o recorde.
	if not concluidas.has(id) or quantidade <= melhor_estrelas(id) or quantidade > 256:
		return false
	melhores_estrelas[id] = quantidade
	alterado.emit()
	return true


func concluir_com_estrelas(id: String, itens: Array, quantidade: int) -> bool:
	if not itens.any(func(item: Dictionary): return item.id == id) or not pode_abrir(id):
		return false
	var concluiu := concluir(id, itens)
	var melhorou := registrar_estrelas(id, quantidade)
	return concluiu or melhorou


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
