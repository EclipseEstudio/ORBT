class_name ControladorJogo extends Node

const ProgressoSessao = preload("res://src/Campanha/progresso_sessao.gd")
const ProgressoPersistente = preload("res://src/Campanha/progresso_persistente.gd")
const CheckpointPersistente = preload("res://src/Campanha/checkpoint_persistente.gd")
const Preferencias = preload("res://src/Configuracoes/preferencias.gd")
const AudioJogo = preload("res://src/Audio/audio_jogo.gd")
@export var persistir_progresso := true
@export var ativar_audio := true
var caminho_progresso := "user://progresso.json"
var caminho_checkpoint := "user://checkpoint.json"
var caminho_preferencias := "user://preferencias.json"
var preferencias = Preferencias.new()
var audio: Node
var checkpoint = CheckpointPersistente.new()
const Selecao = preload("res://src/Campanha/selecao_fases.gd")
var progresso := ProgressoSessao.new()
var erro_abertura := ""
var _abrindo := false
var _voltar_pendente := false

@onready var mundo: Node = $Mundo
@onready var interface: Control = $Interface
var mundo_atual: Node2D
var interface_atual: Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Receber Voltar durante a pausa sem fazer o mundo herdar PROCESS_MODE_ALWAYS.
	mundo.process_mode = Node.PROCESS_MODE_PAUSABLE
	interface.process_mode = Node.PROCESS_MODE_PAUSABLE
	GLOBAL.controlador_jogo = self
	preferencias.caminho = caminho_preferencias
	preferencias.persistir = persistir_progresso
	preferencias.carregar()
	audio = AudioJogo.new()
	audio.controlador = self
	audio.ativo = ativar_audio
	add_child(audio)
	if persistir_progresso:
		var salvo := ProgressoPersistente.new()
		salvo.caminho = caminho_progresso
		salvo.carregar()
		progresso = salvo
		checkpoint.caminho = caminho_checkpoint
		checkpoint.carregar()
	if interface.get_child_count() > 0:
		interface_atual = interface.get_child(0)
	if mundo.get_child_count() > 0:
		mundo_atual = mundo.get_child(0)
	interface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	progresso.configurar(GLOBAL.gerendiador_de_nivel.itens)
	if is_instance_valid(interface_atual) and interface_atual.has_method("configurar_checkpoint"):
		interface_atual.configurar_checkpoint()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and is_node_ready():
		solicitar_voltar(true)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		get_viewport().set_input_as_handled()
		solicitar_voltar()


func solicitar_voltar(nativo := false) -> void:
	if _voltar_pendente or _abrindo:
		return
	_voltar_pendente = true
	_executar_voltar.call_deferred(nativo)


func _executar_voltar(nativo: bool) -> void:
	_liberar_voltar()
	# Fechar somente a tela sobreposta; a pausa permanece como estava.
	for nome in ["TelaConfiguracoes", "TelaCreditos"]:
		var tela := find_child(nome, true, false)
		if tela != null and not tela.is_queued_for_deletion():
			tela.fechar()
			return
	if is_instance_valid(interface_atual) and interface_atual is Selecao:
		mostrar_menu()
		return
	if is_instance_valid(mundo_atual) and mundo_atual.get("partida") != null:
		var partida = mundo_atual.partida
		if partida.estado in [partida.Estado.JOGANDO, partida.Estado.PAUSADO]:
			partida.pausar()
		else:
			mostrar_selecao()
		return
	# Preservar a saída nativa apenas quando já estiver no menu principal.
	if nativo:
		get_tree().quit()


func _liberar_voltar() -> void:
	# Não atravessar duas telas por notificações repetidas no mesmo quadro.
	await get_tree().process_frame
	_voltar_pendente = false


func iniciar_fase(id_nivel: String, recuperacao: Dictionary = {}) -> bool:
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
	instancia.preferencias = preferencias
	instancia.proxima_fase = proxima_fase(id_nivel)
	get_tree().paused = false
	alterar_mundo_nodo(instancia)
	audio.vincular_partida(instancia.partida)
	audio.trocar_musica("fase")
	instancia.partida.concluida.connect(func(id: String):
		if mundo_atual == instancia:
			progresso.concluir(id, GLOBAL.gerendiador_de_nivel.itens)
			instancia.partida.aviso_salvamento = progresso.aviso_para_partida())
	instancia.partida.selecao_solicitada.connect(func():
		if mundo_atual == instancia:
			mostrar_selecao())
	instancia.partida.menu_solicitado.connect(func():
		if mundo_atual == instancia:
			mostrar_menu())
	instancia.partida.proxima_solicitada.connect(func():
		if mundo_atual != instancia or instancia.partida.estado != instancia.partida.Estado.CONCLUIDA:
			return
		var id: String = proxima_fase(instancia.nivel_res.id)
		if id.is_empty() or not iniciar_fase(id):
			mostrar_selecao()
			if not id.is_empty():
				interface_atual.falhou(erro_abertura))
	if not recuperacao.is_empty():
		instancia.partida._checkpoint = recuperacao.duplicate(true)
		instancia.partida.pausar()
		instancia.partida.restaurar_checkpoint(true)
	if persistir_progresso:
		instancia.partida.checkpoint_alterado.connect(func(dados: Dictionary):
			if mundo_atual == instancia:
				checkpoint.salvar(dados, int(instancia.nivel_res.dados_autorais.content_version))
				instancia.partida.aviso_salvamento = checkpoint.aviso)
		if recuperacao.is_empty():
			checkpoint.salvar(instancia.partida._checkpoint, int(instancia.nivel_res.dados_autorais.content_version))
			instancia.partida.aviso_salvamento = checkpoint.aviso
		instancia.partida.concluida.connect(func(_id: String):
			if mundo_atual == instancia:
				if not checkpoint.bloqueado:
					checkpoint.limpar())
	var vazio := Control.new()
	vazio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	alterar_interface_nodo(vazio)
	_liberar_abertura.call_deferred()
	return true


func proxima_fase(id: String) -> String:
	var itens: Array = GLOBAL.gerendiador_de_nivel.itens
	for indice in range(itens.size() - 1):
		if itens[indice].id == id:
			return itens[indice + 1].id
	return ""


func checkpoint_disponivel() -> bool:
	if checkpoint.salvamento_pendente():
		return false
	if checkpoint.dados.is_empty():
		return false
	if not checkpoint.dados.get("fase") is String:
		checkpoint.aviso = "Checkpoint inválido. Reinicie a fase."
		checkpoint.bloqueado = true
		return false
	var id: String = checkpoint.dados.fase
	if not progresso.pode_abrir(id):
		checkpoint.aviso = "Fase do checkpoint indisponível. Reinicie uma fase."
		checkpoint.bloqueado = true
		return false
	return not checkpoint.validar(GLOBAL.gerendiador_de_nivel.obter_nivel_res(id)).is_empty()


func tentar_salvar_checkpoint() -> bool:
	if not persistir_progresso:
		return false
	return checkpoint.tentar_salvar()


func continuar_checkpoint() -> bool:
	if checkpoint.salvamento_pendente():
		return false
	if checkpoint.dados.is_empty() or not checkpoint.dados.get("fase") is String:
		checkpoint.aviso = "Checkpoint inválido. Reinicie a fase."
		return false
	var id: String = checkpoint.dados.fase
	if not progresso.pode_abrir(id):
		checkpoint.aviso = "Fase do checkpoint indisponível. Reinicie uma fase."
		checkpoint.bloqueado = true
		return false
	var recurso = GLOBAL.gerendiador_de_nivel.obter_nivel_res(id)
	var dados: Dictionary = checkpoint.validar(recurso)
	if dados.is_empty():
		return false
	return iniciar_fase(id, dados)


func _liberar_abertura() -> void:
	_abrindo = false


func mostrar_selecao() -> void:
	get_tree().paused = false
	audio.trocar_musica("menu")
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
	audio.trocar_musica("menu")
	alterar_mundo_nodo(Node2D.new())
	alterar_interface("res://src/MenuPrincipal/MenuPrincipal.tscn")
	if is_instance_valid(interface_atual) and interface_atual.has_method("configurar_checkpoint"):
		interface_atual.configurar_checkpoint()


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
	if is_instance_valid(audio):
		audio.parar_efeitos()
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
