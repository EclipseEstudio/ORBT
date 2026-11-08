extends SceneTree
const Carregador = preload("res://src/Nivel/carregador_fase.gd")
const Cena = preload("res://src/Nivel/Nivel.tscn")
const Rotas = preload("res://tests/rotas_nivel3.gd")
func _initialize() -> void:
	executar.call_deferred()

func executar() -> void:
	var falhas := 0
	for rota in Rotas.ROTAS:
		var caminho: String = "res://Recursos/Fases/" + rota.id + ".json"
		var dados: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(caminho))
		var carregado := Carregador.validar(dados)
		if carregado.nivel == null:
			printerr(rota.id, ": ", carregado.erros)
			falhas += 1
			continue
		var mundo = Cena.instantiate()
		mundo.nivel_res = carregado.nivel
		root.add_child(mundo)
		mundo.partida.set_physics_process(false)
		var resultado := Rotas.executar(mundo.partida, rota.get("coleta",rota.etapas))
		print(rota.id, " ", resultado.venceu, " ", resultado.resumo)
		if not resultado.venceu:
			falhas += 1
		elif dados.stars.is_empty():
			var candidatos: Array = []
			for trecho in resultado.trechos:
				var posicao: Vector2 = trecho[1]
				var livre := true
				for corpo in carregado.nivel.corpos:
					if posicao.distance_to(corpo.position) < mundo.partida.nave.Fisica.raio_contato(corpo) + 22:
						livre = false
				if livre: candidatos.append(posicao)
			for i in range(4):
				var posicao: Vector2 = candidatos[int((i+1.0)*candidatos.size()/5.0)]
				dados.stars.append({"id":"dourada_"+str(i+1) if i<3 else "azul","type":"gold" if i<3 else "blue","position":[snappedf(posicao.x,0.001),snappedf(posicao.y,0.001)],"radius":7})
			var validado := Carregador.validar(dados)
			if validado.nivel == null:
				printerr(rota.id, ": estrelas ",validado.erros)
				falhas += 1
			else:
				var arquivo := FileAccess.open(caminho,FileAccess.WRITE)
				arquivo.store_string(JSON.stringify(dados,"  ",false)+"\n")
		mundo.free()
	quit(1 if falhas else 0)
