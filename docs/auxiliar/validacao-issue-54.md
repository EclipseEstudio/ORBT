# Validação do tutorial contextual — issue #54

Execução em 30/10/2026, Windows, Godot 4.7.2, base `498d57d` com as alterações deste PR. `tests/run.ps1`: 1.185 verificações, zero falhas, incluindo dez específicas do tutorial. `tests/run_exportacao.ps1`: 23 verificações no PCK; `tests/test_tutorial.gd` contra o PCK isolado: dez verificações, zero falhas. O PCK no computador não substitui um APK em aparelho Android.

| Ação | Esperado e observado no teste |
| --- | --- |
| Iniciar primeira fase | Instrução pede toque e segurar e mostra a dica autoral para alcançar a Terra. |
| Tocar área livre e arrastar | Dica orienta arraste e retorno ao círculo; ao sair da zona morta mostra soltura, custo e cancelamento. O toque inicia a mira normalmente. |
| Voltar ao círculo e soltar | Gesto cancela sem impulso ou gasto de combustível. |
| Arrastar e soltar fora do círculo | Um impulso é aplicado, uma unidade é consumida e a dica explica custo e ausência de recarga no pouso. |
| Pousar, pausar e reiniciar | Pouso não reabastece; pausa mostra sua própria mensagem; reinício restaura a instrução inicial. |

O texto usa `MOUSE_FILTER_IGNORE`. As capturas de início, toque, arraste e pós-lançamento foram inspecionadas no renderizador OpenGL no Windows; a mira permaneceu visível e as dicas apareceram no rodapé. Para reproduzir: `godot --path . --rendering-method gl_compatibility --script tests/capturar_tutorial.gd`; as imagens ficam em `.godot/tutorial-*.png`.

Ainda é preciso testar em aparelho com jogadores não autores: registrar revisão/APK, modelo e Android, observar se compreendem a primeira fase sem instrução verbal, cobertura da rota e toque pelo polegar; registrar resultados e ajustar as dicas. Essas observações não foram realizadas nesta execução, portanto a #54 permanece aberta para aceite.
