extends SceneTree

const Selecao = preload("res://src/Campanha/selecao_fases.gd")
const Area = preload("res://src/Visual/area_segura_menu.gd")
var verificacoes := 0
var falhas := 0

class ProgressoAviso:
	extends "res://src/Campanha/progresso_sessao.gd"
	var pendente := true
	func descricao() -> String:
		return "Não foi possível salvar o progresso. ".repeat(6) if pendente else "Progresso salvo."
	func salvamento_pendente() -> bool:
		return pendente
	func salvar() -> bool:
		pendente = false
		return true

func _initialize() -> void:
	_executar.call_deferred()

func conferir(condicao: bool, mensagem: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(mensagem)

func acomodar() -> void:
	for i in range(4):
		await process_frame

func _executar() -> void:
	var suporte := SubViewportContainer.new()
	root.add_child(suporte)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(180, 240)
	suporte.add_child(viewport)
	var itens: Array = []
	for i in range(10):
		itens.append({"id": "fase_%d" % i, "ordem": i + 1, "nome": "Nome de fase muito longo para testar quebra de linha" if i == 0 else "Fase %d" % (i + 1)})
	var progresso := ProgressoAviso.new()
	progresso.configurar(itens)
	for item in itens.slice(0, 9):
		progresso.concluir(item.id, itens)
	var tela := Selecao.new()
	tela.itens = itens
	tela.progresso = progresso
	tela.erros = ["Não foi possível carregar um arquivo. ".repeat(6)]
	viewport.add_child(tela)
	var segura := Rect2(8, 16, 164, 208)
	Area.aplicar(tela._margem, 0, viewport.get_screen_transform() * segura)
	await acomodar()
	conferir(tela.quantidade_cartoes() == 10, "Diagnósticos não removem os dez cartões")
	conferir(segura.encloses(tela.rolagem.get_global_rect()) and tela.rolagem.size.y >= 48, "Lista conserva espaço para alvo de toque dentro da área segura")
	var rodape: Array = tela._margem.get_child(0).get_children().filter(func(item): return item is Button and item.visible)
	var voltar: Button = tela.find_child("Voltar", true, false)
	conferir(rodape.size() == 1 and rodape.all(func(item): return segura.encloses(item.get_global_rect())) and segura.encloses(voltar.get_global_rect()), "Retentativa de salvar e voltar permanecem acessíveis sem atualização manual")
	conferir(tela.rolagem.get_v_scroll_bar().visible and not tela.rolagem.get_h_scroll_bar().visible, "Avisos e nomes longos usam rolagem vertical")
	var primeiro: Button = tela.obter_cartao(0).get_child(2)
	var trilha: VBoxContainer = tela.find_child("Fases01", true, false)
	var area := tela.rolagem.get_global_rect()
	var ultimo_y := -INF
	for indice in itens.size():
		var cartao := tela.obter_cartao(indice)
		var no := trilha.get_child(indice) as Control
		conferir(cartao.get_parent() == no and no.name == "No%02d" % (indice + 1) and no.position.y > ultimo_y, "Trilha mantém a ordem vertical dos cartões")
		conferir(cartao.global_position.x >= area.position.x and cartao.get_global_rect().end.x <= area.end.x, "Cartão cabe horizontalmente na área segura")
		ultimo_y = no.position.y
	var segundo: Button = tela.obter_cartao(1).get_child(2)
	conferir(primeiro.global_position.x < segundo.global_position.x and primeiro.get_node(primeiro.focus_neighbor_bottom) == segundo and tela.rolagem.follow_focus, "Cartões alternam de lado e o foco segue a sequência")
	conferir(primeiro.size.x >= 28 and primeiro.tooltip_text == primeiro.accessibility_name and primeiro.accessibility_name == "01 - %s - Concluída - Estrelas: 0/0" % itens[0].nome, "Alvo de toque e descrição acessível mantêm número, nome, estado e recorde")
	var ultimo: Button = tela.obter_cartao(9).get_child(2)
	tela.rolagem.ensure_control_visible(ultimo)
	await acomodar()
	conferir(tela.rolagem.get_global_rect().encloses(ultimo.get_global_rect()) and ultimo.size.y >= 40, "Décima fase pode ser alcançada com cartão compacto")
	var escolhas: Array = []
	tela.fase_escolhida.connect(func(id): escolhas.append(id))
	ultimo.pressed.emit()
	ultimo.pressed.emit()
	await acomodar()
	conferir(escolhas == [itens[9].id], "Rolagem preserva abertura única pelo ID da décima fase")
	tela.falhou("Falha ao abrir. Tente novamente.")
	await acomodar()
	conferir(tela.rolagem.get_global_rect().encloses(tela.mensagem.get_global_rect()), "Falha de abertura traz diagnóstico de volta à tela")
	ultimo.pressed.emit()
	await acomodar()
	conferir(escolhas.size() == 2, "Falha de abertura permite nova tentativa")
	tela._tentar_salvar.pressed.emit()
	await acomodar()
	conferir(not tela._tentar_salvar.visible and tela._nota.text == "Progresso salvo.", "Retentativa de salvamento atualiza aviso e rodapé")
	conferir(tela.rolagem.get_global_rect().encloses(tela._nota.get_global_rect()), "Resultado da retentativa fica visível após rolagem")
	tela.atualizar([], [])
	await acomodar()
	conferir(tela.quantidade_cartoes() == 0 and tela.mensagem.text == "Nenhuma fase cadastrada.", "Estado vazio mantém navegação sem cartões residuais")
	suporte.queue_free()
	await process_frame
	print("Layout da campanha: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas else 0)
