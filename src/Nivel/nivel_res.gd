@tool
class_name NivelRes extends Resource
## Dados validados; cada tentativa recebe sua própria cópia.

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
var dados_autorais: Dictionary = {}


func obter_posicao_inicial() -> Vector2:
	if inicio.has("position"):
		return Vector2(inicio.position[0], inicio.position[1])
	var apoio := obter_corpo(inicio.body_id)
	var normal := Vector2.RIGHT.rotated(deg_to_rad(inicio.angle_degrees))
	return apoio.position + normal * (apoio.collision_radius + parametros_nave.radius)


func obter_corpo(id_corpo: String) -> Dictionary:
	for corpo in corpos:
		if corpo.id == id_corpo:
			return corpo
	return {}
