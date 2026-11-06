extends RefCounted
## Contrato e implementação em memória para testes; o serviço de disco herda esta base.

signal alterado
var concluidas: Dictionary = {}
var liberadas: Dictionary = {}
var melhores_estrelas: Dictionary = {}
var melhores_azuis: Dictionary = {}
var _itens: Array = []


func descricao() -> String:
	return "Progresso de teste: vale somente nesta sessão."


func salvamento_pendente() -> bool:
	return false


func aviso_para_partida() -> String:
	return ""


func configurar(itens: Array) -> void:
	_itens = itens.duplicate(true)
	if not itens.is_empty():
		liberadas[itens[0].id] = true
	# Uma campanha pode ganhar fases depois da conclusão da antiga última.
	for indice in range(itens.size() - 1):
		if concluidas.has(itens[indice].id):
			liberadas[itens[indice + 1].id] = true


func estado(id: String) -> String:
	if not pode_abrir(id):
		return "Bloqueada"
	if concluidas.has(id):
		return "Concluída"
	return "Disponível"


func pode_abrir(id: String) -> bool:
	var indice := _itens.find_custom(func(item: Dictionary): return item.id == id)
	if indice < 0 or not bloqueio(id).is_empty():
		return false
	for anterior in range(indice):
		if not concluidas.has(_itens[anterior].id):
			return false
	return indice == 0 or liberadas.has(id) or concluidas.has(id)


func bloqueio(id: String) -> String:
	var indice := -1
	for i in range(_itens.size()):
		if _itens[i].id == id:
			indice = i
	for inicio in range(0, maxi(0, indice / 10) * 10, 10):
		var total := 0
		var obtidas := 0
		for i in range(inicio, mini(inicio + 10, _itens.size())):
			var quantidade: int = _itens[i].get("estrelas", 3)
			total += quantidade
			obtidas += mini(quantidade, melhor_estrelas(_itens[i].id))
		var exigidas := ceili(total * 0.8)
		if obtidas < exigidas:
			return "Conjunto %d: %d/%d douradas. Meta: %d (80%%)." % [inicio / 10 + 1, obtidas, total, exigidas]
	return ""


func melhor_azuis(id: String) -> int:
	return int(melhores_azuis.get(id, 0))


func registrar_azuis(id: String, quantidade: int) -> bool:
	if not concluidas.has(id) or quantidade <= melhor_azuis(id) or quantidade > 256:
		return false
	melhores_azuis[id] = quantidade
	alterado.emit()
	return true


func concluir_com_coletas(id: String, itens: Array, douradas: int, azuis: int) -> bool:
	var mudou := concluir_com_estrelas(id, itens, douradas)
	return registrar_azuis(id, azuis) or mudou


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
