extends Node2D

const FabricaCorpos = preload("res://src/CorpoEstelar/gerenciador_corpos_estelares.gd")
const Partida = preload("res://src/ControladorJogo/partida.gd")
const CameraNivel = preload("res://src/Nivel/camera_nivel.gd")
const InterfacePartida = preload("res://src/Nivel/interface_partida.gd")

var nivel_res: NivelRes
var campanha_permitida := false
var preferencias: RefCounted
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
	camera = CameraNivel.new()
	camera.partida = partida
	add_child(camera)
	var hud := InterfacePartida.new()
	hud.partida = partida
	hud.preferencias = preferencias
	add_child(hud)
	queue_redraw()


func _ao_alerta(id_corpo: String, ativo: bool) -> void:
	if corpos_visuais.has(id_corpo):
		corpos_visuais[id_corpo].proximo = ativo


func _draw() -> void:
	if nivel_res != null:
		draw_rect(nivel_res.limites, Color(0.35, 0.5, 0.7, 0.35), false, 1)
