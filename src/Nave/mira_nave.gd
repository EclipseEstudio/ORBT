extends Node2D

@onready var nave = get_parent().get_parent()
var pontos := PackedVector2Array()
const SEGMENTOS_FORCA := 10
const CORES_FORCA := [Color("4b6585"), Color("688db5"), Color("8cbce0"), Color("d5edff")]
const Fonte = preload("res://Recursos/Fontes/PressStart2P-Regular.ttf")


func largura_forca() -> float:
	return 4.0 + roundf(nave.entrada.gesto.obter_intensidade() * 2.0)


static func cor_intensidade(intensidade: float) -> Color:
	var faixa := clampf(intensidade, 0.0, 1.0) * (CORES_FORCA.size() - 1)
	var indice := mini(int(faixa), CORES_FORCA.size() - 2)
	return CORES_FORCA[indice].lerp(CORES_FORCA[indice + 1], faixa - indice)

func pontos_forca() -> PackedVector2Array:
	var gesto = nave.entrada.gesto
	if gesto.contato_ativo == -1:
		return PackedVector2Array()
	return PackedVector2Array([gesto.origem, gesto.posicao])

func forca_saturada() -> bool:
	var gesto = nave.entrada.gesto
	return gesto.contato_ativo != -1 and gesto.origem.distance_to(gesto.posicao) >= gesto.arraste_maximo


func _ready() -> void:
	nave.get_node("Entrada").mira_encerrada.connect(limpar)
	nave.get_node("Entrada").impulso_solicitado.connect(func(_impulso: Vector2): limpar())


func limpar() -> void:
	pontos.clear()
	queue_redraw()


func _physics_process(_delta: float) -> void:
	if not nave.entrada.pode_controlar() or nave.entrada.gesto.contato_ativo == -1:
		limpar()
		return
	pontos = nave.obter_guia_mira()
	queue_redraw()


func _draw() -> void:
	var entrada = nave.get_node("Entrada")
	if not entrada.pode_controlar() or entrada.gesto.contato_ativo == -1:
		return
	var origem: Vector2 = entrada.gesto.origem
	var valido: bool = not entrada.gesto.obter_impulso().is_zero_approx()
	var cor := Color("8cbce0") if valido else Color("63738a")
	var linha := pontos_forca()
	var intensidade: float = entrada.gesto.obter_intensidade()
	var cor_forca := cor_intensidade(intensidade) if valido else cor
	var largura := largura_forca()
	draw_line(linha[0], linha[1], Color("0b1423"), largura + 2)
	for indice in SEGMENTOS_FORCA:
		var inicio := float(indice) / SEGMENTOS_FORCA
		var fim := float(indice + 1) / SEGMENTOS_FORCA
		var cor_segmento := cor_intensidade(intensidade * fim) if valido else cor
		draw_line(linha[0].lerp(linha[1], inicio), linha[0].lerp(linha[1], fim), cor_segmento, largura)
	draw_circle(linha[1], largura / 2 + 2, Color("0b1423"))
	draw_circle(linha[1], largura / 2 + 1, cor_forca)
	if forca_saturada():
		draw_arc(linha[1], 5, 0, TAU, 16, cor_forca, 1)
	draw_arc(origem, entrada.zona_morta, 0, TAU, 40, Color("0b1423"), 3)
	draw_arc(origem, entrada.zona_morta, 0, TAU, 40, cor, 1)
	var texto := "%.1f" % entrada.gesto.obter_impulso().length()
	var tamanho := Fonte.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 6)
	var posicao := origem - Vector2(tamanho.x / 2.0, entrada.zona_morta + 5.0)
	posicao.x = clampf(posicao.x, 2.0, maxf(2.0, get_viewport_rect().size.x - tamanho.x - 2.0))
	posicao.y = maxf(8.0, posicao.y)
	draw_string_outline(Fonte, posicao, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 6, 2, Color("070e21"))
	draw_string(Fonte, posicao, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color("d5edff"))
	if not valido:
		draw_line(origem - Vector2(3, 3), origem + Vector2(3, 3), cor, 1)
		draw_line(origem - Vector2(-3, 3), origem + Vector2(-3, 3), cor, 1)
	var transformacao: Transform2D = nave.get_canvas_transform()
	for indice in range(1, pontos.size()):
		if not pontos[indice-1].is_finite() or not pontos[indice].is_finite():
			continue
		draw_line(transformacao * pontos[indice - 1], transformacao * pontos[indice], Color("0b1423"), 3)
		draw_line(transformacao * pontos[indice - 1], transformacao * pontos[indice], Color("a3c8e5"), 1)
	if pontos.size() > 1:
		draw_circle(transformacao * pontos[-1], 2, cor, false, 1)
