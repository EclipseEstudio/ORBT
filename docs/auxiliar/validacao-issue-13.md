# Validação do modelo de gravidade — issue #13

Execução em 30/10/2026, Windows, Godot 4.7.2.stable.official.ed1daf0bf, branch `codex/issue-13-validacao` baseada em `7f7fc35`. O teste e esta nota fazem parte do PR. Não houve teste Android nesta execução.

## Decisão submetida à revisão

Manter para a primeira fase a fórmula suavizada do GDD já usada por `SimulacaoVoo`: `a = Σ(G * massa * r / (|r|² + epsilon²)^(3/2))`, com `r` apontando da nave para cada fonte. A integração é semi-implícita a 60 Hz e a prévia usa o mesmo passo e os mesmos contatos. Isso dá força contínua e finita e evita combinar o modelo com as antigas duas faixas. Há limites validados e unidades em [fases e simulação](../tecnica/fases-e-simulacao.md#modelo-físico-e-decisão-de-arquitetura). Corpos são estáticos; gravitação mútua, órbitas e rotação não são simuladas.

Na fase `teste_001`, versão de conteúdo 2, `G=2`, `epsilon=8`, massas da origem e apoio 24.000 e 30.000. Em 29/10 a versão 1 (`G=1`, massas 6.000 e 500) foi recalibrada para tornar o desvio perceptível, sem alterar a fórmula. O raio de proximidade passou de 55 para 110 e continua somente um aviso. Esses parâmetros são ponto de partida, não exigência de todas as fases.

## Execução reproduzível

Na raiz do projeto, executar `./tests/run.ps1 -Godot <caminho-da-Godot-console>`. A suíte inclui `tests/test_gravidade_issue_13.gd`; também pode ser executado diretamente com `godot --headless --path . --script tests/test_gravidade_issue_13.gd`. Os valores abaixo são impressos pelo teste. Posições são unidades do mundo, velocidades unidades/s e acelerações unidades/s².

| Cenário e esperado | Resultado observado |
| --- | --- |
| Origem isolada em (90,250): centro finito; aceleração dirigida ao corpo e menor a 400 que a 200 unidades | Centro (0,0); a 200: (-1,197126; 0); a 400: (-0,299820; 0). Tolerância numérica 0,0001. |
| Duas fontes no ponto (150,160): soma igual à soma individual, tolerância 0,00001 | Origem (-2,257148; 3,385721), apoio (13,89543; -4,631809), soma (11,63828; -1,246088). |
| Aproximação: nave parada em (290,250), apenas origem, 180 passos; nenhum contato | Posição (284,5331; 250), velocidade (-3,657681; 0); aproximação de 5,4669 unidades. Tolerância de posição 0,02. |
| Rota: partida em (90,222), velocidade inicial (0,-80), corpos da fase; chegar à Terra com desvio lateral maior que 5 | Contato com Terra no passo 128, em (97,80874; 82,69413), velocidade (7,763352; -60,57247); desvio 7,80874. Tempo do passo 2,1333 s, contato ocorre dentro dele. |
| Ampliar o raio de proximidade para 1.000 sem alterar demais parâmetros | A aceleração a 200 unidades permanece igual. |

Resultado: 189 verificações da #13, zero falhas. A suíte completa passou com 849 verificações, incluindo 158 de partida e a comparação da prévia com voo (erro inferior a 0,001 unidade). Cenários de cancelamento simétrico e centro também constam de `tests/test_partida.gd`. O arquivo de log local é `.godot/test_gravidade_issue_13.log`.

O PR propõe o aceite da decisão e da evidência desta issue; a aprovação cabe à revisão. Ergonomia, custo da prévia e validação em aparelho continuam nas #4 e #18, sem assumir que a execução no Windows as resolve. A implementação e os parâmetros podem ser recalibrados mediante registro e novas evidências.
