extends Node2D

const FabricaCorpos = preload("res://src/CorpoEstelar/gerenciador_corpos_estelares.gd")
const Explosao = preload("res://src/Visual/explosao.gd")
const Nebulosa = preload("res://src/Visual/nebulosa.gd")
const Partida = preload("res://src/ControladorJogo/partida.gd")
const CameraNivel = preload("res://src/Nivel/camera_nivel.gd")
const InterfacePartida = preload("res://src/Nivel/interface_partida.gd")
const RastroNave = preload("res://src/Nave/rastro_nave.gd")
const EstrelasColetaveis = preload("res://src/Visual/estrelas_coletaveis.gd")
const CeuParallax = preload("res://src/Visual/ceu_parallax.gd")
const CombustiveisColetaveis = preload("res://src/Visual/combustiveis_coletaveis.gd")

var nivel_res: NivelRes
var campanha_permitida := false
var preferencias: RefCounted
var progresso: RefCounted
var proxima_fase := ""
var partida: Node
var camera: Camera2D
var corpos_visuais: Dictionary = {}


func _ready() -> void:
	if nivel_res == null:
		$Nave.hide()
		$Nave.simulacao_automatica = false
		$Nave.entrada.habilitada = false
		return
	for dados in nivel_res.corpos:
		var corpo := FabricaCorpos.criar(dados)
		$Estaticos.add_child(corpo)
		corpos_visuais[dados.id] = corpo
	partida = Partida.new()
	partida.campanha_permitida = campanha_permitida
	add_child(partida)
	partida.proximidade_alterada.connect(_ao_alerta)
	partida.iniciar(nivel_res, $Nave)
	partida.perdida.connect(_explodir)
	partida.reiniciada.connect(func(): $Nave.show())
	var estrelas := EstrelasColetaveis.new()
	estrelas.partida = partida
	add_child(estrelas)
	camera = CameraNivel.new()
	camera.partida = partida
	add_child(camera)
	if nivel_res.dados_autorais.has("nebula"):
		var nevoa := Nebulosa.new()
		nevoa.partida = partida
		nevoa.camera = camera
		add_child(nevoa)
	$CanvasLayer/GeradorEstrelas.hide()
	var ceu := CeuParallax.new()
	ceu.name = "CeuParallax"
	ceu.camera = camera
	$CanvasLayer.add_child(ceu)
	var combustiveis := CombustiveisColetaveis.new()
	combustiveis.partida = partida
	add_child(combustiveis)
	var rastro := RastroNave.new()
	rastro.partida = partida
	rastro.camera = camera
	add_child(rastro)
	var hud := InterfacePartida.new()
	hud.partida = partida
	hud.preferencias = preferencias
	hud.progresso = progresso
	hud.proxima_fase = proxima_fase
	add_child(hud)
	queue_redraw()


func _process(_delta: float) -> void:
	if not is_instance_valid(partida):
		return
	for dados in partida.nave.corpos:
		if corpos_visuais.has(dados.id):
			var visual: Node2D = corpos_visuais[dados.id]
			visual.position = dados.position
			var giro: float = partida.nave.Fisica.rotacao_corpo(dados, partida.nave.tempo_simulacao)
			visual.sprite.rotation = giro
			visual.marcas.dados["_rotation"] = giro
			visual.marcas.queue_redraw()


func _ao_alerta(id_corpo: String, ativo: bool) -> void:
	if corpos_visuais.has(id_corpo):
		corpos_visuais[id_corpo].proximo = ativo


func _draw() -> void:
	if nivel_res != null:
		draw_rect(nivel_res.limites, Color(0.35, 0.5, 0.7, 0.35), false, 1)


func _explodir(_motivo: String) -> void:
	var efeito := Explosao.new()
	efeito.position = $Nave.position
	add_child(efeito)
	$Nave.hide()
