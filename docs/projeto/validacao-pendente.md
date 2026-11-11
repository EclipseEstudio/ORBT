# Validação do estado atual

O código comprova a presença dos recursos, mas não seu aceite humano. Esta lista orienta a validação da versão atual, sem presumir status remoto de issues ou tratar implementação existente como funcionalidade por construir.

Os ensaios de desktop, pacote, renderização, editor e Web de 10/11/2026 estão no [relatório de validação](../historico/registros/validacao-2026-11-10.md). Passaram sem falhas funcionais; não substituem os aceites humanos abaixo. O ADB falhou antes de enumerar dispositivos, impedindo o teste Android nesta sessão.

As dicas das 30 fases foram revisadas na [correção da issue #54](../historico/registros/revisao-tutorial-issue-54.md), em 11/11/2026. Os testes conferem apresentação, cancelamento, custo, preferências e encaixe dos diálogos em telas lógicas de 180×240 e 180×320. Ainda falta observar um jogador que não seja autor e conferir leitura e toque no APK atual; a revisão textual não encerra esse aceite.

| Frente | Conferir na revisão atual | Referência |
| --- | --- | --- |
| Campanha | Completar 30 fases, avaliar dificuldade, alternativas e douradas necessárias aos portões | `test_fases.gd`, `test_campanha_30.gd` |
| Controles | Uma mão, multitouch, cancelamento, bloqueio contra origem e suspensão sem disparo | `test_controles.gd`, `test_decolagem.gd` |
| Mecânicas | Leitura de faixas, apoios móveis, instrumentos na nebulosa e saída de portais | Suítes de órbitas, rotação, portais e campanha |
| Interface/arte | Contraste, recortes, oclusão pelo dedo e alvos de toque no Android | `test_ui_redesign.gd`, `test_estrelas_ui.gd` |
| Tutorial | Jogador que não seja autor compreender o jogo sem ajuda verbal | `test_tutorial.gd` e dicas autorais |
| Áudio/vibração | Alto-falante, fones, alertas, pausa, volumes e pulsos | `test_audio.gd`, `test_opcoes_jogador.gd` |
| Saves | Atualização do APK anterior, recuperação e falha de escrita | [Atualização Android](../tecnica/atualizacao-android.md) |
| Editor | Outro integrante criar, salvar, reabrir e testar; conferir retorno e recarga | [Guia](../guias/editor-de-fases.md) |
| Narrativa | Aprovar textos e sua apresentação efetiva, distinguindo tooltip de texto visível | `narrativa.gd`, `menu_principal.gd`, `interface_partida.gd` |
| Desempenho | Tempo de quadro e resposta em fases avançadas no APK atual | [Android](../tecnica/android.md#roteiro-no-aparelho) |

Registre revisão/hash, APK, aparelho/Android, passos e resultado. Os [relatórios antigos](../historico/README.md) valem para suas versões. Mudanças em gravidade, guia de mira, oxigênio e campanha exigem conferir o comportamento atual.

Cena final de praia, modo infinito e evento de erupção solar não estão implementados; são possibilidades de evolução. A reconciliação de GitHub Projects/issues com essas evidências é uma revisão própria.
