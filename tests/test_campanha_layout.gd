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
	conferir(tela.cartoes.get_child_count() == 10, "Diagnósticos não removem os dez cartões")
	conferir(segura.encloses(tela.rolagem.get_global_rect()) and tela.rolagem.size.y >= 48, "Lista conserva espaço para alvo de toque dentro da área segura")
	var rodape: Array = tela._margem.get_child(0).get_children().filter(func(item): return item is Button and item.visible)
	conferir(rodape.size() == 3 and rodape.all(func(item): return segura.encloses(item.get_global_rect())), "Salvar, atualizar e voltar permanecem acessíveis com aviso longo")
	conferir(tela.rolagem.get_v_scroll_bar().visible and not tela.rolagem.get_h_scroll_bar().visible, "Avisos e nomes longos usam rolagem vertical")
	var nome: Label = tela.cartoes.get_child(0).get_child(0)
	conferir(nome.size.x <= tela.rolagem.size.x and nome.size.y > 20, "Nome longo quebra linha dentro da lista")
	var ultimo: Button = tela.cartoes.get_child(9).get_child(2)
	tela.rolagem.ensure_control_visible(ultimo)
	await acomodar()
	conferir(tela.rolagem.get_global_rect().encloses(ultimo.get_global_rect()) and ultimo.size.y >= 48, "Décima fase pode ser alcançada sem reduzir alvo de toque")
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
	conferir(tela.cartoes.get_child_count() == 0 and tela.mensagem.text == "Nenhuma fase cadastrada.", "Estado vazio mantém navegação sem cartões residuais")
	suporte.queue_free()
	await process_frame
	print("Layout da campanha: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas else 0)
