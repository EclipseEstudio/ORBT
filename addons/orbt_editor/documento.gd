@tool
extends RefCounted
## Somente dados autorais. Nenhuma instância de partida ou persistência de progresso.

signal alterado
signal selecao_alterada
const Carregador = preload("res://src/Nivel/carregador_fase.gd")
const EXEMPLO = "res://Recursos/Fases/teste_001.json"
var dados: Dictionary = {}
var caminho := ""
var selecao := -2 # -2 fase; -1 Terra; >= 0 corpo.
var _salvo := ""


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
	alterado.emit()
	return []


func novo() -> void:
	abrir(EXEMPLO)
	caminho = ""
	dados.id = "nova_fase"
	dados.name = "Nova fase"
	_salvo = ""
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
	if indice == -1:
		return dados.get("goal", {})
	if indice >= 0 and indice < dados.get("bodies", []).size():
		return dados.bodies[indice]
	return {}


func selecionar(indice: int) -> void:
	selecao = indice
	alterado.emit()
	selecao_alterada.emit()


func inserir(tipo: String, posicao: Vector2) -> void:
	if tipo not in ["planet", "satellite", "sun", "asteroid", "portal"]:
		return
	var numero := 1
	var ids: Array = [dados.goal.id]
	for corpo in dados.bodies:
		ids.append(corpo.id)
	while "%s_%d" % [tipo, numero] in ids:
		numero += 1
	var perigoso := tipo in ["sun", "asteroid"]
	dados.bodies.append({"id": "%s_%d" % [tipo, numero], "type": tipo,
		"position": [posicao.x, posicao.y], "mass": 0 if tipo == "asteroid" else 500,
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
