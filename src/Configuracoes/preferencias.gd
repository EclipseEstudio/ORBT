extends RefCounted
## Preferências independentes da campanha e dos checkpoints.

var caminho := "user://preferencias.json"
var persistir := true
var musica := 1.0
var efeitos := 1.0
var aviso := ""

func _volume_valido(valor) -> bool:
	return (valor is float or valor is int) and is_finite(float(valor)) and valor >= 0 and valor <= 1

func carregar() -> void:
	musica = 1.0
	efeitos = 1.0
	aviso = ""
	if persistir and FileAccess.file_exists(caminho):
		var parser := JSON.new()
		var texto := FileAccess.get_file_as_string(caminho)
		if texto.length() > 4096 or parser.parse(texto) != OK or not parser.data is Dictionary:
			aviso = "Preferências inválidas; usando valores padrão."
		else:
			var dados: Dictionary = parser.data
			if dados.get("schema_version") != 1 or not _volume_valido(dados.get("musica")) or not _volume_valido(dados.get("efeitos")):
				aviso = "Preferências inválidas; usando valores padrão."
			else:
				musica = float(dados.musica)
				efeitos = float(dados.efeitos)
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

func alterar(campo: String, valor: float) -> bool:
	if campo not in ["musica", "efeitos"] or not _volume_valido(valor):
		return false
	if campo == "musica":
		musica = valor
	else:
		efeitos = valor
	aplicar()
	return salvar()

func salvar() -> bool:
	if not persistir:
		return true
	var texto := JSON.stringify({"schema_version": 1, "musica": musica, "efeitos": efeitos})
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
	return true
