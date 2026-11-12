extends "res://src/Campanha/progresso_sessao.gd"
## Progresso por ID. Gravação por substituição com cópia do último save válido.

var caminho := "user://progresso.json"
var geracao := 0
var aviso := ""
var _ultimo_valido := ""
var _bloqueado := false
var _sujo := false
var _agrupando := false


func descricao() -> String:
	return aviso if not aviso.is_empty() else "Progresso salvo neste aparelho."


func salvamento_pendente() -> bool:
	return _sujo and not _bloqueado


func aviso_para_partida() -> String:
	return "Progresso novo ainda não foi salvo." if _sujo else ""


func configurar(itens: Array) -> void:
	var quantidade_anterior := liberadas.size()
	super.configurar(itens)
	# A primeira configuração continua sem save; reconciliar um save válido é persistente.
	if liberadas.size() > quantidade_anterior and not _ultimo_valido.is_empty() and not _bloqueado:
		_sujo = true
		salvar()


func resetar() -> bool:
	super.resetar()
	_bloqueado = false
	_sujo = true
	if not salvar():
		return false
	# A cópia de segurança também precisa refletir o reset.
	if not _gravar(caminho + ".bak.tmp", _ultimo_valido) or DirAccess.rename_absolute(caminho + ".bak.tmp", caminho + ".bak") != OK:
		aviso = "Progresso resetado, mas não foi possível atualizar a cópia de segurança."
		return false
	return true


func _ler(arquivo: String) -> Dictionary:
	if not FileAccess.file_exists(arquivo):
		return {"estado": "ausente"}
	var texto := FileAccess.get_file_as_string(arquivo)
	var json := JSON.new()
	if json.parse(texto) != OK or not json.data is Dictionary:
		return {"estado": "invalido"}
	var dados: Dictionary = json.data
	var versao = dados.get("schema_version")
	if not (versao is int or versao is float) or not is_finite(float(versao)) or versao != floorf(versao):
		return {"estado": "invalido"}
	if int(versao) not in [1, 2, 3, 4]:
		return {"estado": "incompativel"}
	var numero = dados.get("geracao")
	if not (numero is float or numero is int) or not is_finite(numero) or numero < 1 or numero > 1000000000 or numero != floorf(numero):
		return {"estado": "invalido"}
	for campo in ["concluidas", "liberadas"]:
		if not dados.get(campo) is Array or dados[campo].size() > 10000:
			return {"estado": "invalido"}
		var ids: Dictionary = {}
		for id in dados[campo]:
			if not id is String or id.strip_edges().is_empty() or id.length() > 256 or ids.has(id):
				return {"estado": "invalido"}
			ids[id] = true
	for id in dados.concluidas:
		if id not in dados.liberadas:
			return {"estado": "invalido"}
	var conteudo := {"schema_version": int(versao), "geracao": int(numero), "concluidas": dados.concluidas, "liberadas": dados.liberadas}
	if versao >= 2:
		if not dados.get("melhores_estrelas") is Dictionary or dados.melhores_estrelas.size() > 10000:
			return {"estado": "invalido"}
		var recordes: Dictionary = {}
		for id in dados.melhores_estrelas:
			var quantidade = dados.melhores_estrelas[id]
			if id not in dados.concluidas or not (quantidade is int or quantidade is float) or not is_finite(float(quantidade)) or quantidade != floorf(quantidade) or quantidade < 1 or quantidade > 256:
				return {"estado": "invalido"}
			recordes[id] = int(quantidade)
		conteudo["melhores_estrelas"] = recordes
	if versao >= 3:
		if not dados.get("melhores_azuis") is Dictionary or dados.melhores_azuis.size() > 10000:
			return {"estado": "invalido"}
		var azuis: Dictionary = {}
		for id in dados.melhores_azuis:
			var quantidade = dados.melhores_azuis[id]
			if id not in dados.concluidas or not (quantidade is int or quantidade is float) or not is_finite(float(quantidade)) or quantidade != floorf(quantidade) or quantidade < 1 or quantidade > 256:
				return {"estado": "invalido"}
			azuis[id] = int(quantidade)
		conteudo["melhores_azuis"] = azuis
	if versao >= 4:
		if not dados.get("fases_um_lancamento") is Array or dados.fases_um_lancamento.size() > 10000:
			return {"estado": "invalido"}
		var fases: Dictionary = {}
		for id in dados.fases_um_lancamento:
			if not id is String or id not in dados.concluidas or fases.has(id):
				return {"estado": "invalido"}
			fases[id] = true
		conteudo["fases_um_lancamento"] = dados.fases_um_lancamento
	if dados.get("checksum") != JSON.stringify(conteudo, "", true).sha256_text():
		return {"estado": "invalido"}
	return {"estado": "valido", "dados": conteudo, "texto": texto}


func carregar() -> bool:
	# Não descartar vitórias ainda não gravadas ao tentar novamente.
	if _sujo:
		return false
	var principal := _ler(caminho)
	var backup := _ler(caminho + ".bak")
	aviso = ""
	_bloqueado = false
	if principal.estado == "incompativel":
		_bloqueado = true
		aviso = "Progresso de versão incompatível. Esta sessão não será salva."
		return false
	var escolhido: Dictionary = principal if principal.estado == "valido" else backup
	if escolhido.estado != "valido":
		if principal.estado != "ausente" or backup.estado != "ausente":
			_bloqueado = true
			aviso = "Progresso indisponível. Esta sessão não será salva."
		return false
	concluidas.clear()
	liberadas.clear()
	melhores_estrelas.clear()
	melhores_azuis.clear()
	fases_um_lancamento.clear()
	for id in escolhido.dados.concluidas:
		concluidas[id] = true
	for id in escolhido.dados.liberadas:
		liberadas[id] = true
	for id in escolhido.dados.get("melhores_estrelas", {}):
		melhores_estrelas[id] = int(escolhido.dados.melhores_estrelas[id])
	geracao = escolhido.dados.geracao
	for id in escolhido.dados.get("melhores_azuis", {}):
		melhores_azuis[id] = int(escolhido.dados.melhores_azuis[id])
	for id in escolhido.dados.get("fases_um_lancamento", []):
		fases_um_lancamento[id] = true
	_ultimo_valido = escolhido.texto
	if principal.estado != "valido":
		aviso = "Progresso recuperado da última cópia válida."
	alterado.emit()
	# Migrar apenas depois de verificar o checksum antigo; a cópia mantém o legado.
	if escolhido.dados.schema_version < 4:
		_sujo = true
		salvar()
	return true


func concluir(id: String, itens: Array) -> bool:
	var mudou := super.concluir(id, itens)
	if mudou or _sujo:
		_sujo = true
		if not _agrupando:
			salvar()
	return mudou


func registrar_estrelas(id: String, quantidade: int) -> bool:
	var mudou := super.registrar_estrelas(id, quantidade)
	if mudou or _sujo:
		_sujo = true
		if not _agrupando:
			salvar()
	return mudou


func concluir_com_estrelas(id: String, itens: Array, quantidade: int) -> bool:
	var ja_agrupando := _agrupando
	_agrupando = true
	var mudou := super.concluir_com_estrelas(id, itens, quantidade)
	_agrupando = ja_agrupando
	if _sujo and not _agrupando:
		salvar()
	return mudou


func registrar_azuis(id: String, quantidade: int) -> bool:
	var mudou := super.registrar_azuis(id, quantidade)
	if mudou or _sujo:
		_sujo = true
		if not _agrupando:
			salvar()
	return mudou


func registrar_lancamentos(id: String, quantidade: int) -> bool:
	var mudou := super.registrar_lancamentos(id, quantidade)
	if mudou or _sujo:
		_sujo = true
		if not _agrupando:
			salvar()
	return mudou


func concluir_com_coletas(id: String, itens: Array, douradas: int, azuis: int, lancamentos := -1) -> bool:
	var ja_agrupando := _agrupando
	_agrupando = true
	var mudou := super.concluir_com_coletas(id, itens, douradas, azuis, lancamentos)
	_agrupando = ja_agrupando
	if _sujo and not _agrupando:
		salvar()
	return mudou


func _gravar(arquivo: String, texto: String) -> bool:
	var fluxo := FileAccess.open(arquivo, FileAccess.WRITE)
	if fluxo == null:
		return false
	fluxo.store_string(texto)
	fluxo.flush()
	var erro := fluxo.get_error()
	fluxo.close()
	return erro == OK and FileAccess.get_file_as_string(arquivo) == texto


func salvar() -> bool:
	if _bloqueado:
		return false
	var completas: Array = concluidas.keys()
	var abertas: Array = liberadas.keys()
	completas.sort()
	abertas.sort()
	var fases: Array = fases_um_lancamento.keys()
	fases.sort()
	var dados := {"schema_version": 4, "geracao": geracao + 1, "concluidas": completas, "liberadas": abertas, "melhores_estrelas": melhores_estrelas.duplicate(), "melhores_azuis": melhores_azuis.duplicate(), "fases_um_lancamento": fases}
	dados["checksum"] = JSON.stringify(dados, "", true).sha256_text()
	var texto := JSON.stringify(dados, "\t") + "\n"
	aviso = "Não foi possível salvar. O progresso novo vale só nesta sessão."
	if not _gravar(caminho + ".tmp", texto) or _ler(caminho + ".tmp").estado != "valido":
		return false
	if not _ultimo_valido.is_empty():
		if not _gravar(caminho + ".bak.tmp", _ultimo_valido) or DirAccess.rename_absolute(caminho + ".bak.tmp", caminho + ".bak") != OK:
			return false
	if DirAccess.rename_absolute(caminho + ".tmp", caminho) != OK:
		return false
	geracao += 1
	_ultimo_valido = texto
	_sujo = false
	aviso = ""
	alterado.emit()
	return true
