extends SceneTree

var verificacoes := 0
var falhas := 0

func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)

func efeito_tocando(audio: Node, nome: String) -> bool:
	return audio._efeitos_jogo.any(func(p: AudioStreamPlayer): return p.playing and p.stream == audio.EFEITOS[nome])

func _initialize() -> void:
	_executar.call_deferred()

func _executar() -> void:
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	root.add_child(jogo)
	await process_frame
	var audio = jogo.audio
	conferir(audio.trilha_atual == "menu" and audio._musicas[audio._indice].playing, "menu inicia trilha")
	conferir(audio._musicas[audio._indice].stream.loop_mode == AudioStreamWAV.LOOP_FORWARD and audio._musicas[audio._indice].stream.loop_end > 0, "trilha do menu repete")
	audio._musicas[audio._indice].pitch_scale = 16.0
	await create_timer(0.75).timeout
	conferir(audio._musicas[audio._indice].playing, "música continua após atravessar o fim da faixa")
	audio._musicas[audio._indice].pitch_scale = 1.0
	conferir(jogo.interface_atual.get_node("VBoxContainer/Button").pressed.is_connected(audio._tocar_botao), "botão existente recebe som")
	var indice: int = audio._indice
	audio.trocar_musica("menu")
	conferir(audio._indice == indice, "mesma música não reinicia")
	conferir(jogo.iniciar_fase("teste_001") and audio.trilha_atual == "fase", "fase muda para música calma")
	conferir(audio._musicas[audio._indice].stream.loop_mode == AudioStreamWAV.LOOP_FORWARD and audio._musicas[audio._indice].stream.loop_end > 0, "trilha da fase repete")
	await create_timer(0.5).timeout
	conferir(audio._musicas.filter(func(p: AudioStreamPlayer): return p.playing).size() == 1, "transição termina com uma única música")
	var partida = jogo.mundo_atual.partida
	partida.set_physics_process(false)
	var nave = partida.nave
	nave.impulso_aplicado.emit(1)
	conferir(efeito_tocando(audio, "impulso"), "impulso gera efeito")
	var apoio: Dictionary = partida.nivel.obter_corpo("apoio")
	nave.global_position = apoio.position + Vector2.LEFT * 25
	partida.resolver_contato({"kind": "body", "body": apoio})
	conferir(efeito_tocando(audio, "pouso"), "pouso gera efeito")
	audio.parar_efeitos()
	audio._ultimo_alerta = -audio.INTERVALO_ALERTA_MS
	partida.proximidade_alterada.emit("asteroide", true)
	var ultimo: int = audio._ultimo_alerta
	conferir(efeito_tocando(audio, "proximidade"), "entrada em proximidade gera alerta")
	partida.proximidade_alterada.emit("outro", true)
	conferir(audio._ultimo_alerta == ultimo and audio._efeitos_jogo.filter(func(p: AudioStreamPlayer): return p.playing).size() == 1, "alertas próximos são limitados")
	partida.pausar()
	conferir(not audio._efeitos_jogo[0].can_process() and audio._efeitos_jogo[0].stream_paused and audio._musicas[audio._indice].can_process() and not audio._musicas[audio._indice].stream_paused, "pausa suspende efeito de jogo e mantém música")
	audio.parar_efeitos()
	audio.tocar_efeito("impulso")
	conferir(not efeito_tocando(audio, "impulso"), "pausa bloqueia novos efeitos de simulação")
	audio._tocar_botao()
	conferir(audio._efeito_interface.playing and audio._efeito_interface.can_process(), "botão continua audível na pausa")
	partida.retomar()
	partida.finalizar(false, "teste")
	conferir(efeito_tocando(audio, "derrota"), "derrota gera efeito")
	for player in audio._efeitos_jogo:
		player.stream = audio.EFEITOS.impulso
		player.play()
	audio.tocar_efeito("derrota")
	conferir(efeito_tocando(audio, "derrota"), "resultado tem prioridade quando os canais estão ocupados")
	audio.parar_efeitos()
	partida.reiniciar()
	partida.finalizar(true, "teste")
	conferir(efeito_tocando(audio, "vitoria"), "vitória gera efeito")
	jogo.preferencias.alterar("musica", 0.25)
	jogo.preferencias.alterar("efeitos", 0.0)
	conferir(is_equal_approx(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Musica")), linear_to_db(0.25)) and AudioServer.is_bus_mute(AudioServer.get_bus_index("Efeitos")), "preferências controlam canais separadamente")
	jogo.mostrar_menu()
	conferir(audio.trilha_atual == "menu" and not audio._efeitos_jogo.any(func(p: AudioStreamPlayer): return p.playing), "voltar ao menu troca música e interrompe efeitos antigos")
	await create_timer(0.5).timeout
	conferir(audio._musicas.filter(func(p: AudioStreamPlayer): return p.playing).size() == 1, "retorno deixa apenas uma música")
	jogo.preferencias.alterar("musica", 1.0)
	jogo.preferencias.alterar("efeitos", 1.0)
	await process_frame
	jogo.free()
	await create_timer(0.2).timeout
	print("Áudio: ", verificacoes, " verificações, ", falhas, " falhas.")
	quit(1 if falhas else 0)
