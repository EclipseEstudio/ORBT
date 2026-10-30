extends RefCounted
## Checkpoint independente do progresso de campanha.

var caminho := "user://checkpoint.json"
var aviso := ""
var bloqueado := false
var _ultimo := ""
var dados: Dictionary = {}

func _numero(valor, minimo: float, maximo: float) -> bool:
	return (valor is int or valor is float) and is_finite(float(valor)) and valor >= minimo and valor <= maximo

func validar(nivel: NivelRes) -> Dictionary:
	if nivel == null or dados.get("fase") != nivel.id or dados.get("content_version") != nivel.dados_autorais.get("content_version"):
		aviso = "Checkpoint de fase ou versão incompatível. Reinicie a fase."
		bloqueado = true
		return {}
	if not dados.get("corpo") is String or not dados.get("temporizador_ativo") is bool:
		aviso = "Checkpoint inválido. Reinicie a fase."
		bloqueado = true
		return {}
	var corpo: Dictionary = nivel.obter_corpo(dados.corpo) if not dados.corpo.is_empty() else {}
	var valido: bool = dados.corpo.is_empty() or (not corpo.is_empty() and corpo.type in ["planet", "satellite"])
	for campo in ["posicao", "posicao_relativa"]:
		var v = dados.get(campo)
		valido = valido and v is Array and v.size() == 2
		if valido:
			valido = _numero(v[0], -1000000, 1000000) and _numero(v[1], -1000000, 1000000)
	valido = valido and _numero(dados.get("orientacao"), -1000000, 1000000)
	var combustivel = dados.get("combustivel")
	valido = valido and _numero(combustivel, 0, nivel.combustivel_inicial)
	if valido:
		valido = float(combustivel) == floorf(float(combustivel))
	valido = valido and _numero(dados.get("tempo"), 0, nivel.tempo_voo)
	if not valido:
		aviso = "Checkpoint inválido. Reinicie a fase."
		bloqueado = true
		return {}
	var copia := dados.duplicate(true)
	copia.posicao = Vector2(copia.posicao[0], copia.posicao[1])
	copia.posicao_relativa = Vector2(copia.posicao_relativa[0], copia.posicao_relativa[1])
	if not corpo.is_empty():
		valido = absf(copia.posicao_relativa.length() - (corpo.collision_radius + nivel.parametros_nave.radius)) < 0.01
		valido = valido and copia.posicao.distance_to(corpo.position + copia.posicao_relativa) < 0.01
	else:
		valido = nivel.inicio.has("position") and copia.posicao.is_equal_approx(nivel.obter_posicao_inicial()) and copia.posicao_relativa.is_zero_approx()
	if not valido:
		aviso = "Posição do checkpoint incompatível. Reinicie a fase."
		bloqueado = true
		return {}
	return copia

func _ler(arquivo: String) -> Dictionary:
	if not FileAccess.file_exists(arquivo):
		return {"estado": "ausente"}
	var texto := FileAccess.get_file_as_string(arquivo)
	var json := JSON.new()
	if texto.length() > 32768 or json.parse(texto) != OK or not json.data is Dictionary:
		return {"estado": "invalido"}
	var envelope: Dictionary = json.data
	if envelope.get("schema_version") != 1:
		return {"estado": "incompativel"}
	if not envelope.get("checkpoint") is Dictionary:
		return {"estado": "invalido"}
	var conteudo := {"schema_version": 1, "checkpoint": envelope.checkpoint}
	if envelope.get("checksum") != JSON.stringify(conteudo, "", true).sha256_text():
		return {"estado": "invalido"}
	return {"estado": "valido", "dados": envelope.checkpoint, "texto": texto}

func carregar() -> bool:
	dados = {}
	aviso = ""
	bloqueado = false
	var principal := _ler(caminho)
	var backup := _ler(caminho + ".bak")
	if principal.estado == "incompativel":
		bloqueado = true
		aviso = "Checkpoint incompatível. Reinicie a fase para jogar."
		return false
	var escolhido: Dictionary = principal if principal.estado == "valido" else backup
	if escolhido.estado != "valido":
		if principal.estado != "ausente" or backup.estado != "ausente":
			bloqueado = true
			aviso = "Checkpoint indisponível. Reinicie a fase para jogar."
		return false
	dados = escolhido.dados
	_ultimo = escolhido.texto
	if principal.estado != "valido":
		aviso = "Checkpoint recuperado da cópia anterior."
	return true

func _gravar(arquivo: String, texto: String) -> bool:
	var fluxo := FileAccess.open(arquivo, FileAccess.WRITE)
	if fluxo == null:
		return false
	fluxo.store_string(texto)
	fluxo.flush()
	var erro := fluxo.get_error()
	fluxo.close()
	return erro == OK and FileAccess.get_file_as_string(arquivo) == texto

func salvar(checkpoint: Dictionary, versao: int) -> bool:
	if bloqueado:
		return false
	var copia := checkpoint.duplicate(true)
	for campo in ["posicao", "posicao_relativa"]:
		var v: Vector2 = copia[campo]
		copia[campo] = [v.x, v.y]
	copia["content_version"] = versao
	var envelope: Dictionary = JSON.parse_string(JSON.stringify({"schema_version": 1, "checkpoint": copia}, "", true))
	envelope.schema_version = 1
	envelope["checksum"] = JSON.stringify(envelope, "", true).sha256_text()
	var texto := JSON.stringify(envelope, "\t") + "\n"
	aviso = "Não foi possível salvar o checkpoint."
	if not _gravar(caminho + ".tmp", texto) or _ler(caminho + ".tmp").estado != "valido":
		return false
	if not _ultimo.is_empty():
		if not _gravar(caminho + ".bak.tmp", _ultimo) or DirAccess.rename_absolute(caminho + ".bak.tmp", caminho + ".bak") != OK:
			return false
	if DirAccess.rename_absolute(caminho + ".tmp", caminho) != OK:
		return false
	_ultimo = texto
	dados = copia
	aviso = ""
	return true

func limpar() -> bool:
	for sufixo in ["", ".bak", ".tmp", ".bak.tmp"]:
		if FileAccess.file_exists(caminho + sufixo) and DirAccess.remove_absolute(caminho + sufixo) != OK:
			aviso = "Não foi possível descartar o checkpoint."
			return false
	dados = {}
	_ultimo = ""
	bloqueado = false
	aviso = ""
	return true
