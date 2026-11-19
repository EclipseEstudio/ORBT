extends SceneTree

const Catalogo = preload("res://src/Campanha/catalogo.gd")
const Carregador = preload("res://src/Nivel/carregador_fase.gd")
const Arte = preload("res://src/Visual/arte_pixel.gd")
const CenaNivel = preload("res://src/Nivel/Nivel.tscn")
const CAMPOS_FISICOS := ["mass", "visual_radius", "collision_radius", "capture_radius",
	"danger_radius", "proximity_radius", "gravity_radius"]

var verificacoes := 0
var falhas := 0


func _initialize() -> void:
	_executar.call_deferred()


func conferir(condicao: bool, mensagem: String) -> bool:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)
	return condicao


func _executar() -> void:
	var catalogo := Catalogo.carregar("res://Recursos/Niveis.json")
	conferir(catalogo.erros.is_empty() and catalogo.itens.size() == 30, "Catálogo contém as 30 fases válidas")
	var terra := Arte.textura("earth")
	var posto := Arte.textura("outpost")
	conferir(posto != terra and posto == Arte.textura("outpost"), "Posto usa textura procedural própria em cache")
	for item: Dictionary in catalogo.itens:
		var resultado := Carregador.carregar(item.arquivo)
		if conferir(resultado.nivel != null and resultado.erros.is_empty(), item.id + ": carrega sem erros " + str(resultado.erros)):
			_conferir_fase(resultado.nivel, item.ordem)

	var dados: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://Recursos/Fases/teste_001.json"))
	dados.goal.erase("visual_type")
	var legado := Carregador.validar(dados)
	conferir(legado.nivel != null and legado.nivel.corpos[-1].visual_type == "earth", "Destino legado sem visual_type usa Terra")
	for invalido in ["station", "OUTPOST", 42, null]:
		dados.goal.visual_type = invalido
		var resultado := Carregador.validar(dados)
		conferir(resultado.nivel == null and "visual_type" in "\n".join(resultado.erros), "Destino rejeita visual_type inválido: " + str(invalido))
	dados.goal.visual_type = "outpost"
	for identidade in ["earth", "outpost"]:
		dados.bodies[0].visual_type = identidade
		var resultado := Carregador.validar(dados)
		conferir(resultado.nivel == null and "visual_type" in "\n".join(resultado.erros), "Corpos comuns rejeitam visual_type: " + identidade)

	print("Destino visual: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas else 0)


func _conferir_fase(nivel: NivelRes, ordem: int) -> void:
	var final := ordem == 30
	var identidade := "earth" if final else "outpost"
	var rotulo := "TERRA" if final else "POSTO"
	var autoral: Dictionary = nivel.dados_autorais.goal
	var destino := nivel.obter_corpo(autoral.id)
	conferir(destino.get("type") == "earth" and destino.get("visual_type") == identidade and autoral.get("visual_type") == identidade,
		nivel.id + ": o destino físico earth tem a identidade autoral " + identidade)
	conferir(not final or nivel.id == "grande_retorno", "Terra é o destino do Grande Retorno")

	for campo in CAMPOS_FISICOS:
		conferir(destino.get(campo) == autoral.get(campo), nivel.id + ": valor autoral preservado em " + campo)
	conferir(destino.position == Vector2(autoral.position[0], autoral.position[1]) and nivel.fisica == nivel.dados_autorais.physics,
		nivel.id + ": posição e parâmetros de gravidade autorais preservados")
	var dados_legados := nivel.dados_autorais.duplicate(true)
	dados_legados.goal.erase("visual_type")
	var legado: NivelRes = Carregador.validar(dados_legados).nivel
	if conferir(legado != null, nivel.id + ": variante sem metadado continua válida"):
		var corpo_legado := legado.obter_corpo(autoral.id)
		var corpo_atual := destino.duplicate(true)
		corpo_legado.erase("visual_type")
		corpo_atual.erase("visual_type")
		conferir(corpo_atual == corpo_legado, nivel.id + ": mesmos dados físicos e mesma rotação normalizada que a fase legada")

	var mundo := CenaNivel.instantiate()
	mundo.nivel_res = nivel
	root.add_child(mundo)
	var corpo: Node2D = mundo.corpos_visuais[autoral.id]
	conferir(corpo.sprite.texture == Arte.textura(identidade) and corpo.marcas.rotulo_destino == rotulo,
		nivel.id + ": textura e rótulo visuais do destino")
	var concluidas: Array[String] = []
	mundo.partida.concluida.connect(func(id: String): concluidas.append(id))
	mundo.partida.resolver_contato({"kind": "body", "body": destino})
	conferir(mundo.partida.estado == mundo.partida.Estado.CONCLUIDA and concluidas == [nivel.id],
		nivel.id + ": contato com o destino dispara vitória")
	mundo.free()
