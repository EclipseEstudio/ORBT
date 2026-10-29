class_name GestoMira extends RefCounted
## Intenção em coordenadas lógicas da tela, independente da nave e da câmera.

var zona_morta := 10.0
var arraste_maximo := 80.0
var impulso_maximo := 80.0
var margem_histerese := 2.0

var contato_ativo := -1
var origem := Vector2.ZERO
var posicao := Vector2.ZERO
var saiu_da_zona_morta := false
var _direcao_estavel := Vector2.ZERO


func iniciar(contato: int, ponto: Vector2) -> bool:
	if contato_ativo != -1 or contato < 0 or not ponto.is_finite():
		return false
	contato_ativo = contato
	origem = ponto
	posicao = ponto
	_direcao_estavel = Vector2.ZERO
	return true


func mover(contato: int, ponto: Vector2) -> void:
	if contato != contato_ativo or contato_ativo == -1:
		return
	if not ponto.is_finite():
		cancelar()
		return
	posicao = ponto
	var distancia := origem.distance_to(posicao)
	var margem := clampf(margem_histerese, 0.0, zona_morta)
	var limiar_saida := zona_morta + margem
	var limiar_retorno := maxf(0.0, zona_morta - margem)
	if distancia > limiar_saida:
		saiu_da_zona_morta = true
		var arraste := origem - posicao
		if not arraste.is_zero_approx():
			_direcao_estavel = arraste.normalized()
	elif saiu_da_zona_morta and distancia < limiar_retorno:
		# Após voltar ao círculo, somente um novo toque pode preparar outro impulso.
		cancelar()


func soltar(contato: int, ponto: Vector2) -> Vector2:
	if contato != contato_ativo or contato_ativo == -1:
		return Vector2.ZERO
	mover(contato, ponto)
	var intencao := obter_impulso()
	cancelar()
	return intencao


func obter_impulso() -> Vector2:
	if contato_ativo == -1:
		return Vector2.ZERO
	var arraste := origem - posicao
	var distancia := arraste.length()
	if distancia <= zona_morta or not is_finite(distancia):
		return Vector2.ZERO
	var direcao := arraste.normalized()
	var margem := clampf(margem_histerese, 0.0, zona_morta)
	var limiar_saida := zona_morta + margem
	if saiu_da_zona_morta and distancia < limiar_saida and not _direcao_estavel.is_zero_approx():
		direcao = _direcao_estavel
	elif not direcao.is_zero_approx():
		_direcao_estavel = direcao
	var intensidade := clampf((distancia - zona_morta) / (arraste_maximo - zona_morta), 0.0, 1.0)
	return direcao * intensidade * impulso_maximo


func cancelar() -> void:
	contato_ativo = -1
	origem = Vector2.ZERO
	posicao = Vector2.ZERO
	saiu_da_zona_morta = false
	_direcao_estavel = Vector2.ZERO


static func calcular_impulso(
	inicio: Vector2, fim: Vector2, raio: float, arraste_limite: float, impulso_limite: float
) -> Vector2:
	if not inicio.is_finite() or not fim.is_finite():
		return Vector2.ZERO
	if not is_finite(raio) or not is_finite(arraste_limite) or not is_finite(impulso_limite):
		return Vector2.ZERO
	if raio < 0.0 or arraste_limite <= raio or impulso_limite <= 0.0:
		return Vector2.ZERO
	var arraste := inicio - fim
	var distancia := arraste.length()
	if distancia <= raio or not is_finite(distancia):
		return Vector2.ZERO
	var intensidade := clampf((distancia - raio) / (arraste_limite - raio), 0.0, 1.0)
	return arraste.normalized() * intensidade * impulso_limite
