# Correção em voo e custo da prévia no Android — #4/#18

## Ambiente e alcance

Em 31/10/2026, após o PR #88 integrado, foi medida a primeira fase no Samsung SM-A556E/Android 16, tela 1080 × 2340. Fonte: `alpha` em `f500161ed4030d6d8541324dc238b8b3bd9de055`, Godot 4.7.2, renderizador Mobile, APK de depuração.

Foi usada uma instalação nova e independente **ORBT QA Prévia**, `com.eclipseestudio.orbt.qa18r88`. Na cópia dos arquivos versionados, mudaram nome/identificador do preset e foram inseridos dois instrumentos temporários: duração de `nave.prever_trajetoria()` e valores ao aplicar um impulso. O algoritmo, o horizonte, os parâmetros físicos e os JSONs das fases foram preservados. Nenhuma instrumentação foi aplicada ao código de produção deste PR.

APK SHA-256 `0be32e32ebca4ef0513a2ca602dd0f02f7bb4c179abf0c67aaef00e342b9226e`. Assinatura v2/v3 e alinhamento de 16 KB verificados. Fase `teste_001`, conteúdo v2, quatro corpos incluindo a Terra, SHA-256 `ffb8a48ac3daf06de560737c393ee72603eb4af6ae9e3c750fcfad089c0f05ad`.

O usuário reservou o aparelho para o teste. Antes de **cada comando de toque e de cada captura**, o auxiliar conferiu que o pacote QA estava em primeiro plano. Uma tentativa anterior na instalação QA R87 foi interrompida por perda de foco e não forneceu resultados; as evidências aceitas abaixo pertencem à nova instalação QA de medição. Os toques foram injetados por ADB; não há avaliação nova de ergonomia com o dedo.

## Instrumentação e reprodução

Arquivos usados somente na cópia QA:

- [Mira com coleta de duração](evidencias-previa-android-2026-10-31/instrumentacao-mira.gd.txt): substituir `src/Nave/mira_nave.gd` na cópia QA. A diferença entre `Time.get_ticks_usec()` antes/depois envolve apenas `nave.prever_trajetoria()`; registro, serialização e desenho ficam fora desse intervalo.
- [Nave com registro dos impulsos](evidencias-previa-android-2026-10-31/instrumentacao-nave.gd.txt): substituir `src/Nave/nave.gd` na cópia QA. Guarda velocidade antes/depois da soma, impulso, massa, condição anterior, saldo e tempo após o sinal de impulso aplicado.
- [Verificação local da coleta](evidencias-previa-android-2026-10-31/verificar-coleta-qa.gd.txt): executada na cópia QA, confirmou 300 amostras sem alterar posição/saldo e conferiu os valores de uma correção. Esse ensaio local não é medição Android.
- [Resumo dos dados](evidencias-previa-android-2026-10-31/resumir-medicao.ps1): percentil por posição `ceil(p × N) - 1`, sem interpolação. Reexecutar na pasta com os arquivos JSON coletados.

Para reproduzir, exportar uma cópia limpa da revisão indicada, aplicar os dois arquivos instrumentados e usar um identificador QA independente. Na primeira fase, aguardar a apresentação; iniciar mira em `(540,800)` e mover até `(540,1280)`, manter por sete segundos e cancelar. Cada gesto válido descarta 60 chamadas de aquecimento e grava 300 amostras; gestos cancelados limpam a coleta parcial. Em seguida, lançar com arraste de `(400,900)` a `(585,1196)` em 450 ms; iniciar outra mira de `(540,800)` até `(540,1100)`, manter por sete segundos e cancelar. As coordenadas são pixels físicos deste aparelho.

Os dois lotes foram gravados no armazenamento do QA e recolhidos via `run-as`. As capturas foram feitas depois de completar cada lote, para evitar captura de tela durante as 300 amostras aceitas. Uma leitura de registros inicialmente falhou por caminho local vazio; a leitura foi repetida, sem repetir ou fabricar medições.

## Medição observada

| Estado durante o lote | N | Mediana | P95 | Máximo | Pontos da prévia | FPS informado pela engine |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Pousada, mirando a Terra | 300 | 4,457 ms | 4,910 ms | 6,574 ms | 44 | 111–120 |
| Em voo, preparando correção | 300 | 5,278 ms | 5,930 ms | 8,174 ms | 61 | 111–118 |

Médias: 4,42485 ms e 5,23950 ms. Os dados brutos incluem [lote pousado](evidencias-previa-android-2026-10-31/previa-qa-0.json), [lote em voo](evidencias-previa-android-2026-10-31/previa-qa-1.json) e [resumo calculado](evidencias-previa-android-2026-10-31/resumo-medicao.json). Todos os registros do primeiro lote têm condição 0 (pousada); os do segundo, condição 1 (em voo). [Captura pousada](evidencias-previa-android-2026-10-31/previa-pousada.png) e [captura em voo](evidencias-previa-android-2026-10-31/previa-em-voo.png).

O tempo é a duração observada da chamada, podendo incluir agendamento do sistema; não é tempo exclusivo de CPU nem tempo total de quadro. O FPS é o contador da engine, não medição de apresentação da tela ou da GPU. O intervalo P95 entre os registros foi 17,722 ms pousada e 23,963 ms em voo; esse intervalo pertence às chamadas de física e não deve ser convertido em FPS de renderização.

Esta caracterização cobre dois lotes de uma fase, em uma sessão de APK de depuração instrumentado, sem comparação A/B com versão sem coleta, nem medição de bateria/temperatura. Não é pior caso da campanha ou benchmark de outros aparelhos. Não foi definido por inferência um limite de desempenho aceitável nem implementada otimização a partir destes números.

## Correção durante o voo

Depois do segundo lote, a mira foi cancelada e uma correção foi enviada com arraste de `(540,800)` a `(540,1100)` em 250 ms. Antes, a tela mostrava combustível 4 e tempo 21,2 s; depois, combustível 3 e tempo 29,5 s. A captura ocorre depois da aplicação, enquanto o tempo volta a correr. [Antes](evidencias-previa-android-2026-10-31/correcao-antes.png), [depois](evidencias-previa-android-2026-10-31/correcao-depois.png).

O [registro do segundo impulso](evidencias-previa-android-2026-10-31/impulso-qa-2.json), tomado imediatamente após o sinal de aplicação, mostrou:

| Campo | Valor |
| --- | --- |
| Condição anterior | 1 — em voo |
| Velocidade antes | `(6,283257961; -0,666035533)` |
| Impulso efetivamente recebido | `(0; -44,114204407)` |
| Massa | 1 |
| Velocidade depois | `(6,283257961; -44,780239105)` |
| Combustível | 4 → 3 |
| Tempo imediatamente após aplicação | 30,0 s |

A diferença entre a velocidade registrada e `velocidade_antes + impulso / massa` foi 0 no eixo X e aproximadamente `8,35 × 10⁻⁷` no eixo Y, abaixo de `10⁻⁵` usado na conferência deste registro. O [primeiro impulso](evidencias-previa-android-2026-10-31/impulso-qa-1.json) partiu pousado, consumiu 5 → 4 e iniciou o voo. Não houve pouso entre os dois impulsos; as 300 amostras do segundo lote confirmam condição em voo, sem gasto durante a mira.

Esses valores demonstram soma de velocidade, uma cobrança na correção observada e reinício do tempo no Android instrumentado. Não demonstram repetição física do gesto pelo usuário, precisão de toda trajetória futura nem todos os casos de interface.

## Preservação e continuidade

Os saves do ORBT principal conservaram os mesmos hashes antes/depois:

```text
checkpoint.json 4ce439ba9b6c95212650ff2dc2d1819d3c4c39ffef50e0c2674a3ba7ba219c7e
progresso.json  040f39efdd632002ae523a008e13d86c6896cabb0e9e9c881a45c9b4ecdc343f
```

O QA instrumentado ficou instalado e pausado ao final; ele é uma ferramenta de medição separada. Nenhuma operação de toque foi enviada depois de encerrar o intervalo de uso reservado. Não houve alteração de produção, regra ou fase.

A evidência avança a correção em voo de #4/#37 e a medição de custo em #18. Permanecem revisão do resultado, critério de desempenho, legibilidade/alcance da prévia em outras situações, casos restantes com Sol e decisões de regra. Não encerra #4/#18 automaticamente. O relato dos quatro testes físicos anteriores e o teste sem instrumentação permanecem no [roteiro anterior](validacao-roteiro-android-2026-10-31.md).
