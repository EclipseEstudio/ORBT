extends "res://src/Campanha/progresso_sessao.gd"
## Progresso por ID. Gravação por substituição com cópia do último save válido.

var caminho := "user://progresso.json"
var geracao := 0
var aviso := ""
var _ultimo_valido := ""
var _bloqueado := false
var _sujo := false


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
	if versao != 1:
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
	var conteudo := {"schema_version": 1, "geracao": int(numero), "concluidas": dados.concluidas, "liberadas": dados.liberadas}
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
	for id in escolhido.dados.concluidas:
		concluidas[id] = true
	for id in escolhido.dados.liberadas:
		liberadas[id] = true
	geracao = escolhido.dados.geracao
	_ultimo_valido = escolhido.texto
	if principal.estado != "valido":
		aviso = "Progresso recuperado da última cópia válida."
	alterado.emit()
	return true


func concluir(id: String, itens: Array) -> bool:
	var mudou := super.concluir(id, itens)
	if mudou or _sujo:
		_sujo = true
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
	var dados := {"schema_version": 1, "geracao": geracao + 1, "concluidas": completas, "liberadas": abertas}
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
