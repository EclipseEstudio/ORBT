extends SceneTree

const Preferencias = preload("res://src/Configuracoes/preferencias.gd")
const Tela = preload("res://src/Configuracoes/tela_configuracoes.gd")
const Area = preload("res://src/Visual/area_segura_menu.gd")
var verificacoes := 0
var falhas := 0
var base := "res://.godot/retentar-preferencias-%d" % OS.get_process_id()

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

func abrir(pai: Node, preferencias: RefCounted) -> Control:
	var tela := Tela.new()
	tela.preferencias = preferencias
	pai.add_child(tela)
	var recorte: Rect2 = tela.get_viewport().get_screen_transform() * Rect2(8, 16, 164, 208)
	Area.aplicar(tela._margem, 0, recorte)
	return tela

func _executar() -> void:
	var suporte := SubViewportContainer.new()
	root.add_child(suporte)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(180, 240)
	suporte.add_child(viewport)
	var preferencias := Preferencias.new()
	preferencias.caminho = base + "/ausente/preferencias.json"
	preferencias.carregar()
	var tela := abrir(viewport, preferencias)
	await acomodar()
	conferir(not tela._tentar_salvar.visible and not preferencias.salvamento_pendente(), "Sem falha não há retentativa pendente")
	paused = true
	tela.find_child("musica", true, false).value = 0.25
	tela.find_child("efeitos", true, false).value = 0.75
	await acomodar()
	conferir(tela._tentar_salvar.visible and preferencias.salvamento_pendente(), "Falha de escrita oferece retentativa")
	conferir(tela._aviso.text.contains("nesta sessão") and tela._aviso.text.contains("não foram salvos"), "Aviso distingue valores da sessão de valores salvos")
	conferir(is_equal_approx(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Musica")), linear_to_db(0.25)) and is_equal_approx(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Efeitos")), linear_to_db(0.75)), "Falha não impede aplicação independente dos volumes")
	var scroll: ScrollContainer = tela._margem.get_child(0)
	scroll.ensure_control_visible(tela._tentar_salvar)
	await acomodar()
	conferir(scroll.get_global_rect().encloses(tela._tentar_salvar.get_global_rect()), "Retentativa alcançável na tela curta")
	tela._tentar_salvar.pressed.emit()
	conferir(preferencias.salvamento_pendente() and tela._tentar_salvar.visible and not FileAccess.file_exists(preferencias.caminho), "Nova falha mantém aviso e dados em memória")
	tela.find_child("Voltar", true, false).pressed.emit()
	await acomodar()
	conferir(paused and preferencias.salvamento_pendente(), "Fechar configurações mantém pausa e pendência")
	tela = abrir(viewport, preferencias)
	await acomodar()
	conferir(tela._tentar_salvar.visible and is_equal_approx(tela.find_child("musica", true, false).value, 0.25) and is_equal_approx(tela.find_child("efeitos", true, false).value, 0.75), "Reabrir mantém volumes e retentativa")
	conferir(DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(base + "/ausente")) == OK, "Destino temporário de teste disponível para recuperação")
	tela._tentar_salvar.pressed.emit()
	await acomodar()
	conferir(not preferencias.salvamento_pendente() and not tela._tentar_salvar.visible and tela._aviso.text.is_empty(), "Sucesso remove pendência e retentativa sem mover seletores")
	var salvo := Preferencias.new()
	salvo.caminho = preferencias.caminho
	salvo.carregar()
	conferir(is_equal_approx(salvo.musica, 0.25) and is_equal_approx(salvo.efeitos, 0.75) and salvo.aviso.is_empty(), "Nova instância carrega os volumes recuperados do arquivo real")
	conferir(paused and preferencias.musica == 0.25 and preferencias.efeitos == 0.75, "Salvar novamente preserva pausa e valores da sessão")
	var texto := FileAccess.get_file_as_string(preferencias.caminho)
	conferir(not preferencias.alterar("musica", NAN) and not preferencias.salvamento_pendente() and FileAccess.get_file_as_string(preferencias.caminho) == texto, "Valor inválido não cria pendência nem altera arquivo salvo")
	tela.free()
	var corrompido := FileAccess.open(base + "/corrompido.json", FileAccess.WRITE)
	corrompido.store_string("{invalido")
	corrompido.close()
	var invalido := Preferencias.new()
	invalido.caminho = base + "/corrompido.json"
	invalido.carregar()
	tela = abrir(viewport, invalido)
	await acomodar()
	conferir(not invalido.aviso.is_empty() and not tela._tentar_salvar.visible and not invalido.salvamento_pendente() and FileAccess.get_file_as_string(invalido.caminho) == "{invalido", "Arquivo inválido carregado não é tratado como edição pendente nem sobrescrito")
	paused = false
	suporte.queue_free()
	await process_frame
	for arquivo in [preferencias.caminho, preferencias.caminho + ".tmp", invalido.caminho]:
		if FileAccess.file_exists(arquivo):
			DirAccess.remove_absolute(arquivo)
	DirAccess.remove_absolute(base + "/ausente")
	DirAccess.remove_absolute(base)
	print("Retentativa de preferências: %d verificações, %d falhas." % [verificacoes, falhas])
	quit(1 if falhas else 0)
