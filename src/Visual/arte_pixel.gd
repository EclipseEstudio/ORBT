extends RefCounted
## Apresentação somente: nenhuma propriedade do contrato físico é alterada.

const TEXTURAS = {
	"ship": "res://Recursos/Sprites/Identidade/nave.png",
	"planet": "res://Recursos/Sprites/Identidade/planeta.png",
	"satellite": "res://Recursos/Sprites/Identidade/satelite.png",
	"earth": "res://Recursos/Sprites/Identidade/terra.png",
	"sun": "res://Recursos/Sprites/Identidade/sol.png",
	"asteroid": "res://Recursos/Sprites/Identidade/asteroide.png"
}
const APOIOS = [Color("a8ead5"), Color("f4d1a0")]
static var _raios: Dictionary = {}
static var _texturas: Dictionary = {}


static func textura(tipo: String) -> Texture2D:
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
