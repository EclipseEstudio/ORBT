# Recursos visuais e procedência

Fonte do inventário atual: `src/Visual/arte_pixel.gd`, scripts de apresentação, cenas, `export_presets.cfg` e créditos. Conferido em 10/11/2026. Fontes originais e registros de geração são preservados para reprodução; não devem ser confundidos com todos os recursos usados em produção.

| Recurso | Fonte atual |
| --- | --- |
| Nave | `Recursos/Sprites/Identidade/nave_detalhada.png` |
| Planeta, Terra, Sol e asteroide | PNGs correspondentes em `Recursos/Sprites/Identidade/` |
| Estação | Gerada em código por `src/Visual/arte_pixel.gd` |
| Satélite legado | Textura ainda disponível; carregador normaliza o tipo físico |
| Menu | `Recursos/Sprites/fundo_menu_principal.png`, com apresentação/parallax em código |
| Estrelas, ícones, bússolas | Scripts de `src/Visual/` |
| Propulsão, rastro e explosão | `propulsao_pixel.gd`, `rastro_nave.gd`, `explosao.gd` |
| Portais/nebulosa | `portal_visual.gd`, `nebulosa.gd`, `nebulosa.gdshader` |
| Fonte comum | `Recursos/Fontes/PressStart2P-Regular.ttf` |
| Título ORBT | `Recursos/Fontes/orbt-pixel.fnt` e atlas PNG |
| Marcas | Recursos em `Recursos/Logos/` e `Recursos/Sprites/`; ver [registro das marcas](../../Recursos/Logos/README.md) |

Filtro nearest e ajuste de escala são implementados no código; o raio visual não substitui colisão/captura. Veja [interface](../tecnica/ui-hud.md).

## Fontes e registros

`fontes/` guarda PNGs de origem usados por `scripts/preparar_sprites.gd` e `scripts/preparar_nave_detalhada.gd`. Eles são lidos diretamente como imagens, sem necessidade de importação da pasta docs. Não excluir as fontes como se fossem capturas descartáveis.

- [prompts.json](prompts.json): descrição de geração dos seis sprites iniciais.
- [manifesto.json](manifesto.json): procedência, preparação e hashes registrados dos seis sprites iniciais; não é um manifesto completo da arte atual.
- [prancha.png](prancha.png): prancha histórica da identidade inicial.
- [Propulsão](propulsao/README.md): registro da substituição dos bitmaps antigos por código.

Os registros atribuem os seis sprites iniciais à ferramenta OpenAI ImageGen e não declaram licença pública adicional. A fonte da nave detalhada é preservada separadamente; não inferir autoria/licença dos demais arquivos a partir do manifesto inicial. Recursos legados e modelos visuais excluídos no preset não foram removidos nesta organização.

Press Start 2P tem [SIL OFL](../../Recursos/Fontes/OFL.txt), incluída na exportação. A marca Godot tem [registro/licença](../../Recursos/Logos/GODOT-LICENSE.txt). Mantenha essas licenças e os créditos. Esta organização não cria uma licença geral para o projeto.

## Reprodução

```powershell
godot --headless --path . --script scripts/preparar_sprites.gd
godot --headless --path . --script scripts/preparar_nave_detalhada.gd
```

Esses comandos regeneram saídas: execute apenas ao preparar arte, confira o diff, importe e revise hashes quando aplicável. Inspeções visuais no desktop não comprovam contraste ou ergonomia no Android.
