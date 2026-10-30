extends SceneTree
## Sintetiza os recursos originais de áudio do ORBT; não usa amostras externas.
const TAXA := 22050
const PASTA := "res://Recursos/Audio/"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(PASTA)
	gravar("musica_menu", 8.0, func(t): return musica(t, true))
	gravar("musica_fase", 16.0, func(t): return musica(t, false))
	for item in [["impulso", 0.24], ["pouso", 0.32], ["proximidade", 0.25], ["derrota", 0.55], ["vitoria", 0.75], ["botao", 0.09]]:
		var nome: String = item[0]
		var duracao: float = item[1]
		gravar(nome, duracao, func(t): return efeito(nome, t, duracao))
	print("Áudio original gerado em ", PASTA)
	quit()

func gravar(nome: String, duracao: float, amostra: Callable) -> void:
	var quantidade := roundi(TAXA * duracao)
	var pcm := PackedByteArray()
	pcm.resize(quantidade * 2)
	for i in range(quantidade):
		var t := float(i) / TAXA
		var borda := minf(1.0, minf(t / 0.025, (duracao - t) / 0.025))
		var valor: float = clampf(amostra.call(t) * borda, -0.95, 0.95)
		pcm.encode_s16(i * 2, roundi(valor * 32767.0))
	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_16_BITS
	audio.mix_rate = TAXA
	audio.stereo = false
	audio.data = pcm
	var erro := audio.save_to_wav(PASTA + nome + ".wav")
	if erro != OK:
		push_error("Não foi possível gravar " + nome)

func frequencia(nota: int) -> float:
	return 440.0 * pow(2.0, float(nota - 69) / 12.0)

func musica(t: float, menu: bool) -> float:
	var notas: Array = [60, 64, 67, 72, 67, 64, 62, 67, 69, 72, 76, 72, 69, 67, 64, 67] if menu else [48, 55, 60, 64, 50, 57, 62, 65, 53, 60, 65, 69, 48, 55, 60, 67]
	var duracao := 0.25 if menu else 0.5
	var indice := int(t / duracao) % notas.size()
	var fase := fmod(t, duracao)
	var f := frequencia(notas[indice])
	var envoltoria := minf(1.0, fase / 0.025) * exp(-fase * (7.0 if menu else 2.5))
	var melodia := (sin(TAU * f * t) + 0.18 * sin(TAU * f * 2.0 * t)) * envoltoria
	var baixo := sin(TAU * frequencia(notas[int(indice / 4) * 4] - 12) * t)
	return melodia * (0.15 if menu else 0.11) + baixo * (0.055 if menu else 0.035)

func efeito(nome: String, t: float, duracao: float) -> float:
	var p := t / duracao
	var env := pow(1.0 - p, 1.5)
	var f := 440.0
	match nome:
		"impulso": f = 230.0 + 490.0 * p
		"pouso": f = 540.0 - 220.0 * p
		"proximidade": f = 740.0 if p < 0.5 else 600.0
		"derrota": f = 380.0 - 240.0 * p
		"vitoria": f = [523.25, 659.25, 783.99][mini(int(p * 3.0), 2)]
		"botao": f = 680.0
	return (sin(TAU * f * t) + 0.15 * sin(TAU * f * 2.0 * t)) * env * 0.2
