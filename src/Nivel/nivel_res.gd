@tool
class_name NivelRes extends Resource
## Dados validados; cada tentativa recebe sua própria cópia.

const Fisica = preload("res://src/Nave/simulacao_voo.gd")
const ANTECIPACAO_ESTACAO := 0.35

var id := ""
var nome := ""
var ordem := 1
var limites := Rect2()
var combustivel_inicial := 5
var tempo_voo := 30.0
var fisica: Dictionary = {}
var parametros_nave: Dictionary = {}
var inicio: Dictionary = {}
var corpos: Array = []
var estrelas: Array = []
var combustiveis: Array = []
var dados_autorais: Dictionary = {}


func obter_tempo_inicial() -> float:
	return float(inicio.get("time_seconds", 0.0))


func obter_posicao_inicial() -> Vector2:
	if inicio.has("position"):
		return Vector2(inicio.position[0], inicio.position[1])
	var apoio := obter_corpo(inicio.body_id)
	var normal := Vector2.RIGHT.rotated(deg_to_rad(inicio.angle_degrees))
	if apoio.type == "station":
		var velocidade_giro := float(apoio.get("rotation", {}).get("degrees_per_second", 0.0))
		normal = normal.rotated(-deg_to_rad(velocidade_giro) * ANTECIPACAO_ESTACAO)
	return Fisica.posicao_corpo(apoio, obter_tempo_inicial()) + normal * (apoio.collision_radius + parametros_nave.radius)


func obter_corpo(id_corpo: String) -> Dictionary:
	for corpo in corpos:
		if corpo.id == id_corpo:
			return corpo
	return {}


func quantidade_estrelas(tipo := "gold") -> int:
	return estrelas.filter(func(estrela: Dictionary): return estrela.get("type", "gold") == tipo).size()
