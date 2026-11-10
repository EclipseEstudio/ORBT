# ORBT

Puzzle espacial 2D para Android, feito em Godot. Conduza a nave até a Terra usando impulsos, gravidade, pousos e recursos limitados.

O código contém **30 fases em três níveis**, 90 estrelas douradas e 29 azuis secretas, órbitas, rotação, faixas de pouso, portais, nebulosas e um editor de fases JSON. Versão do projeto: **0.5.0**, código Android **9**. Esses dados vêm dos arquivos locais e não atestam qual APK está publicado.

## Executar

Abra `project.godot` na Godot **4.7.2** (versão fixada no CI) e pressione **F5**. O projeto usa renderizador Mobile, retrato e viewport lógico de 180 × 320, com expansão para outras proporções.

**Jogar** abre a seleção. Pressione uma área livre, arraste e solte: o impulso segue a direção oposta ao arraste. Voltar ao círculo cancela. Cada impulso válido custa uma carga; correções somam velocidade. A guia de mira é reta, sem previsão gravitacional.

O oxigênio começa no primeiro lançamento, para durante o pouso e não recarrega nas correções. Fora da região autoral, é consumido em dobro. Chegar à Terra confirma a conclusão e os recordes. Os níveis 2 e 3 exigem todas as douradas das primeiras dez e vinte fases, respectivamente.

## Documentação

Comece pelo [índice completo](docs/README.md).

| Necessidade | Referência |
| --- | --- |
| Entender o jogo | [Visão geral](docs/projeto/visao-geral.md) e [jogabilidade](docs/regras-de-negocio/jogabilidade.md) |
| Consultar fases e desbloqueios | [Campanha](docs/regras-de-negocio/campanha.md) e [catálogo](docs/projeto/catalogo-fases.md) |
| Desenvolver | [Arquitetura](docs/tecnica/arquitetura.md) e [contrato JSON](docs/tecnica/fases-e-simulacao.md) |
| Criar fases | [Guia do editor](docs/guias/editor-de-fases.md) |
| Testar | [Guia de testes](docs/guias/testes.md) |
| Gerar e instalar APK | [Android](docs/tecnica/android.md) e [atualização](docs/tecnica/atualizacao-android.md) |
| Publicar download | [GitHub Pages e Releases](docs/tecnica/publicacao-web.md) |
| Consultar evidências anteriores | [Histórico](docs/historico/README.md) |

## Testes

Na raiz, com a Godot no PATH:

```powershell
godot --headless --path . --editor --import --quit
./tests/run.ps1 -Godot godot
./tests/run_exportacao.ps1 -Godot godot
```

`-Godot` também aceita o caminho completo do executável. O teste de exportação verifica um PCK no desktop; toque, desempenho e atualização exigem teste no Android.

## Estrutura

| Pasta | Conteúdo |
| --- | --- |
| `src/` | Jogo, simulação, interface, áudio e persistência |
| `Recursos/` | Catálogo, fases, sprites, áudio, fontes e licenças |
| `addons/orbt_editor/` | Plugin de autoria |
| `tests/` | Suítes, capturas e harness do editor |
| `scripts/` | Exportação, assinatura, instalação e preparação de recursos |
| `docs/` | Documentação, fontes de arte, histórico e página de download |
| `build/`, `.godot/` | Saídas e cache locais, ignorados pelo Git |

Documentação conferida contra o código em **10/11/2026**. Evidências antigas valem para as revisões descritas nos respectivos relatórios.
