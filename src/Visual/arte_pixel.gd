extends RefCounted
## Apresentação somente: nenhuma propriedade do contrato físico é alterada.

const TEXTURAS = {
	"ship": "res://Recursos/Sprites/Identidade/nave_detalhada.png",
	"planet": "res://Recursos/Sprites/Identidade/planeta.png",
	"satellite": "res://Recursos/Sprites/Identidade/satelite.png",
	"earth": "res://Recursos/Sprites/Identidade/terra.png",
	"sun": "res://Recursos/Sprites/Identidade/sol.png",
	"asteroid": "res://Recursos/Sprites/Identidade/asteroide.png"
}
const APOIOS = [Color("a4bfdc"), Color("7d9dbf")]
static var _raios: Dictionary = {}
static var _texturas: Dictionary = {}


static func textura(tipo: String) -> Texture2D:
	if tipo == "station":
		if not _texturas.has(tipo):
			var imagem := Image.create(40, 40, false, Image.FORMAT_RGBA8)
			imagem.fill(Color.TRANSPARENT)
			# Células solares, armação, módulos pressurizados e antena em pixels.
			imagem.fill_rect(Rect2i(4, 18, 32, 4), Color("425776"))
			for x in [3, 26]:
				imagem.fill_rect(Rect2i(x, 11, 11, 18), Color("15263e"))
				imagem.fill_rect(Rect2i(x, 11, 11, 1), Color("9bb9d3"))
				for coluna in range(3):
					for linha in range(5):
						imagem.fill_rect(Rect2i(x + 1 + coluna * 3, 13 + linha * 3, 2, 2), Color("42678e") if linha % 2 == 0 else Color("304d73"))
			imagem.fill_rect(Rect2i(16, 8, 8, 24), Color("142238"))
			imagem.fill_rect(Rect2i(17, 9, 6, 22), Color("829bb6"))
			imagem.fill_rect(Rect2i(17, 10, 2, 20), Color("c1d4e4"))
			imagem.fill_rect(Rect2i(14, 16, 12, 8), Color("182b43"))
			imagem.fill_rect(Rect2i(15, 17, 10, 6), Color("718ca9"))
			imagem.fill_rect(Rect2i(17, 18, 6, 4), Color("264363"))
			imagem.fill_rect(Rect2i(18, 18, 4, 2), Color("9bd7f1"))
			for y in [12, 26]:
				imagem.fill_rect(Rect2i(19, y, 3, 2), Color("304a65"))
			imagem.fill_rect(Rect2i(19, 4, 1, 4), Color("a0b4c9"))
			imagem.fill_rect(Rect2i(17, 3, 5, 1), Color("829bb6"))
			imagem.fill_rect(Rect2i(18, 32, 4, 2), Color("354d69"))
			_texturas[tipo] = ImageTexture.create_from_image(imagem)
		return _texturas[tipo]
	# Carregar após a importação, sem exigir arquivos .ctex ao analisar os scripts.
	if not _texturas.has(tipo):
		_texturas[tipo] = load(TEXTURAS[tipo])
	return _texturas[tipo]


static func raio_textura(textura: Texture2D) -> float:
	if _raios.has(textura):
		return _raios[textura]
	var imagem := textura.get_image()
	var centro := Vector2(imagem.get_size()) / 2
	var raio := 1.0
	for y in range(imagem.get_height()):
		for x in range(imagem.get_width()):
			if imagem.get_pixel(x, y).a > 0:
				raio = maxf(raio, (Vector2(x, y) + Vector2.ONE * 0.5 - centro).length() + sqrt(0.5))
	_raios[textura] = raio
	return raio


static func ajustar(sprite: Sprite2D, raio: float) -> void:
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2.ONE * raio / raio_textura(sprite.texture)


static func cor_apoio(id: String) -> Color:
	return APOIOS[posmod(id.hash(), APOIOS.size())]
