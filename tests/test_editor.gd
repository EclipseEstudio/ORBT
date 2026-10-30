extends SceneTree

const Documento = preload("res://addons/orbt_editor/documento.gd")
const Painel = preload("res://addons/orbt_editor/painel.gd")
const Carregador = preload("res://src/Nivel/carregador_fase.gd")
const Teste = preload("res://addons/orbt_editor/teste.gd")
var verificacoes := 0
var falhas := 0


func _initialize() -> void:
	_executar.call_deferred()


func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)


func _executar() -> void:
	var itens: Array = load("res://src/Campanha/catalogo.gd").carregar("res://Recursos/Niveis.json").itens
	for item in itens:
		var fase := Documento.new()
		conferir(fase.abrir(item.arquivo).is_empty() and fase.validar().nivel != null and not fase.modificado(), item.id + ": abre e valida no editor sem alterações")
	var documento := Documento.new()
	var original := FileAccess.get_file_as_string(Documento.EXEMPLO)
	conferir(documento.abrir(Documento.EXEMPLO).is_empty(), "Abre exemplo pelo carregador comum")
	conferir(not documento.modificado(), "Abertura não marca documento alterado")
	var dados: Dictionary = documento.dados.duplicate(true)
	documento.selecionar(0)
	conferir(not documento.modificado(), "Seleção não altera dados")
	var posicao := Vector2(91.123456789, 250)
	documento.mover(0, posicao)
	conferir(documento.dados.bodies[0].id == dados.bodies[0].id and documento.modificado(), "Mover preserva ID e marca alteração")
	documento.editar(["bodies", 0, "id"], "novo_apoio")
	conferir(documento.dados.start.body_id == "novo_apoio", "Renomear apoio atualiza referência")
	documento.editar(["initial_fuel"], 3)
	documento.editar(["flight_timeout"], 45)
	conferir(documento.validar().nivel.combustivel_inicial == 3 and documento.validar().nivel.tempo_voo == 45, "Propriedades usam parâmetros por fase")
	var destino := "res://.godot/teste-editor-fase.json"
	conferir(documento.salvar(destino).is_empty() and not documento.modificado(), "Salvar limpa marca de alteração")
	var outro := Documento.new()
	conferir(outro.abrir(destino).is_empty() and outro.dados == JSON.parse_string(JSON.stringify(documento.dados, "", true, true)), "Reabrir mantém todos os parâmetros")
	conferir(absf(outro.dados.bodies[0].position[0] - posicao.x) < 0.0000000001, "Gravação mantém precisão numérica")
	documento.editar(["name"], "Sobrescrita")
	conferir(documento.salvar(destino).is_empty() and outro.abrir(destino).is_empty() and outro.dados == JSON.parse_string(JSON.stringify(documento.dados, "", true, true)), "Substituição mantém parâmetros")
	documento.mover(0, Vector2(90, 250))
	var antes := documento.dados.duplicate(true)
	conferir(not documento.abrir("res://.godot/ausente.json").is_empty() and documento.dados == antes, "Falha de abertura preserva edição")
	var invalido := FileAccess.open("res://.godot/editor-invalido.json", FileAccess.WRITE)
	invalido.store_string("{")
	invalido.close()
	conferir(not documento.abrir("res://.godot/editor-invalido.json").is_empty() and documento.dados == antes, "JSON malformado preserva documento")
	conferir(not documento.salvar("res://.godot/pasta-inexistente/fase.json").is_empty() and documento.modificado(), "Falha de gravação mantém trabalho sujo")
	documento.inserir("planet", Vector2(1000, 1000))
	var id: String = documento.objeto(documento.selecao).id
	documento.inserir("planet", Vector2(1100, 1000))
	conferir(documento.objeto(documento.selecao).id != id, "Inserção gera IDs únicos")
	documento.excluir()
	conferir(documento.selecao == -2 and documento.dados.bodies.size() == dados.bodies.size() + 1, "Excluir limpa seleção e objeto correto")
	documento.selecionar(0)
	documento.excluir()
	conferir(documento.validar().nivel == null and not documento.validar().erros.is_empty(), "Excluir origem aponta referência inválida")
	conferir(not documento.exportar_teste("res://.godot/teste-editor-bloqueado.json").is_empty(), "Teste inválido bloqueado antes da construção")
	documento.abrir(Documento.EXEMPLO)
	var teste := "res://.godot/orbt-editor-preview.json"
	conferir(documento.exportar_teste(teste).is_empty(), "Teste gera cópia independente")
	var nivel = Carregador.carregar(teste).nivel
	nivel.corpos[0].position = Vector2.ZERO
	nivel.combustivel_inicial = 0
	conferir(documento.dados == dados and FileAccess.get_file_as_string(Documento.EXEMPLO) == original, "Simulação não modifica edição nem JSON autoral")
	documento.mover(1, Vector2(160, 250))
	conferir(documento.validar().nivel != null and not documento.validar().avisos.is_empty(), "Passagem estreita é aviso não bloqueante")
	for ciclo in range(2):
		var painel := Painel.new()
		painel.persistir_sessao = false
		root.add_child(painel)
		await process_frame
		conferir(painel.documento.dados == dados and painel.mapa.get_child_count() == 0, "Editor desenha sem instanciar física")
		painel.documento.selecionar(-1)
		painel.documento.mover(-1, Vector2(100, 60))
		conferir(painel._propriedades.get_child_count() > 0 and painel.documento.dados.goal.position == [100.0, 60.0], "Seleção e edição da Terra atualizam painel")
		painel.queue_free()
		await process_frame
		conferir(not is_instance_valid(painel), "Ciclo libera painel e sinais")
	var rascunho := "res://.godot/editor-teste-rascunho.json"
	if FileAccess.file_exists(rascunho):
		DirAccess.remove_absolute(rascunho)
	var painel_rascunho := Painel.new()
	painel_rascunho.caminho_rascunho = rascunho
	root.add_child(painel_rascunho)
	painel_rascunho.documento.selecionar(0)
	painel_rascunho.documento.editar(["initial_fuel"], 3)
	painel_rascunho.queue_free()
	await process_frame
	painel_rascunho = Painel.new()
	painel_rascunho.caminho_rascunho = rascunho
	root.add_child(painel_rascunho)
	conferir(painel_rascunho.documento.modificado() and painel_rascunho.documento.selecao == 0 and painel_rascunho.documento.dados.initial_fuel == 3, "Rascunho restaura alterações e seleção")
	painel_rascunho.documento.salvar(destino)
	painel_rascunho.queue_free()
	await process_frame
	painel_rascunho = Painel.new()
	painel_rascunho.caminho_rascunho = rascunho
	root.add_child(painel_rascunho)
	conferir(not painel_rascunho.documento.modificado(), "Rascunho salvo restaura sem alteração fantasma")
	painel_rascunho.queue_free()
	await process_frame
	documento.abrir(Documento.EXEMPLO)
	documento.exportar_teste(teste)
	var jogo := Teste.new()
	root.add_child(jogo)
	await process_frame
	var partida = jogo.nivel.partida
	partida.set_physics_process(false)
	jogo.nivel.camera._process(2.0)
	var nave = jogo.nivel.get_node("Nave")
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	conferir(nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2(0, -80)), "Teste joga com controle de produção")
	for passo in range(180):
		partida.avancar(1.0 / 60)
	conferir(partida.estado == partida.Estado.CONCLUIDA and nave.combustivel == 4, "Mesma rota vence no teste do editor")
	partida.reiniciar()
	nave.condicao = nave.Condicao.EM_VOO
	nave.global_position = Vector2(10000, 10000)
	partida.avancar(1.0 / 60)
	conferir(partida.estado == partida.Estado.PERDIDA, "Teste também permite derrota")
	conferir(documento.dados == dados and FileAccess.get_file_as_string(Documento.EXEMPLO) == original, "Vitória, reinício e derrota preservam dados")
	jogo.queue_free()
	await process_frame
	print("Editor: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(0 if falhas == 0 else 1)
