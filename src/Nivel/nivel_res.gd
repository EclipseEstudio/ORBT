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


func obter_corpo(id_corpo: String) -> Dictionary:
	for corpo in corpos:
		if corpo.id == id_corpo:
			return corpo
	return {}
