@tool
class_name SimulacaoVoo extends RefCounted
## Integrador compartilhado pelo voo e pela prévia. Corpos estáticos.

static func aceleracao(posicao: Vector2, corpos: Array, fisica: Dictionary) -> Vector2:
	var resultado := Vector2.ZERO
	var epsilon: float = fisica.get("softening", 8.0)
	var constante: float = fisica.get("gravity_constant", 1.0)
	for corpo in corpos:
		if corpo.type in ["asteroid", "earth"] or corpo.mass <= 0.0:
			continue
		var r: Vector2 = corpo.position - posicao
		resultado += constante * corpo.mass * r / pow(r.length_squared() + epsilon * epsilon, 1.5)
	return resultado


static func raio_contato(corpo: Dictionary) -> float:
	if corpo.type in ["sun", "asteroid"]:
		return corpo.danger_radius
	return maxf(corpo.collision_radius, corpo.capture_radius)


static func intersecao_circulo(inicio: Vector2, fim: Vector2, centro: Vector2, raio: float) -> float:
	var relativo := inicio - centro
	var deslocamento := fim - inicio
	if relativo.length_squared() <= raio * raio:
		return 0.0
	var a := deslocamento.length_squared()
	if a <= 0.0:
		return INF
	var b := 2.0 * relativo.dot(deslocamento)
	var c := relativo.length_squared() - raio * raio
	var discriminante := b * b - 4.0 * a * c
	if discriminante < 0.0:
		return INF
	var t := (-b - sqrt(discriminante)) / (2.0 * a)
	return t if t >= 0.0 and t <= 1.0 else INF


static func dentro_limites(ponto: Vector2, limites: Rect2) -> bool:
	return ponto.x >= limites.position.x and ponto.y >= limites.position.y and ponto.x <= limites.end.x and ponto.y <= limites.end.y


static func passo(posicao: Vector2, velocidade: Vector2, delta: float, corpos: Array, fisica: Dictionary, limites: Rect2, raio_nave: float, origem := "") -> Dictionary:
	var nova_velocidade := velocidade + aceleracao(posicao, corpos, fisica) * delta
	var fim := posicao + nova_velocidade * delta
	var contato: Dictionary = {}
	var primeiro := INF
	var prioridade := 99
	for corpo in corpos:
		var relativo: Vector2 = posicao - corpo.position
		# A proteção vale só para saída externa do apoio de origem.
		if corpo.id == origem and corpo.type in ["planet", "satellite"]:
			if relativo.length() >= corpo.collision_radius + raio_nave and relativo.dot(fim - posicao) >= 0.0:
				continue
		var t := intersecao_circulo(posicao, fim, corpo.position, raio_contato(corpo) + raio_nave)
		var p := 0 if corpo.type in ["sun", "asteroid"] else (1 if corpo.type == "earth" else 2)
		if t < primeiro - 0.000001 or (is_finite(t) and absf(t - primeiro) <= 0.000001 and p < prioridade):
			primeiro = t
			prioridade = p
			contato = {"body": corpo, "kind": "body", "fraction": t}
	if not dentro_limites(fim, limites):
		var t := 0.0
		if dentro_limites(posicao, limites):
			t = 1.0
			for eixo in range(2):
				if fim[eixo] < limites.position[eixo]:
					t = minf(t, (limites.position[eixo] - posicao[eixo]) / (fim[eixo] - posicao[eixo]))
				elif fim[eixo] > limites.end[eixo]:
					t = minf(t, (limites.end[eixo] - posicao[eixo]) / (fim[eixo] - posicao[eixo]))
		if t <= primeiro:
			primeiro = t
			contato = {"kind": "bounds", "fraction": t}
	return {"position": posicao.lerp(fim, primeiro) if not contato.is_empty() else fim, "velocity": nova_velocidade, "contact": contato}


static func prever(posicao: Vector2, velocidade: Vector2, corpos: Array, fisica: Dictionary, limites: Rect2, raio_nave: float, origem := "", passos := 180, delta := 1.0 / 60.0) -> PackedVector2Array:
	var pontos := PackedVector2Array([posicao])
	for indice in range(passos):
		var proximo := passo(posicao, velocidade, delta, corpos, fisica, limites, raio_nave, origem)
		posicao = proximo.position
		velocidade = proximo.velocity
		if indice % 3 == 2 or not proximo.contact.is_empty() or indice == passos - 1:
			pontos.append(posicao)
		if not proximo.contact.is_empty():
			break
	return pontos
