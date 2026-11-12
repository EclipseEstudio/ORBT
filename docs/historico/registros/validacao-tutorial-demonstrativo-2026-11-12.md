# Tutorial demonstrativo — validação de 12/11/2026

Revisão: alterações locais sobre `5b0ac21`, na branch `melhorias/tutorial-campanha-54`. Ambiente: Windows, Godot 4.7.2 stable. Sem commit, exportação ou publicação nesta validação.

## Entrega

O tutorial aparece somente no diálogo da primeira fase, após o título. São duas demonstrações animadas: lançamento e cancelamento, acompanhadas de lembretes sobre custo do impulso, direção, pouso e oxigênio. Próximo e Voltar navegam sem exigir gestos; Jogar, fechar, Escape ou Voltar nativo dispensam o diálogo e liberam a fase. O menu principal mantém Jogar, configurações e créditos.

Não há prática interativa nem entrada de gestos na área animada. A campanha permanece pausada, preservando recursos, posição, checkpoint e progresso. Desativar dicas também oculta a apresentação automática. As demais fases mantêm suas dicas autorais.

A narrativa está planejada em [Volta para casa](../../projeto/plano-narrativa-tutorial.md): postos nas fases 1–29, Terra na fase 30 e descanso na praia no encerramento. Destinos, textos legados e arte final ainda não foram migrados.

## Verificação automatizada

Executadas com `--headless --path . --script tests/<suíte>.gd --quit-after 1200`, usando caminho absoluto para `--log-file`. Todas terminaram com código zero e sem `ERROR:` ou `SCRIPT ERROR:`.

| Suíte | Verificações | Falhas |
| --- | ---: | ---: |
| `test_tutorial_demonstrativo` | 44 | 0 |
| `test_tutorial` | 257 | 0 |
| `test_menus` | 26 | 0 |
| `test_narrativa` | 14 | 0 |
| `test_voltar` | 18 | 0 |
| Total | 359 | 0 |

O teste demonstrativo confere apresentação automática, ausência do botão no menu, animação durante a pausa, avanço sem prática, retorno à etapa anterior, fechamento por Jogar/Escape/Voltar, preferência de dicas e recursos preservados. Injeta toque e mouse sobre as duas animações para conferir que não controlam a nave ou alteram a etapa. Verifica o encaixe em 180×240, 180×320 e 240×320. A suíte de tutorial também confere as dicas das 30 fases.

## Revisão visual

`tests/capturar_tutorial_demonstrativo.gd` gerou capturas com renderização Compatibility/OpenGL em `.godot/tutorial-demonstrativo/`. Conferidos o menu sem o botão Como jogar e os dois demonstrativos no diálogo em telas de 180×240 e 180×320.

## Aceite restante

Não houve teste no Android nem observação de um jogador que não seja autor. Conferir no APK: recortes do aparelho, leitura das animações, navegação, suspensão/retomada e compreensão sem orientação verbal. Esta validação não encerra o aceite humano da issue #54 e não comprova a nova narrativa implementada.
