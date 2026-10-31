# Continuidade do roteiro Android — issue #4

## Versão e isolamento

Em 31/10/2026, após o PR #87 integrado, foi executado o roteiro na `alpha` em `722c372889fc06eff9935281b105db25e6a6605e`. Samsung SM-A556E, Android 16, tela física 1080 × 2340; Godot 4.7.2 e renderizador Mobile.

O APK foi exportado de uma cópia limpa dos arquivos versionados, alterando apenas o nome para **ORBT QA R87** e o identificador para `com.eclipseestudio.orbt.qa4r87`. Instalação nova, independente do ORBT principal e do ORBT QA 31 anterior. Importação/exportação concluídas; assinatura v2/v3 e alinhamento de 16 KB verificados.

- APK SHA-256: `ec6ab747045e69bca949e2c01aa696ee02920000c16dcd319ee617356a3ba486`.
- Fase `teste_001.json`, conteúdo v2, SHA-256: `ffb8a48ac3daf06de560737c393ee72603eb4af6ae9e3c750fcfad089c0f05ad`.
- As fases, a simulação e os saves não receberam instrumentação ou alterações para estes cenários. Rotas foram preparadas com o simulador existente no computador e executadas por gestos normais no Android.

## Resultados observados por comandos de toque

Coordenadas abaixo são pixels físicos deste aparelho. ADB enviou toques, arrastes e as teclas de início do sistema; as capturas só foram realizadas após confirmar que o QA estava em primeiro plano. Nenhuma tela pessoal foi capturada. Toque injetado em aparelho real não demonstra ergonomia, operação física com uma mão ou multitouch real.

| Cenário e passos | Resultado observado | Evidência |
| --- | --- | --- |
| Campanha → Primeiro impulso; aguardar apresentação | Nave no apoio inicial; combustível 5, tempo 30,0 s, distância 162 m. | [Início](evidencias-roteiro-android-2026-10-31/inicio.png) |
| Toque parado em `(540,800)` | Não lançou nem gastou; captura idêntica à inicial. | [Início](evidencias-roteiro-android-2026-10-31/inicio.png) |
| DOWN `(540,800)`, MOVE `(540,1160)`, voltar a `(540,800)` e UP | Mira mostrou círculo/prévia; retorno ao círculo limpou a mira, manteve combustível 5 e tempo 30,0 s. | [Mira](evidencias-roteiro-android-2026-10-31/mira-ativa.png), [cancelamento](evidencias-roteiro-android-2026-10-31/cancelado-circulo.png) |
| Nova mira ativa; tecla Home; aguardar; reabrir o QA | Voltou pausado, com mira limpa, combustível 5 e tempo 30,0 s. Liberar o toque e tocar Retomar não disparou. | [Suspensão](evidencias-roteiro-android-2026-10-31/suspensao-mira.png), [retomada](evidencias-roteiro-android-2026-10-31/retomada-sem-disparo.png) |
| Explorar mapa; arrastar `(540,1000)` → `(760,1300)`; Voltar à nave | Mapa deslocou; combustível 5 e tempo 30,0 s. Recentralização devolveu a nave ao enquadramento inicial sem impulso. | [Exploração](evidencias-roteiro-android-2026-10-31/exploracao.png), [recentralização](evidencias-roteiro-android-2026-10-31/recentralizado.png) |
| Lançar `(540,800)` → `(540,1280)` em 450 ms; Home logo após; aguardar 3 s e reabrir | Fase pausada em voo, combustível 4, tempo 29,9 s e distância 150 m. Duas capturas separadas por mais 3 s foram idênticas. | [Pausa A](evidencias-roteiro-android-2026-10-31/voo-suspenso-a.png), [pausa B](evidencias-roteiro-android-2026-10-31/voo-suspenso-b.png) |
| Retomar o voo anterior | Terra alcançada, combustível 4 e tempo 27,9 s. | [Vitória após retomar](evidencias-roteiro-android-2026-10-31/voo-retomado-vitoria.png) |
| Voltar à Campanha e repetir Primeiro impulso | Primeira concluída e Tutorial disponível; repetição restaurou combustível 5, tempo 30,0 s e posição inicial. | [Campanha](evidencias-roteiro-android-2026-10-31/campanha-retorno.png), [repetição](evidencias-roteiro-android-2026-10-31/primeira-repetida.png) |
| Arrastar `(540,1100)` → `(540,620)` em 450 ms, contra a origem | Pousou novamente sem atravessar o apoio; combustível 4 e tempo 30,0 s. Checkpoint confirmou `fase=teste_001`, `corpo=origem`, posição `(90,222)`, saldo 4. | [Contato com origem](evidencias-roteiro-android-2026-10-31/origem-saldo-4.png) |
| Repetir o gesto contra a origem até consumir cinco impulsos | Saldo zero e causa “Sem combustível para decolar”. Restaurar esse último pouso manteve saldo zero e o desfecho; não recarregou combustível. | [Derrota](evidencias-roteiro-android-2026-10-31/derrota-sem-combustivel.png), [checkpoint sem saldo](evidencias-roteiro-android-2026-10-31/checkpoint-sem-saldo.png) |
| Reiniciar após a derrota | Combustível 5, tempo 30,0 s, nave e câmera no início. | [Reinício](evidencias-roteiro-android-2026-10-31/reinicio-derrota.png) |
| Reiniciar; quatro gestos contra a origem; último impulso pela rota vertical para a Terra | Saldo zero manteve voo, com indicação “À deriva”; depois Terra alcançada com combustível 0 e tempo 27,8 s. | [Deriva](evidencias-roteiro-android-2026-10-31/deriva-saldo-zero.png), [vitória com zero](evidencias-roteiro-android-2026-10-31/vitoria-saldo-zero.png) |
| Reiniciar; arrastar `(300,1000)` → `(780,1017)` em 450 ms | Derrota “Fora dos limites”, combustível 4 e tempo 25,2 s. | [Limites](evidencias-roteiro-android-2026-10-31/derrota-limites.png) |
| Reiniciar; arrastar `(400,900)` → `(745,1233)` em 450 ms | Derrota “Colisão com perigo” no asteroide, combustível 4 e tempo 27,3 s. | [Asteroide](evidencias-roteiro-android-2026-10-31/derrota-asteroide.png) |
| Reiniciar; arrastar `(400,900)` → `(585,1196)` em 450 ms; aguardar sem novos gestos | Derrota “Tempo esgotado”, combustível 4 e tempo 0,0 s. | [Timeout](evidencias-roteiro-android-2026-10-31/timeout-final.png) |

As capturas A/B da pausa têm o mesmo SHA-256 `a8fb845c6fa793ecf94964c4b45339335ba1df8c4c41f33ff6ab14d3d862ae6a`. Isso demonstra os estados visíveis estáveis durante esse intervalo; não mede contagem de sinais internos nem custo da prévia.

Na captura da deriva e do checkpoint sem saldo, o texto de distância mostrou seta para cima quando o centro da Terra ficou sob esse texto: é evidência parcial do indicador do PR #86 no Android. Não demonstra ausência de toda sobreposição de sprites ou leitura pelo polegar.

## Tentativas e diagnóstico

Um toque inicialmente destinado a Repetir acionou Próxima fase. A campanha foi reaberta e Primeiro impulso foi selecionado novamente antes dos ensaios de origem/saldo; capturas e checkpoint desse contato pertencem à primeira fase. A tentativa na segunda fase não foi usada como evidência de contato contra a origem.

A primeira rota preparada para timeout, arraste `(400,900)` → `(510,1203)`, voltou ao apoio de origem com combustível 4 e tempo 12,7667 s, confirmados no checkpoint. A contagem parou porque houve pouso. Ela não foi contada como timeout; o ensaio foi repetido com a rota da tabela, sem alterar a fase.

O log coletado apenas do processo QA não mostrou `SCRIPT ERROR` nem `FATAL EXCEPTION`, mas contém duas mensagens `java.lang.AssertionError: Failed to close dex file in finalizer`, em `dalvik.system.DexFile.finalize`. O QA permaneceu aberto e os cenários foram concluídos. A origem dessas mensagens não foi diagnosticada nesta entrega; não se afirma ausência de erros do ambiente Android.

## Preservação e trecho manual

Antes do ensaio e ao entregar o aparelho para o teste físico, os arquivos da instalação principal conservaram os hashes:

```text
checkpoint.json 4ce439ba9b6c95212650ff2dc2d1819d3c4c39ffef50e0c2674a3ba7ba219c7e
progresso.json  040f39efdd632002ae523a008e13d86c6896cabb0e9e9c881a45c9b4ecdc343f
```

O QA ficou instalado, com [Primeiro impulso restaurado](evidencias-roteiro-android-2026-10-31/pronto-teste-manual.png), combustível 5 e tempo 30,0 s. O usuário recebeu quatro verificações físicas: cancelamento com uma mão; segundo dedo sem assumir mira/disparar; Home durante mira e retomada sem lançamento; reabrir a fase em modo avião. Nenhum comando ADB foi enviado depois dessa passagem enquanto se aguardava a resposta.

**Resultado manual: aguardando resposta.** Não registrar esses quatro casos como aprovados por inferência. O manifesto QA não lista permissão de internet, mas o ensaio explícito em modo avião ainda depende da confirmação manual; a #33 permanece aberta.

## Pendências de aceite

Esta entrega avança #4 e fornece evidência parcial para #14/#16/#31/#37/#51. Permanecem a resposta aos casos físicos, correção em voo com observação do custo/tempo, teste com Sol em fase que o contenha, custo/desempenho da prévia, avaliação em outros recortes e decisões de regra ainda abertas. Multitouch injetado não foi ensaiado. A rota completa por outro integrante deve ter relato específico e versão registrada; relatos gerais anteriores não substituem os casos pendentes.

Não houve correção de código do jogo, mudança de regra ou conteúdo, nem encerramento de issue nesta etapa. Continuidade e limites seguem a [revisão de escopo](revisao-issues-2026-10-31.md).
