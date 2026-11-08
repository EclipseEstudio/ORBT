extends SceneTree

const Preferencias = preload("res://src/Configuracoes/preferencias.gd")
var verificacoes := 0
var falhas := 0

class Espia:
	extends "res://src/Configuracoes/preferencias.gd"
	var pulsos: Array[int] = []
	func _vibrar_dispositivo(duracao_ms: int) -> void:
		pulsos.append(duracao_ms)

func conferir(ok: bool, mensagem: String) -> void:
	verificacoes += 1
	if not ok:
		falhas += 1
		push_error(mensagem)

func _initialize() -> void:
	_executar.call_deferred()

func acomodar() -> void:
	for i in 6:
		await process_frame

func _executar() -> void:
	var caminho := "res://.godot/opcoes-%d.json" % OS.get_process_id()
	var antigo := '{"schema_version":1,"musica":0.25,"efeitos":0.75}'
	var arquivo := FileAccess.open(caminho, FileAccess.WRITE)
	arquivo.store_string(antigo)
	arquivo.close()
	var preferencias := Preferencias.new()
	preferencias.caminho = caminho
	preferencias.carregar()
	conferir(preferencias.musica == 0.25 and preferencias.efeitos == 0.75 and preferencias.vibracao and preferencias.dicas, "Preferências antigas preservam volumes e ativam novas opções")
	conferir(FileAccess.get_file_as_string(caminho) == antigo, "Carregar versão antiga não sobrescreve arquivo")
	conferir(preferencias.alterar("vibracao", false) and preferencias.alterar("dicas", false), "Novas opções são salvas")
	var reabertas := Preferencias.new()
	reabertas.caminho = caminho
	reabertas.carregar()
	conferir(not reabertas.vibracao and not reabertas.dicas and reabertas.musica == 0.25 and reabertas.efeitos == 0.75 and reabertas.aviso.is_empty(), "Reabrir versão nova preserva todas as preferências")
	var antes := FileAccess.get_file_as_string(caminho)
	conferir(not reabertas.alterar("vibracao", 1) and not reabertas.alterar("dicas", "false") and not reabertas.alterar("musica", true), "Booleanos e volumes exigem os tipos corretos")
	conferir(FileAccess.get_file_as_string(caminho) == antes, "Valores inválidos não alteram arquivo")
	var invalido := '{"schema_version":2,"musica":0.25,"efeitos":0.75,"vibracao":"false","dicas":false}'
	arquivo = FileAccess.open(caminho, FileAccess.WRITE)
	arquivo.store_string(invalido)
	arquivo.close()
	reabertas.carregar()
	conferir(reabertas.vibracao and reabertas.dicas and not reabertas.aviso.is_empty() and FileAccess.get_file_as_string(caminho) == invalido, "Arquivo inválido recebe padrão com aviso e permanece preservado")
	var pendente := Preferencias.new()
	pendente.caminho = caminho + "/ausente.json"
	conferir(not pendente.alterar("dicas", false) and not pendente.dicas and pendente.salvamento_pendente(), "Falha de escrita mantém opção na sessão e permite retentar")
	pendente.caminho = caminho
	conferir(pendente.salvar() and not pendente.salvamento_pendente(), "Retentar salva a opção pendente")
	var espia := Espia.new()
	var suporte := SubViewportContainer.new()
	root.add_child(suporte)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(180, 240)
	suporte.add_child(viewport)
	var jogo = load("res://src/ControladorJogo/main.tscn").instantiate()
	jogo.persistir_progresso = false
	jogo.ativar_audio = false
	jogo.preferencias = espia
	viewport.add_child(jogo)
	await acomodar()
	jogo.interface_atual.get_node("Splash").free()
	jogo.interface_atual.get_node("Margem/Rolagem/VBoxContainer/Acoes/Configuracoes").pressed.emit()
	var tela: Control = jogo.interface_atual.get_node("TelaConfiguracoes")
	for campo in ["vibracao", "dicas"]:
		var opcao: Button = tela.find_child(campo, true, false)
		tela.rolagem.ensure_control_visible(opcao)
		await acomodar()
		conferir(tela.rolagem.get_global_rect().encloses(opcao.get_global_rect()), campo + ": alcançável em tela de 180x240")
		opcao.button_pressed = false
	conferir(not espia.vibracao and not espia.dicas and espia.pulsos.is_empty(), "Configurações desativam opções sem emitir vibração")
	tela.free()
	conferir(jogo.iniciar_fase("teste_001"), "Abre fase com opções desativadas")
	await acomodar()
	var mundo = jogo.mundo_atual
	var partida = mundo.partida
	partida.set_physics_process(false)
	for filho in mundo.get_children():
		if filho.has_method("_alternar_pausa"):
			await filho.get_node("TituloFase").terminou
	await process_frame
	mundo.camera._process(2)
	var nave = partida.nave
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	var hud: CanvasLayer
	for filho in mundo.get_children():
		if filho.has_method("_alternar_pausa"):
			hud = filho
	hud._process(0)
	conferir(not hud._mensagem.visible, "Ocultar dicas remove ajuda durante a partida")
	partida.aviso_salvamento = "Não foi possível salvar."
	hud._process(0)
	conferir(hud._alerta.visible, "Ocultar dicas preserva avisos de salvamento")
	partida.aviso_salvamento = ""
	nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2.UP * 80)
	partida.avancar(0)
	conferir(espia.pulsos.is_empty(), "Vibração desativada bloqueia impulso")
	partida.pausar()
	hud._process(0)
	conferir(hud._dialogo_pausa.visible, "Ocultar dicas preserva diálogos importantes")
	espia.alterar("dicas", true)
	partida.retomar()
	hud._process(0)
	await process_frame
	conferir(hud.has_node("DialogoDica") and paused, "Ativar dicas durante a tentativa abre ajuda com confirmação")
	hud.get_node("DialogoDica").find_children("*", "Button", true, false)[0].pressed.emit()
	await process_frame
	espia.alterar("vibracao", true)
	partida.reiniciar()
	mundo.camera._process(2)
	nave.entrada.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	nave.entrada.gesto.iniciar(0, Vector2(90, 100))
	nave.entrada.cancelar()
	conferir(espia.pulsos.is_empty(), "Cancelar gesto não vibra")
	nave.solicitar_impulso(nave._ultimo_pedido + 1, Vector2.UP * 80)
	partida.avancar(0)
	conferir(espia.pulsos == [25], "Impulso confirmado produz um único pulso curto")
	partida.resolver_contato({"kind":"body", "body":partida.nivel.obter_corpo("apoio")})
	partida.finalizar(true, "Terra")
	conferir(espia.pulsos == [25, 40, 60], "Pouso e chegada têm retorno tátil")
	conferir(not espia.vibrar(0) and not espia.vibrar(501), "Pulsos fora do limite são recusados")
	suporte.queue_free()
	await process_frame
	for sufixo in ["", ".tmp"]:
		if FileAccess.file_exists(caminho + sufixo):
			DirAccess.remove_absolute(caminho + sufixo)
	print("Opções do jogador: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas else 0)
