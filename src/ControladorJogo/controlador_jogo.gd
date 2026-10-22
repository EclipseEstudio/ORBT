class_name ControladorJogo extends Node

const ProgressoSessao = preload("res://src/Campanha/progresso_sessao.gd")
const Selecao = preload("res://src/Campanha/selecao_fases.gd")
var progresso := ProgressoSessao.new()
var erro_abertura := ""
var _abrindo := false

@onready var mundo: Node = $Mundo
@onready var interface: Control = $Interface
var mundo_atual: Node2D
var interface_atual: Control


func _ready() -> void:
	GLOBAL.controlador_jogo = self
	if interface.get_child_count() > 0:
		interface_atual = interface.get_child(0)
	if mundo.get_child_count() > 0:
		mundo_atual = mundo.get_child(0)
	interface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	progresso.configurar(GLOBAL.gerendiador_de_nivel.itens)
	if OS.has_feature("android"):
		var itens: Array = GLOBAL.gerendiador_de_nivel.itens
		if itens.is_empty():
			mostrar_selecao()
		elif not iniciar_fase(itens[0].id):
			mostrar_selecao()
			interface_atual.falhou(erro_abertura)


func iniciar_fase(id_nivel: String) -> bool:
	if _abrindo:
		return false
	if not progresso.pode_abrir(id_nivel):
		erro_abertura = "Fase bloqueada ou indisponível."
		return false
	_abrindo = true
	var instancia := GLOBAL.gerendiador_de_nivel.obter_nivel_instancia(id_nivel)
	if instancia == null:
		erro_abertura = "Não foi possível abrir a fase.\n" + "\n".join(GLOBAL.gerendiador_de_nivel.erros)
		_abrindo = false
		return false
	erro_abertura = ""
	instancia.campanha_permitida = true
	get_tree().paused = false
	alterar_mundo_nodo(instancia)
	instancia.partida.concluida.connect(func(id: String):
		if mundo_atual == instancia:
			progresso.concluir(id, GLOBAL.gerendiador_de_nivel.itens))
	instancia.partida.selecao_solicitada.connect(func():
		if mundo_atual == instancia:
			mostrar_selecao())
	var vazio := Control.new()
	vazio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	alterar_interface_nodo(vazio)
	_liberar_abertura.call_deferred()
	return true


func _liberar_abertura() -> void:
	_abrindo = false


func mostrar_selecao() -> void:
	get_tree().paused = false
	alterar_mundo_nodo(Node2D.new())
	var gerenciador = GLOBAL.gerendiador_de_nivel
	gerenciador.carregar_niveis()
	progresso.configurar(gerenciador.itens)
	var tela := Selecao.new()
	tela.itens = gerenciador.itens
	tela.erros = gerenciador.erros.duplicate()
	tela.progresso = progresso
	tela.fase_escolhida.connect(func(id: String):
		if interface_atual == tela and not iniciar_fase(id):
			tela.falhou(erro_abertura))
	tela.voltar.connect(mostrar_menu)
	tela.recarregar.connect(func():
		gerenciador.carregar_niveis()
		progresso.configurar(gerenciador.itens)
		tela.atualizar(gerenciador.itens, gerenciador.erros))
	alterar_interface_nodo(tela)


func mostrar_menu() -> void:
	get_tree().paused = false
	alterar_mundo_nodo(Node2D.new())
	alterar_interface("res://src/MenuPrincipal/MenuPrincipal.tscn")


func alterar_interface(caminho: String, deletar := true, manter_rodando := false) -> void:
	var cena = load(caminho)
	if cena is PackedScene:
		var instancia = cena.instantiate()
		if instancia is Control:
			alterar_interface_nodo(instancia, deletar, manter_rodando)
		else:
			instancia.free()


func alterar_interface_nodo(nova: Control, _deletar := true, manter_rodando := false) -> void:
	if is_instance_valid(interface_atual):
		if manter_rodando:
			interface_atual.hide()
		else:
			interface.remove_child(interface_atual)
			interface_atual.queue_free()
	interface_atual = nova
	interface.add_child(nova)


func alterar_mundo(caminho: String, deletar := true, manter_rodando := false) -> void:
	var cena = load(caminho)
	if cena is PackedScene:
		var instancia = cena.instantiate()
		if instancia is Node2D:
			alterar_mundo_nodo(instancia, deletar, manter_rodando)
		else:
			instancia.free()


func alterar_mundo_nodo(novo: Node2D, _deletar := true, manter_rodando := false) -> void:
	if is_instance_valid(mundo_atual):
		var partida = mundo_atual.get("partida")
		if is_instance_valid(partida):
			partida.nave.parar()
			partida.set_physics_process(false)
		if manter_rodando:
			mundo_atual.hide()
		else:
			mundo.remove_child(mundo_atual)
			mundo_atual.queue_free()
	mundo_atual = novo
	mundo.add_child(novo)
