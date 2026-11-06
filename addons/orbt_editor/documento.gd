@tool
extends RefCounted
## Somente dados autorais. Nenhuma instância de partida ou persistência de progresso.

signal alterado
signal selecao_alterada
const Carregador = preload("res://src/Nivel/carregador_fase.gd")
const EXEMPLO = "res://Recursos/Fases/teste_001.json"
var dados: Dictionary = {}
var caminho := ""
var selecao := -2 # -2 fase; -1 Terra; >= 0 corpo; -3 - índice da estrela.
var _salvo := ""
var _historico: Array[Dictionary] = []
var _indice_historico := -1
var _reproduzindo := false
var _agrupando := false


func _init() -> void:
	alterado.connect(_registrar_estado)


func limpar_historico() -> void:
	_historico.clear()
	_indice_historico = -1
	_agrupando = false
	_registrar_estado()


func _registrar_estado() -> void:
	if _reproduzindo or _agrupando:
		return
	var texto := JSON.stringify(dados, "", true, true)
	if _indice_historico >= 0 and _historico[_indice_historico].texto == texto:
		_historico[_indice_historico].selecao = selecao
		return
	_historico.resize(_indice_historico + 1)
	_historico.append({"dados": dados.duplicate(true), "selecao": selecao, "texto": texto})
	if _historico.size() > 101:
		_historico.pop_front()
	_indice_historico = _historico.size() - 1


func iniciar_grupo() -> void:
	_registrar_estado()
	_agrupando = true


func terminar_grupo() -> void:
	if not _agrupando:
		return
	_agrupando = false
	alterado.emit()


func pode_desfazer() -> bool:
	return _indice_historico > 0 and not _agrupando


func pode_refazer() -> bool:
	return _indice_historico + 1 < _historico.size() and not _agrupando


func desfazer() -> bool:
	terminar_grupo()
	if not pode_desfazer():
		return false
	_restaurar_estado(_indice_historico - 1)
	return true


func refazer() -> bool:
	terminar_grupo()
	if not pode_refazer():
		return false
	_restaurar_estado(_indice_historico + 1)
	return true


func _restaurar_estado(indice: int) -> void:
	_indice_historico = indice
	dados = _historico[indice].dados.duplicate(true)
	selecao = selecao_valida(_historico[indice].selecao)
	_reproduzindo = true
	alterado.emit()
	selecao_alterada.emit()
	_reproduzindo = false


func _id_copia(id_original: String) -> String:
	var ids: Array = [dados.goal.id]
	for corpo in dados.bodies:
		ids.append(corpo.id)
	for estrela in dados.get("stars", []):
		ids.append(estrela.id)
	var numero := 1
	while (id_original + "_copia_%d" % numero) in ids:
		numero += 1
	return id_original + "_copia_%d" % numero


func duplicar(deslocamento := Vector2(40, 40)) -> bool:
	if selecao <= -3:
		var estrela := objeto(selecao)
		if estrela.is_empty() or not deslocamento.is_finite():
			return false
		terminar_grupo()
		var copia: Dictionary = estrela.duplicate(true)
		copia.id = _id_copia(estrela.id)
		copia.position = [estrela.position[0] + deslocamento.x, estrela.position[1] + deslocamento.y]
		dados.stars.append(copia)
		selecao = -3 - (dados.stars.size() - 1)
		alterado.emit()
		selecao_alterada.emit()
		return true
	if selecao < 0 or selecao >= dados.bodies.size() or not deslocamento.is_finite():
		return false
	terminar_grupo()
	var original := objeto(selecao)
	var fontes: Array = [original]
	if original.type == "portal":
		for corpo in dados.bodies:
			if corpo.id == original.get("target_id") and corpo.type == "portal" and corpo.get("target_id") == original.id and corpo.id != original.id:
				fontes.append(corpo)
		if fontes.size() != 2:
			return false
	var novos: Array = []
	var primeiro: int = dados.bodies.size()
	for fonte in fontes:
		var copia: Dictionary = fonte.duplicate(true)
		copia.id = _id_copia(fonte.id)
		copia.position = [fonte.position[0] + deslocamento.x, fonte.position[1] + deslocamento.y]
		if copia.has("orbit"):
			copia.orbit.center = [fonte.orbit.center[0] + deslocamento.x, fonte.orbit.center[1] + deslocamento.y]
		dados.bodies.append(copia)
		novos.append(copia)
	if novos.size() == 2:
		novos[0].target_id = novos[1].id
		novos[1].target_id = novos[0].id
	selecao = primeiro
	alterado.emit()
	selecao_alterada.emit()
	return true


func modificado() -> bool:
	return JSON.stringify(dados, "", true, true) != _salvo


func abrir(arquivo: String) -> Array[String]:
	if not FileAccess.file_exists(arquivo):
		return ["Arquivo ausente: " + arquivo]
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(arquivo)) != OK:
		return ["%s:%d: %s" % [arquivo, json.get_error_line(), json.get_error_message()]]
	var resultado := Carregador.validar(json.data)
	if resultado.nivel == null:
		return resultado.erros
	dados = json.data.duplicate(true)
	caminho = arquivo
	selecao = -2
	_salvo = JSON.stringify(dados, "", true, true)
	limpar_historico()
	alterado.emit()
	return []


func novo() -> void:
	abrir(EXEMPLO)
	caminho = ""
	dados.id = "nova_fase"
	dados.name = "Nova fase"
	_salvo = ""
	limpar_historico()
	alterado.emit()


func validar() -> Dictionary:
	var resultado := Carregador.validar(dados)
	var avisos: Array[String] = []
	if resultado.nivel != null:
		var corpos: Array = resultado.nivel.corpos
		var raio: float = dados.ship.radius
		for i in range(corpos.size()):
			var corpo: Dictionary = corpos[i]
			if not Carregador.Fisica.dentro_limites(corpo.position, resultado.nivel.limites):
				avisos.append("%s.position: objeto fora dos limites" % corpo.id)
			for j in range(i + 1, corpos.size()):
				var a: Dictionary = corpos[i]
				var b: Dictionary = corpos[j]
				var livre: float = a.position.distance_to(b.position) - Carregador.Fisica.raio_contato(a) - Carregador.Fisica.raio_contato(b) - 2 * raio
				if livre < 2 * raio:
					avisos.append("%s / %s: passagem estreita (folga %.2f unidades)" % [a.id, b.id, livre])
				if a.position.distance_to(b.position) < a.visual_radius + b.visual_radius:
					avisos.append("%s / %s: visuais sobrepostos%s" % [a.id, b.id, "; destino encoberto" if a.type == "earth" or b.type == "earth" else ""])
	resultado["avisos"] = avisos
	return resultado


func salvar(arquivo: String) -> Array[String]:
	var resultado := validar()
	if resultado.nivel == null:
		return resultado.erros
	if not arquivo.ends_with(".json"):
		return ["Destino deve terminar em .json"]
	# Gravar ao lado e renomear: uma falha de escrita preserva o arquivo anterior.
	var temporario := arquivo + ".orbt-tmp"
	var fluxo := FileAccess.open(temporario, FileAccess.WRITE)
	if fluxo == null:
		return ["Não foi possível gravar: " + arquivo]
	fluxo.store_string(JSON.stringify(dados, "\t", true, true) + "\n")
	fluxo.flush()
	var erro := fluxo.get_error()
	fluxo.close()
	if erro != OK:
		DirAccess.remove_absolute(temporario)
		return ["Falha de gravação: " + arquivo]
	if DirAccess.rename_absolute(temporario, arquivo) != OK:
		DirAccess.remove_absolute(temporario)
		return ["Não foi possível substituir: " + arquivo]
	caminho = arquivo
	_salvo = JSON.stringify(dados, "", true, true)
	alterado.emit()
	return []


func objeto(indice: int) -> Dictionary:
	if indice <= -3:
		var estrelas: Array = dados.get("stars", [])
		var indice_estrela := -3 - indice
		return estrelas[indice_estrela] if indice_estrela < estrelas.size() else {}
	if indice == -1:
		return dados.get("goal", {})
	if indice >= 0 and indice < dados.get("bodies", []).size():
		return dados.bodies[indice]
	return {}


func selecao_valida(indice: int) -> int:
	return indice if indice == -2 or not objeto(indice).is_empty() else -2


func inserir_estrela(posicao: Vector2) -> void:
	if not posicao.is_finite():
		return
	terminar_grupo()
	if not dados.has("stars"):
		dados["stars"] = []
	var numero := 1
	var ids: Array = dados.stars.map(func(estrela: Dictionary): return estrela.id)
	while "estrela_%d" % numero in ids:
		numero += 1
	dados.stars.append({"id": "estrela_%d" % numero, "type": "gold", "position": [posicao.x, posicao.y], "radius": 7.0})
	selecao = -3 - (dados.stars.size() - 1)
	alterado.emit()
	selecao_alterada.emit()


func selecionar(indice: int) -> void:
	selecao = indice
	alterado.emit()
	selecao_alterada.emit()


func inserir(tipo: String, posicao: Vector2) -> void:
	if tipo not in ["planet", "station", "sun", "asteroid", "portal"]:
		return
	var numero := 1
	var ids: Array = [dados.goal.id]
	for corpo in dados.bodies:
		ids.append(corpo.id)
	while "%s_%d" % [tipo, numero] in ids:
		numero += 1
	var perigoso := tipo in ["sun", "asteroid"]
	dados.bodies.append({"id": "%s_%d" % [tipo, numero], "type": tipo,
		"position": [posicao.x, posicao.y], "mass": 0 if tipo in ["asteroid", "station"] else 500,
		"visual_radius": 12, "collision_radius": 12, "capture_radius": 0 if perigoso else 16,
		"danger_radius": 12 if perigoso else 0, "proximity_radius": 40})
	if tipo == "portal":
		var portal: Dictionary = dados.bodies[-1]
		portal.mass = 0
		portal.capture_radius = 0
		portal["target_id"] = ""
		portal["exit_degrees"] = 0.0
	selecao = dados.bodies.size() - 1
	alterado.emit()


func mover(indice: int, posicao: Vector2) -> void:
	var corpo := objeto(indice)
	if corpo.is_empty() or not posicao.is_finite():
		return
	corpo.position = [posicao.x, posicao.y]
	alterado.emit()


func excluir() -> void:
	if selecao <= -3 and not objeto(selecao).is_empty():
		dados.stars.remove_at(-3 - selecao)
		selecao = -2
		alterado.emit()
		selecao_alterada.emit()
		return
	if selecao < 0 or selecao >= dados.bodies.size():
		return
	# Referência ao apoio é preservada para que o carregador mostre o erro.
	dados.bodies.remove_at(selecao)
	selecao = -2
	alterado.emit()


func editar(trilha: Array, valor: Variant) -> void:
	var alvo: Variant = dados
	for chave in trilha.slice(0, -1):
		alvo = alvo[chave]
	var chave: Variant = trilha[-1]
	if chave == "id" and trilha.size() == 3 and trilha[0] == "bodies":
		if dados.start.get("body_id") == alvo.id:
			dados.start.body_id = valor
		for corpo in dados.bodies:
			if corpo.get("target_id") == alvo.id:
				corpo.target_id = valor
	alvo[chave] = valor
	if chave == "type" and valor == "station":
		alvo.mass = 0
	if chave == "type" and valor == "portal":
		alvo.mass = 0
		alvo.capture_radius = 0
		alvo.danger_radius = 0
		alvo["target_id"] = alvo.get("target_id", "")
		alvo["exit_degrees"] = alvo.get("exit_degrees", 0.0)
		alvo.erase("orbit")
		alvo.erase("rotation")
		alvo.erase("landing_zone")
		selecao_alterada.emit()
	alterado.emit()


func exportar_teste(arquivo: String) -> Array[String]:
	var resultado := validar()
	if resultado.nivel == null:
		return resultado.erros
	var fluxo := FileAccess.open(arquivo, FileAccess.WRITE)
	if fluxo == null:
		return ["Não foi possível preparar cópia de teste"]
	fluxo.store_string(JSON.stringify(dados.duplicate(true), "", true, true))
	fluxo.close()
	return []
