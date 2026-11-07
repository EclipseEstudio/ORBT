extends SceneTree

const Progresso = preload("res://src/Campanha/progresso_persistente.gd")
const Preferencias = preload("res://src/Configuracoes/preferencias.gd")
const Configuracoes = preload("res://src/Configuracoes/tela_configuracoes.gd")

var falhas := 0
var verificacoes := 0

func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)

func _initialize() -> void:
	executar.call_deferred()

func executar() -> void:
	var caminho := "res://.godot/test-reset-%d.json" % OS.get_process_id()
	var itens := [{"id": "a", "estrelas": 3}, {"id": "b", "estrelas": 3}]
	var progresso := Progresso.new()
	progresso.caminho = caminho
	progresso.configurar(itens)
	progresso.concluir_com_coletas("a", itens, 3, 1)
	var tela := Configuracoes.new()
	tela.preferencias = Preferencias.new()
	tela.acao_resetar = func(): return "Progresso resetado." if progresso.resetar() else progresso.aviso
	root.add_child(tela)
	var botao := tela.find_child("ResetarProgresso", true, false) as Button
	botao.pressed.emit()
	conferir(progresso.concluidas.has("a"), "Abrir confirmação não apaga progresso")
	conferir(tela.find_child("ConfirmacaoReset", true, false).visible, "Confirmação é exibida")
	var confirmar := tela.find_child("ConfirmarReset", true, false) as Button
	confirmar.pressed.emit()
	conferir(progresso.concluidas.is_empty() and progresso.melhores_estrelas.is_empty() and progresso.melhores_azuis.is_empty(), "Reset limpa conquistas e estrelas")
	conferir(progresso.pode_abrir("a") and not progresso.pode_abrir("b"), "Somente primeira fase fica disponível")
	var reaberto := Progresso.new()
	reaberto.caminho = caminho
	conferir(reaberto.carregar() and reaberto.concluidas.is_empty(), "Reset permanece ao reabrir")
	DirAccess.remove_absolute(caminho)
	var recuperado := Progresso.new()
	recuperado.caminho = caminho
	conferir(recuperado.carregar() and recuperado.concluidas.is_empty(), "Backup não restaura progresso antigo")
	for sufixo in ["", ".bak", ".tmp", ".bak.tmp"]:
		if FileAccess.file_exists(caminho + sufixo):
			DirAccess.remove_absolute(caminho + sufixo)
	tela.queue_free()
	print("Reset de progresso: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas else 0)
