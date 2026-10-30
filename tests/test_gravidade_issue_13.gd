extends SceneTree

const Fisica = preload("res://src/Nave/simulacao_voo.gd")
const Carregador = preload("res://src/Nivel/carregador_fase.gd")
const DT := 1.0 / 60.0
var falhas := 0
var verificacoes := 0

func verificar(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		printerr("FALHA: " + mensagem)

func _initialize() -> void:
	var nivel = Carregador.carregar("res://Recursos/Fases/teste_001.json").nivel
	verificar(nivel != null, "fase carrega")
	if nivel == null:
		quit(1)
		return
	var planeta: Dictionary = nivel.obter_corpo("origem")
	var apoio: Dictionary = nivel.obter_corpo("apoio")
	var centro: Vector2 = planeta.position
	var a_centro: Vector2 = Fisica.aceleracao(centro, [planeta], nivel.fisica)
	var a_200: Vector2 = Fisica.aceleracao(centro + Vector2(200, 0), [planeta], nivel.fisica)
	var a_400: Vector2 = Fisica.aceleracao(centro + Vector2(400, 0), [planeta], nivel.fisica)
	verificar(a_centro.is_finite() and a_centro == Vector2.ZERO, "centro finito")
	verificar(a_200.x < 0 and absf(a_200.x - (-1.197126)) < 0.0001, "atração a 200")
	verificar(a_400.length() < a_200.length() and absf(a_400.x - (-0.299820)) < 0.0001, "atração a 400")
	var copia := planeta.duplicate(true)
	copia.proximity_radius = 1000.0
	verificar(Fisica.aceleracao(centro + Vector2(200, 0), [copia], nivel.fisica).is_equal_approx(a_200), "proximidade não altera força")
	var ponto := Vector2(150, 160)
	var a1: Vector2 = Fisica.aceleracao(ponto, [planeta], nivel.fisica)
	var a2: Vector2 = Fisica.aceleracao(ponto, [apoio], nivel.fisica)
	var soma: Vector2 = Fisica.aceleracao(ponto, [planeta, apoio], nivel.fisica)
	verificar(soma.distance_to(a1 + a2) < 0.00001 and soma.is_finite(), "soma de duas fontes")
	print("Aceleração centro=", a_centro, " 200=", a_200, " 400=", a_400)
	print("Duas fontes em ", ponto, ": origem=", a1, " apoio=", a2, " soma=", soma)
	var pos := centro + Vector2(200, 0)
	var velocidade := Vector2.ZERO
	for i in range(180):
		var passo: Dictionary = Fisica.passo(pos, velocidade, DT, [planeta], nivel.fisica, nivel.limites, nivel.parametros_nave.radius)
		pos = passo.position
		velocidade = passo.velocity
		verificar(passo.contact.is_empty(), "aproximação sem contato")
	verificar(absf(pos.x - (centro.x + 194.533)) < 0.02, "aproximação em 3 segundos")
	print("Aproximação 3 s: posição=", pos, " velocidade=", velocidade)
	pos = Vector2(90, 222)
	velocidade = Vector2(0, -80)
	var contato := {}
	var passos := 0
	while passos < 180 and contato.is_empty():
		var passo: Dictionary = Fisica.passo(pos, velocidade, DT, nivel.corpos, nivel.fisica, nivel.limites, nivel.parametros_nave.radius, "origem")
		pos = passo.position
		velocidade = passo.velocity
		contato = passo.contact
		passos += 1
	verificar(not contato.is_empty() and contato.get("body", {}).get("type", "") == "earth", "rota alcança Terra")
	verificar(pos.x - 90.0 > 5.0, "desvio lateral perceptível")
	print("Rota tutorial: passos=", passos, " tempo=", passos * DT, " posição=", pos, " velocidade=", velocidade, " contato=", contato.get("kind", "nenhum"))
	print("Gravidade #13: ", verificacoes, " verificações, ", falhas, " falhas.")
	quit(1 if falhas else 0)
