extends Node
## Música contínua no menu/pausa; efeitos da simulação obedecem à pausa.

const TRILHAS = {
	"menu": preload("res://Recursos/Audio/musica_menu.wav"),
	"fase": preload("res://Recursos/Audio/musica_fase.wav"),
}
const EFEITOS = {
	"impulso": preload("res://Recursos/Audio/impulso.wav"),
	"pouso": preload("res://Recursos/Audio/pouso.wav"),
	"proximidade": preload("res://Recursos/Audio/proximidade.wav"),
	"derrota": preload("res://Recursos/Audio/derrota.wav"),
	"vitoria": preload("res://Recursos/Audio/vitoria.wav"),
	"botao": preload("res://Recursos/Audio/botao.wav"),
}
const INTERVALO_ALERTA_MS := 3000
var controlador: Node
var ativo := true
var trilha_atual := ""
var _musicas: Array[AudioStreamPlayer] = []
var _efeitos_jogo: Array[AudioStreamPlayer] = []
var _efeito_interface: AudioStreamPlayer
var _indice := 0
var _fade: Tween
var _ultimo_alerta := -INTERVALO_ALERTA_MS

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(2):
		var player := AudioStreamPlayer.new()
		player.bus = "Musica"
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(player)
		_musicas.append(player)
	for i in range(4):
		var player := AudioStreamPlayer.new()
		player.bus = "Efeitos"
		player.process_mode = Node.PROCESS_MODE_PAUSABLE
		player.volume_db = -6.0
		add_child(player)
		_efeitos_jogo.append(player)
	_efeito_interface = AudioStreamPlayer.new()
	_efeito_interface.bus = "Efeitos"
	_efeito_interface.volume_db = -6.0
	_efeito_interface.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_efeito_interface)
	get_tree().node_added.connect(_ao_adicionar_nodo)
	for botao in controlador.find_children("*", "BaseButton", true, false):
		_conectar_botao(botao)
	trocar_musica("menu")

func _exit_tree() -> void:
	if _fade != null and _fade.is_running():
		_fade.kill()
	for player in _musicas:
		player.stop()
		player.stream = null
	for player in _efeitos_jogo:
		player.stop()
		player.stream = null
	if _efeito_interface != null:
		_efeito_interface.stop()
		_efeito_interface.stream = null

func _ao_adicionar_nodo(nodo: Node) -> void:
	if nodo is BaseButton and controlador.is_ancestor_of(nodo):
		_conectar_botao(nodo)

func _conectar_botao(botao: BaseButton) -> void:
	if not botao.pressed.is_connected(_tocar_botao):
		botao.pressed.connect(_tocar_botao)

func _tocar_botao() -> void:
	if not ativo:
		return
	_efeito_interface.stream = EFEITOS.botao
	_efeito_interface.play()

func trocar_musica(nome: String) -> void:
	if not ativo:
		return
	if nome == trilha_atual or not TRILHAS.has(nome):
		return
	if _fade != null and _fade.is_running():
		_fade.kill()
	var anterior := _musicas[_indice]
	_indice = 1 - _indice
	var proxima := _musicas[_indice]
	proxima.stop()
	var trilha: AudioStreamWAV = TRILHAS[nome].duplicate()
	trilha.loop_mode = AudioStreamWAV.LOOP_FORWARD
	trilha.loop_begin = 0
	trilha.loop_end = roundi(trilha.get_length() * trilha.mix_rate)
	proxima.stream = trilha
	proxima.volume_db = -60.0
	proxima.play()
	trilha_atual = nome
	_fade = create_tween().set_parallel(true).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_fade.tween_property(proxima, "volume_db", -10.0, 0.35)
	_fade.tween_property(anterior, "volume_db", -60.0, 0.35)
	_fade.chain().tween_callback(anterior.stop)

func tocar_efeito(nome: String) -> void:
	if not ativo or not EFEITOS.has(nome) or nome == "botao" or get_tree().paused:
		return
	for player in _efeitos_jogo:
		if not player.playing:
			player.stream = EFEITOS[nome]
			player.play()
			return
	if nome in ["vitoria", "derrota"]:
		_efeitos_jogo[0].stop()
		_efeitos_jogo[0].stream = EFEITOS[nome]
		_efeitos_jogo[0].play()

func parar_efeitos() -> void:
	for player in _efeitos_jogo:
		player.stop()

func vincular_partida(partida: Node) -> void:
	_ultimo_alerta = -INTERVALO_ALERTA_MS
	partida.nave.impulso_aplicado.connect(func(_id: int): tocar_efeito("impulso"))
	partida.pouso_realizado.connect(func(): tocar_efeito("pouso"))
	partida.concluida.connect(func(_id: String): tocar_efeito("vitoria"))
	partida.perdida.connect(func(_motivo: String): tocar_efeito("derrota"))
	partida.proximidade_alterada.connect(func(id: String, ativo: bool):
		if ativo and partida.estado == partida.Estado.JOGANDO and id != partida.nave.corpo_apoio:
			var agora := Time.get_ticks_msec()
			if agora - _ultimo_alerta >= INTERVALO_ALERTA_MS:
				_ultimo_alerta = agora
				tocar_efeito("proximidade"))
