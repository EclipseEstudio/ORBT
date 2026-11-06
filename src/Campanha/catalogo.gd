extends RefCounted
## Lê somente metadados autorais; a validação física acontece ao abrir a escolha.

static func carregar(caminho: String) -> Dictionary:
	var erros: Array[String] = []
	var itens: Array[Dictionary] = []
	if not FileAccess.file_exists(caminho):
		return {"itens": itens, "erros": ["Catálogo ausente: " + caminho]}
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(caminho)) != OK or not json.data is Dictionary:
		return {"itens": itens, "erros": ["Catálogo inválido: esperado objeto com IDs e caminhos de fases"]}
	var arquivos: Dictionary = {}
	for id in json.data:
		var arquivo = json.data[id]
		if not arquivo is String or not arquivo.begins_with("res://Recursos/Fases/") or ".." in arquivo or not arquivo.ends_with(".json"):
			erros.append("%s: caminho inválido" % id)
			continue
		if arquivos.has(arquivo):
			erros.append("%s: arquivo duplicado no catálogo" % id)
			continue
		arquivos[arquivo] = true
		var fase := JSON.new()
		if not FileAccess.file_exists(arquivo) or fase.parse(FileAccess.get_file_as_string(arquivo)) != OK or not fase.data is Dictionary:
			erros.append("%s: arquivo ausente ou JSON inválido" % id)
			continue
		var dados: Dictionary = fase.data
		var ordem = dados.get("order")
		if str(id).strip_edges().is_empty() or dados.get("id") != id or not dados.get("name") is String or dados.name.strip_edges().is_empty() or not (ordem is int or ordem is float) or not is_finite(float(ordem)) or ordem < 1 or ordem > 1000000 or ordem != floorf(ordem):
			erros.append("%s: ID, nome ou ordem inválidos" % id)
			continue
		var estrelas := 0
		var azuis := 0
		var coletas: Array = dados.stars if dados.get("stars") is Array else []
		for estrela in coletas:
			if not estrela is Dictionary:
				continue
			if estrela.get("type", "gold") == "blue":
				azuis += 1
			else:
				estrelas += 1
		itens.append({"id": id, "nome": dados.name, "ordem": int(ordem), "arquivo": arquivo, "estrelas": estrelas, "azuis": azuis})
	itens.sort_custom(func(a: Dictionary, b: Dictionary): return a.id < b.id if a.ordem == b.ordem else a.ordem < b.ordem)
	# Falha fechada: um catálogo parcial não muda silenciosamente a progressão.
	return {"itens": itens if erros.is_empty() else [], "erros": erros}
