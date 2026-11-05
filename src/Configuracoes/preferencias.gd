extends RefCounted
## Preferências independentes da campanha e dos checkpoints.

var caminho := "user://preferencias.json"
var persistir := true
var musica := 1.0
var efeitos := 1.0
var vibracao := true
var dicas := true
var aviso := ""
var _pendente := false

func _volume_valido(valor) -> bool:
	return (valor is float or valor is int) and is_finite(float(valor)) and valor >= 0 and valor <= 1

func carregar() -> void:
	musica = 1.0
	efeitos = 1.0
	vibracao = true
	dicas = true
	aviso = ""
	_pendente = false
	if persistir and FileAccess.file_exists(caminho):
		var parser := JSON.new()
		var texto := FileAccess.get_file_as_string(caminho)
		if texto.length() > 4096 or parser.parse(texto) != OK or not parser.data is Dictionary:
			aviso = "Preferências inválidas; usando valores padrão."
		else:
			var dados: Dictionary = parser.data
			var versao = dados.get("schema_version")
			var opcoes_validas: bool = versao == 1 or (dados.get("vibracao") is bool and dados.get("dicas") is bool)
			if (versao != 1 and versao != 2) or not opcoes_validas or not _volume_valido(dados.get("musica")) or not _volume_valido(dados.get("efeitos")):
				aviso = "Preferências inválidas; usando valores padrão."
			else:
				musica = float(dados.musica)
				efeitos = float(dados.efeitos)
				if versao == 2:
					vibracao = dados.vibracao
					dicas = dados.dicas
	aplicar()

func aplicar() -> void:
	for item in [["Musica", musica], ["Efeitos", efeitos]]:
		var indice := AudioServer.get_bus_index(item[0])
		if indice < 0:
			AudioServer.add_bus()
			indice = AudioServer.bus_count - 1
			AudioServer.set_bus_name(indice, item[0])
			AudioServer.set_bus_send(indice, "Master")
		AudioServer.set_bus_mute(indice, item[1] <= 0)
		AudioServer.set_bus_volume_db(indice, linear_to_db(maxf(item[1], 0.0001)))

func alterar(campo: String, valor: Variant) -> bool:
	if campo in ["musica", "efeitos"]:
		if not _volume_valido(valor):
			return false
		set(campo, float(valor))
		aplicar()
	elif campo in ["vibracao", "dicas"]:
		if not valor is bool:
			return false
		set(campo, valor)
	else:
		return false
	return salvar()


func vibrar(duracao_ms := 25) -> bool:
	if not vibracao or duracao_ms <= 0 or duracao_ms > 500:
		return false
	_vibrar_dispositivo(duracao_ms)
	return true


func _vibrar_dispositivo(duracao_ms: int) -> void:
	if OS.has_feature("android"):
		Input.vibrate_handheld(duracao_ms)

func salvar() -> bool:
	if not persistir:
		_pendente = false
		aviso = ""
		return true
	_pendente = true
	var texto := JSON.stringify({"schema_version": 2, "musica": musica, "efeitos": efeitos, "vibracao": vibracao, "dicas": dicas})
	var arquivo := FileAccess.open(caminho + ".tmp", FileAccess.WRITE)
	if arquivo == null:
		aviso = "Não foi possível salvar as configurações."
		return false
	arquivo.store_string(texto)
	arquivo.flush()
	var erro := arquivo.get_error()
	arquivo.close()
	if erro != OK or FileAccess.get_file_as_string(caminho + ".tmp") != texto or DirAccess.rename_absolute(caminho + ".tmp", caminho) != OK:
		aviso = "Não foi possível salvar as configurações."
		return false
	aviso = ""
	_pendente = false
	return true

func salvamento_pendente() -> bool:
	return _pendente
