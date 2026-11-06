@tool
class_name CarregadorFase extends RefCounted

const Nivel = preload("res://src/Nivel/nivel_res.gd")
const Fisica = preload("res://src/Nave/simulacao_voo.gd")


static func carregar(caminho: String) -> Dictionary:
	if not FileAccess.file_exists(caminho):
		return {"nivel": null, "erros": ["Arquivo ausente: " + caminho]}
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(caminho)) != OK:
		return {"nivel": null, "erros": ["%s:%d: %s" % [caminho, json.get_error_line(), json.get_error_message()]]}
	return validar(json.data)


static func numero(valor: Variant, minimo: float, maximo := 1000000.0) -> bool:
	return (valor is float or valor is int) and is_finite(float(valor)) and valor >= minimo and valor <= maximo


static func inteiro(valor: Variant, minimo: int) -> bool:
	return numero(valor, minimo) and float(valor) == floorf(float(valor))


static func vetor(valor: Variant) -> bool:
	return valor is Array and valor.size() == 2 and numero(valor[0], -1000000) and numero(valor[1], -1000000)


static func texto(valor: Variant) -> bool:
	return valor is String and not valor.strip_edges().is_empty()


static func validar(dados: Variant) -> Dictionary:
	var erros: Array[String] = []
	if not dados is Dictionary:
		return {"nivel": null, "erros": ["fase: esperado objeto JSON"]}
	if not inteiro(dados.get("schema_version"), 1) or dados.schema_version != 1:
		erros.append("schema_version: somente versão 1 é suportada")
	for campo in ["id", "name"]:
		if not texto(dados.get(campo)):
			erros.append(campo + ": texto obrigatório")
	for campo in ["content_version", "order"]:
		if not inteiro(dados.get(campo), 1):
			erros.append(campo + ": inteiro positivo obrigatório")
	if not inteiro(dados.get("initial_fuel", 5), 1):
		erros.append("initial_fuel: inteiro positivo")
	if not numero(dados.get("flight_timeout"), 0.01, 3600):
		erros.append("flight_timeout: duração positiva até 3600 s")
	var bounds = dados.get("bounds")
	if not bounds is Dictionary or not vetor(bounds.get("position")) or not vetor(bounds.get("size")):
		erros.append("bounds: position e size devem conter [x, y]")
	elif bounds["size"][0] <= 0 or bounds["size"][1] <= 0:
		erros.append("bounds.size: dimensões positivas")
	var fisica = dados.get("physics")
	if not fisica is Dictionary or not numero(fisica.get("gravity_constant"), 0, 1000) or not numero(fisica.get("softening"), 1, 10000):
		erros.append("physics: gravity_constant entre 0 e 1000; softening entre 1 e 10000")
	var nave = dados.get("ship")
	if not nave is Dictionary:
		erros.append("ship: parâmetros obrigatórios")
	else:
		for campo in ["radius", "mass", "dead_zone", "max_drag", "max_impulse"]:
			if not numero(nave.get(campo), 0.01, 1000):
				erros.append("ship." + campo + ": valor positivo até 1000")
		if numero(nave.get("dead_zone"), 0.01) and numero(nave.get("max_drag"), 0.01) and nave.max_drag <= nave.dead_zone:
			erros.append("ship.max_drag: deve superar dead_zone")
	var inicio = dados.get("start")
	if not inicio is Dictionary:
		erros.append("start: esperado apoio ou position [x, y]")
	elif inicio.has("position"):
		if not vetor(inicio.position) or inicio.has("body_id") or inicio.has("angle_degrees"):
			erros.append("start: position [x, y] não pode ser misturada com body_id ou angle_degrees")
	elif not texto(inicio.get("body_id")) or not numero(inicio.get("angle_degrees"), -360, 360):
		erros.append("start: body_id e angle_degrees entre -360 e 360 obrigatórios")
	if dados.has("camera"):
		var camera = dados.camera
		if not camera is Dictionary:
			erros.append("camera: esperado objeto")
		else:
			if camera.has("zoom") and (not numero(camera.zoom, 0, 4) or camera.zoom == 0):
				erros.append("camera.zoom: valor positivo até 4")
			if camera.has("overview"):
				var visao = camera.overview
				if not visao is Dictionary or not vetor(visao.get("position")) or not vetor(visao.get("size")):
					erros.append("camera.overview: position e size devem conter [x, y]")
				elif visao["size"][0] <= 0 or visao["size"][1] <= 0:
					erros.append("camera.overview.size: dimensões positivas")
	if not dados.get("bodies") is Array:
		erros.append("bodies: lista obrigatória")
	if not dados.get("goal") is Dictionary:
		erros.append("goal: Terra obrigatória")
	if not erros.is_empty():
		return {"nivel": null, "erros": erros}
	var todos: Array = dados.bodies.duplicate(true)
	var terra: Dictionary = dados.goal.duplicate(true)
	terra["type"] = "earth"
	todos.append(terra)
	var ids: Dictionary = {}
	var normalizados: Array = []
	for indice in range(todos.size()):
		var corpo = todos[indice]
		var prefixo := "bodies[%d]" % indice if indice < dados.bodies.size() else "goal"
		if not corpo is Dictionary:
			erros.append(prefixo + ": objeto obrigatório")
			continue
		var erros_antes := erros.size()
		if not texto(corpo.get("id")) or ids.has(corpo.get("id")):
			erros.append(prefixo + ".id: ausente ou duplicado")
		else:
			ids[corpo.id] = true
			prefixo += " (" + corpo.id + ")"
		if not corpo.get("type") in ["planet", "station", "satellite", "sun", "asteroid", "earth", "portal"] or (indice < dados.bodies.size() and corpo.get("type") == "earth"):
			erros.append(prefixo + ".type: tipo inválido")
		if not vetor(corpo.get("position")):
			erros.append(prefixo + ".position: esperado [x, y]")
		if corpo.get("type") == "portal":
			if not texto(corpo.get("target_id")) or not numero(corpo.get("exit_degrees"), -360, 360) or corpo.has("orbit") or corpo.has("rotation"):
				erros.append(prefixo + ": portal estático exige target_id e exit_degrees entre -360 e 360")
			if corpo.get("mass") != 0 or corpo.get("danger_radius") != 0 or corpo.get("capture_radius") != 0:
				erros.append(prefixo + ": portal exige massa, perigo e captura zero")
		if corpo.has("rotation"):
			var giro = corpo.rotation
			if not giro is Dictionary or not numero(giro.get("degrees_per_second"), -360, 360) or not numero(giro.get("initial_degrees", 0.0), -360, 360):
				erros.append(prefixo + ".rotation: degrees_per_second e initial_degrees entre -360 e 360")
		if corpo.has("landing_zone"):
			var setor = corpo.landing_zone
			if corpo.get("type") not in ["planet", "station", "satellite"] or not setor is Dictionary or not numero(setor.get("center_degrees"), -360, 360) or not numero(setor.get("half_width_degrees"), 0.01, 180):
				erros.append(prefixo + ".landing_zone: apenas apoios; center_degrees entre -360 e 360, half_width_degrees entre 0,01 e 180")
		if corpo.has("orbit"):
			var orbita = corpo.orbit
			if not orbita is Dictionary or not vetor(orbita.get("center")) or not numero(orbita.get("period_seconds"), 1.0, 86400):
				erros.append(prefixo + ".orbit: center [x, y] e period_seconds entre 1 e 86400 obrigatórios")
			elif (orbita.has("clockwise") and not orbita.clockwise is bool) or (vetor(corpo.get("position")) and Vector2(corpo.position[0], corpo.position[1]).distance_to(Vector2(orbita.center[0], orbita.center[1])) < 0.01):
				erros.append(prefixo + ".orbit: sentido booleano e raio maior ou igual a 0,01 obrigatórios")
		if corpo.has("show_proximity") and not corpo.show_proximity is bool:
			erros.append(prefixo + ".show_proximity: esperado booleano")
		for campo in ["visual_radius", "collision_radius", "capture_radius", "danger_radius", "proximity_radius", "mass"]:
			var minimo := 0.01 if campo in ["visual_radius", "collision_radius", "proximity_radius"] else 0.0
			if not numero(corpo.get(campo), minimo):
				erros.append(prefixo + "." + campo + ": número fora do intervalo")
		if erros.size() > erros_antes:
			continue
		if corpo.type in ["asteroid", "station"] and corpo.mass != 0:
			erros.append(prefixo + ".mass: este tipo não atrai")
		if corpo.has("gravity_radius") and not numero(corpo.gravity_radius, corpo.capture_radius, 10000):
			erros.append(prefixo + ".gravity_radius: deve cobrir captura e ter no máximo 10000")
		# Compatibilidade com fases antigas; satélites deixam de existir na simulação.
		if corpo.type == "satellite":
			corpo.type = "planet" if corpo.mass > 0 else "station"
		if corpo.type == "earth":
			corpo.mass = maxf(corpo.mass, 180000.0)
			corpo["gravity_radius"] = corpo.get("gravity_radius", corpo.capture_radius + 38.0)
		if corpo.type in ["sun", "asteroid"]:
			if corpo.danger_radius < corpo.collision_radius or corpo.capture_radius != 0:
				erros.append(prefixo + ": perigo deve cobrir colisão e não ter captura")
		elif corpo.type != "portal" and (corpo.danger_radius != 0 or corpo.capture_radius < corpo.collision_radius):
			erros.append(prefixo + ": corpo seguro exige captura >= colisão e perigo zero")
		if corpo.proximity_radius < Fisica.raio_contato(corpo):
			erros.append(prefixo + ".proximity_radius: deve cobrir contato")
		corpo.position = Vector2(corpo.position[0], corpo.position[1])
		if corpo.has("orbit"):
			corpo["_posicao_inicial"] = corpo.position
		normalizados.append(corpo)
	if not erros.is_empty():
		return {"nivel": null, "erros": erros}
	for portal in normalizados:
		if portal.type != "portal":
			continue
		var destino: Dictionary = {}
		for candidato in normalizados:
			if candidato.id == portal.target_id:
				destino = candidato
		if destino.is_empty() or destino.type != "portal" or destino.id == portal.id or destino.get("target_id") != portal.id:
			erros.append(portal.id + ".target_id: exige outro portal com ligação recíproca")
			continue
		var direcao := Vector2.RIGHT.rotated(deg_to_rad(destino.exit_degrees))
		var saida: Vector2 = destino.position + direcao * (destino.collision_radius + nave.radius + 0.01)
		var area := Rect2(Vector2(bounds.position[0], bounds.position[1]), Vector2(bounds["size"][0], bounds["size"][1]))
		if not Fisica.dentro_limites(destino.position, area) or not Fisica.dentro_limites(saida, area):
			erros.append(destino.id + ": portal/saída fora dos limites")
		for corpo in normalizados:
			if corpo.id != destino.id and saida.distance_to(corpo.position) <= Fisica.raio_contato(corpo) + nave.radius:
				erros.append(destino.id + ": saída sobreposta a " + corpo.id)
	if not erros.is_empty():
		return {"nivel": null, "erros": erros}
	var nivel := Nivel.new()
	nivel.id = dados.id
	nivel.nome = dados.name
	nivel.ordem = int(dados.order)
	nivel.combustivel_inicial = int(dados.get("initial_fuel", 5))
	nivel.tempo_voo = float(dados.flight_timeout)
	nivel.limites = Rect2(Vector2(bounds.position[0], bounds.position[1]), Vector2(bounds["size"][0], bounds["size"][1]))
	nivel.fisica = fisica.duplicate(true)
	nivel.parametros_nave = nave.duplicate(true)
	nivel.inicio = inicio.duplicate(true)
	nivel.corpos = normalizados
	nivel.dados_autorais = dados.duplicate(true)
	_validar_estrelas(dados.get("stars", []), nivel, erros)
	_validar_combustiveis(dados.get("fuel_pickups", []), nivel, erros)
	if not Fisica.dentro_limites(normalizados[-1].position, nivel.limites):
		erros.append("goal.position: Terra fora dos limites")
	var apoio := nivel.obter_corpo(inicio.get("body_id", ""))
	if not inicio.has("position") and (apoio.is_empty() or not apoio.type in ["planet", "station"]):
		erros.append("start.body_id: apoio seguro inexistente")
	else:
		var posicao := nivel.obter_posicao_inicial()
		if not Fisica.dentro_limites(posicao, nivel.limites):
			erros.append("start: nave fora dos limites")
		for corpo in normalizados:
			if corpo.id != apoio.get("id", "") and posicao.distance_to(corpo.position) <= Fisica.raio_contato(corpo) + nave.radius:
				erros.append("start: sobreposto ao corpo " + corpo.id)
	for i in range(normalizados.size()):
		for j in range(i + 1, normalizados.size()):
			var a: Dictionary = normalizados[i]
			var b: Dictionary = normalizados[j]
			# Muros de rochas/perigos podem formar uma única região fatal.
			if a.type in ["sun", "asteroid"] and b.type in ["sun", "asteroid"]:
				continue
			if a.position.distance_to(b.position) <= Fisica.raio_contato(a) + Fisica.raio_contato(b) + 2 * nave.radius:
				erros.append("contato: zonas incompatíveis entre %s e %s" % [a.id, b.id])
	if not erros.is_empty():
		return {"nivel": null, "erros": erros}
	return {"nivel": nivel, "erros": erros}


static func _validar_estrelas(dados: Variant, nivel: NivelRes, erros: Array[String]) -> void:
	if not dados is Array or dados.size() > 256:
		erros.append("stars: lista opcional com até 256 estrelas")
		return
	var ids: Dictionary = {}
	for indice in range(dados.size()):
		var estrela = dados[indice]
		var prefixo := "stars[%d]" % indice
		if not estrela is Dictionary:
			erros.append(prefixo + ": objeto obrigatório")
			continue
		if not texto(estrela.get("id")) or estrela.id.length() > 256 or ids.has(estrela.get("id")):
			erros.append(prefixo + ".id: ausente ou duplicado")
			continue
		ids[estrela.id] = true
		if not vetor(estrela.get("position")) or not numero(estrela.get("radius"), 0.01, 1000):
			erros.append(prefixo + ": position [x, y] e radius positivo até 1000 obrigatórios")
			continue
		var posicao := Vector2(estrela.position[0], estrela.position[1])
		if estrela.get("type", "gold") not in ["gold", "blue"]:
			erros.append(prefixo + ".type: esperado gold ou blue")
		var raio := float(estrela.radius)
		if not Fisica.dentro_limites(posicao - Vector2.ONE * raio, nivel.limites) or not Fisica.dentro_limites(posicao + Vector2.ONE * raio, nivel.limites):
			erros.append(prefixo + ": estrela fora dos limites")
		for corpo in nivel.corpos:
			if posicao.distance_to(corpo.position) <= Fisica.raio_contato(corpo) + raio:
				erros.append(prefixo + ": sobreposta ao corpo " + corpo.id)
			if corpo.type == "portal":
				var direcao := Vector2.RIGHT.rotated(deg_to_rad(corpo.exit_degrees))
				var saida: Vector2 = corpo.position + direcao * (corpo.collision_radius + nivel.parametros_nave.radius + 0.01)
				if posicao.distance_to(saida) <= raio + nivel.parametros_nave.radius:
					erros.append(prefixo + ": sobreposta à saída do portal " + corpo.id)
		nivel.estrelas.append({"id": estrela.id, "position": posicao, "radius": raio, "type": estrela.get("type", "gold")})


static func _validar_combustiveis(dados: Variant, nivel: NivelRes, erros: Array[String]) -> void:
	if not dados is Array or dados.size() > 256:
		erros.append("fuel_pickups: lista opcional com até 256 tanques")
		return
	var ids: Dictionary = {}
	for tanque in dados:
		if not tanque is Dictionary or not texto(tanque.get("id")) or tanque.id.length() > 256 or ids.has(tanque.id):
			erros.append("fuel_pickups: ID ausente ou duplicado")
			continue
		ids[tanque.id] = true
		if not vetor(tanque.get("position")) or not numero(tanque.get("radius"), 0.01, 1000) or not inteiro(tanque.get("amount"), 1) or tanque.amount > 100:
			erros.append("fuel_pickups: position [x,y], radius positivo e amount inteiro entre 1 e 100")
			continue
		var posicao := Vector2(tanque.position[0], tanque.position[1])
		var raio := float(tanque.radius)
		if not nivel.limites.encloses(Rect2(posicao - Vector2.ONE * raio, Vector2.ONE * raio * 2)):
			erros.append("fuel_pickups: tanque fora dos limites")
		for corpo in nivel.corpos:
			if posicao.distance_to(corpo.position) <= Fisica.raio_contato(corpo) + raio:
				erros.append("fuel_pickups: sobreposto ao corpo " + corpo.id)
			if corpo.type == "portal":
				var saida: Vector2 = corpo.position + Vector2.RIGHT.rotated(deg_to_rad(corpo.exit_degrees)) * (corpo.collision_radius + nivel.parametros_nave.radius + 0.01)
				if posicao.distance_to(saida) <= raio + nivel.parametros_nave.radius:
					erros.append("fuel_pickups: sobreposto à saída do portal " + corpo.id)
		nivel.combustiveis.append({"id": tanque.id, "position": posicao, "radius": raio, "amount": int(tanque.amount)})
