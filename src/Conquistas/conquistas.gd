extends RefCounted
## Conquistas derivadas dos recordes confirmados de fases do catálogo atual.

const TOTAL_AZUIS := 30


static func listar(progresso: RefCounted, itens: Array) -> Array:
	var lista: Array = []
	for bloco in 3:
		var fases := itens.slice(bloco * 10, (bloco + 1) * 10)
		var douradas := 0
		for fase in fases:
			if progresso.concluidas.has(fase.id):
				douradas += mini(3, progresso.melhor_estrelas(fase.id))
		lista.append(_conquista("nivel_%d" % (bloco + 1), "Nível %d dourado" % (bloco + 1), "Colete as 30 estrelas amarelas do nível %d." % (bloco + 1), "medalha", Color("ffc845"), douradas, 30, fases.size() == 10 and douradas >= 30))
	var azuis := 0
	var unicos := 0
	for fase in itens:
		if not progresso.concluidas.has(fase.id):
			continue
		azuis += mini(int(fase.get("azuis", 0)), progresso.melhor_azuis(fase.id))
		if progresso.fases_um_lancamento.has(fase.id):
			unicos += 1
	for meta in [10, 20, 30]:
		lista.append(_conquista("azuis_%d" % meta, "Explorador azul %d" % (meta / 10), "Colete %d estrelas azuis." % meta, "estrela", Color("57b9ff"), azuis, meta, azuis >= meta))
	lista.append(_conquista("todas_azuis", "Coleção celeste", "Colete todas as 30 estrelas azuis da campanha.", "medalha", Color("57b9ff"), azuis, TOTAL_AZUIS, azuis >= TOTAL_AZUIS))
	for meta in [5, 10]:
		lista.append(_conquista("um_lancamento_%d" % meta, "Impulso certeiro %d" % (1 if meta == 5 else 2), "Chegue à Terra com apenas 1 lançamento em %d fases distintas." % meta, "alvo", Color("72e6a2"), unicos, meta, unicos >= meta))
	return lista


static func _conquista(id: String, titulo: String, descricao: String, imagem: String, cor: Color, atual: int, meta: int, desbloqueada: bool) -> Dictionary:
	return {"id": id, "titulo": titulo, "descricao": descricao, "imagem": imagem, "cor": cor, "atual": mini(atual, meta), "meta": meta, "desbloqueada": desbloqueada}
