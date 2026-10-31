# Estado atual e continuidade do ORBT

Atualizado em **31/10/2026**, após a revisão das [issues](https://github.com/EclipseEstudio/ORBT/issues), dos PRs integrados até **#86** e do [Projects ORBT](https://github.com/orgs/EclipseEstudio/projects/1). Base de código: `alpha` em `487b68e`. Esta página substitui as contagens e recomendações anteriores; o detalhamento está na [auditoria de 31/10](revisao-issues-2026-10-31.md).

## Situação reconciliada

| Situação | Quantidade | Significado |
| --- | ---: | --- |
| Concluídas | 17 | 13 encerradas nesta revisão por critérios demonstrados e 4 encerramentos anteriores preservados. |
| Em Revisão | 34 | Implementação integrada; falta teste específico, reprodução humana, aprovação de conteúdo ou decisão de regra. |
| Total de issues planejadas | 51 | Inclui seis tarefas principais e suas tarefas detalhadas/complementares. |

**Não há nova implementação priorizada por esta revisão.** As 34 abertas não são 34 funcionalidades a construir. Antes de alterar código, ligar o trabalho a uma issue existente, um critério pendente e um problema reproduzido ou decisão explícita.

Concluídas: [#7](https://github.com/EclipseEstudio/ORBT/issues/7), [#11](https://github.com/EclipseEstudio/ORBT/issues/11), [#13](https://github.com/EclipseEstudio/ORBT/issues/13), [#19](https://github.com/EclipseEstudio/ORBT/issues/19), [#21](https://github.com/EclipseEstudio/ORBT/issues/21), [#24](https://github.com/EclipseEstudio/ORBT/issues/24), [#32](https://github.com/EclipseEstudio/ORBT/issues/32), [#34](https://github.com/EclipseEstudio/ORBT/issues/34), [#35](https://github.com/EclipseEstudio/ORBT/issues/35), [#36](https://github.com/EclipseEstudio/ORBT/issues/36), [#39](https://github.com/EclipseEstudio/ORBT/issues/39), [#40](https://github.com/EclipseEstudio/ORBT/issues/40), [#41](https://github.com/EclipseEstudio/ORBT/issues/41), [#48](https://github.com/EclipseEstudio/ORBT/issues/48), [#49](https://github.com/EclipseEstudio/ORBT/issues/49), [#50](https://github.com/EclipseEstudio/ORBT/issues/50), [#57](https://github.com/EclipseEstudio/ORBT/issues/57).

## Critério de status no Projects

- **Backlog:** demanda identificada ainda sem escopo detalhado.
- **A Fazer:** escopo aprovado e pronto para implementação, com critério e resultado esperado identificados.
- **Em Desenvolvimento:** trabalho autorizado em execução.
- **Em Revisão:** implementação integrada com evidência, revisão humana ou decisão ainda pendente.
- **Concluído:** critérios próprios demonstrados e issue encerrada; não equivale ao aceite global do Android.

Responsáveis, prioridades, estimativas e redação dos critérios foram preservados. Aprovação de um PR não foi usada para inventar aprovação subjetiva de arte, narrativa, ergonomia ou regras. O relatório distingue a evidência aceita de cada encerramento.

## Entregas integradas

| Frente | Entregas na alpha | Pendência delimitada |
| --- | --- | --- |
| Núcleo, corpos e nave | JSON v1, gravidade aceita na #13, contatos, estados, gestos, combustível, prévia, câmera e HUD (#42/#58) | Casos de fronteira/alertas, comparação de taxas, decisões de contato/tempo e Android (#8–#18/#20/#37). |
| Editor | Criar/editar/validar/salvar/testar, cópia autoral, rascunho e ciclo do plugin (#43) | Recarga de script, inspeção visual e reprodução por outro integrante (#22/#23/#25/#26). |
| Seleção/progresso | Catálogo por ID, bloqueio, liberação, persistência, troca e repetição (#44/#46/#47) | Operação pelo polegar e textos/avisos no aparelho (#38). |
| Checkpoints e preferências | Snapshots, persistência, recuperação, diagnóstico e retentativas (#59–#61/#72–#74/#80/#82/#84) | Roteiro integrado Android e retentativa adicional podem ser exercitados na #4; #48/#49/#50 concluídas no próprio escopo. |
| Menus | Campanha, Configurações, Créditos, Continuar, pausa/resultados, áreas seguras, Voltar e rolagem (#62/#78–#83) | Última fase, derrota/checkpoint, créditos e navegação física restantes (#51). |
| Campanha e tutorial | Dez fases, rotas/alternativas, margens, Labirinto v3 e tutorial contextual (#63–#65/#75/#76) | Aprovar composição, jogar as dez fases em aparelho com revisão cruzada e testar com jogador não autor (#52–#54). |
| Arte, áudio e narrativa | Sprites, propulsão em código, duas músicas/seis efeitos e proposta narrativa (#45/#66/#67/#70/#71/#77/#86) | Aprovação visual no aparelho, escuta e aprovação dos textos (#27–#31/#55/#56). |
| Exportação | APK automático para PRs à alpha, validação e artefato; importação limpa corrigida (#68/#85) | Manutenção; não recriar pipeline nem usar geração do APK como aceite Android. |

A propulsão de origem não identificada foi substituída na produção no PR #77; os arquivos legados preservados estão excluídos do pacote. Sua autoria não foi determinada, mas a antiga pendência não exige refazer a solução já integrada.

## Evidência e limites

Após o PR #87, a continuidade da #4 executou no Samsung SM-A556E/Android 16, em instalação QA independente, cancelamento, suspensão com mira/voo, exploração/recentralização, contato contra origem, último combustível com vitória e derrotas por limite/asteroide/tempo. [Passos, capturas e limites](validacao-roteiro-android-2026-10-31.md). Os hashes dos saves principais permaneceram iguais. O usuário confirmou os quatro testes físicos: cancelamento com uma mão, segundo dedo sem disparo extra, Home durante mira com retomada sem lançamento e abertura da fase em modo avião. São resultados relatados, sem captura adicional do agente. Nenhuma issue foi encerrada nesta etapa e não houve implementação nova.

A auditoria executou **2.747 verificações das suítes**, sem falhas, em Godot 4.7.2/Windows. A cópia limpa importou sem erros e o ciclo do plugin passou em dois processos separados, 11 verificações em cada. A primeira execução no workspace teve mensagens de UID do cache local e não foi usada como evidência de execução limpa.

No Samsung SM-A556E/Android 16 há [testes de 30/10](validacao-android-2026-10-30.md) e [teste breve de 31/10](validacao-android-2026-10-31.md): início, impulso/vitória, pouso intermediário, recuperação, corrupção/incompatibilidade, interrupção instrumentada da escrita, Configurações e Voltar. O usuário relatou que o jogo funciona; isso não detalha todos os cenários físicos ainda abertos. A mudança do indicador da Terra no PR #86 tem testes/capturas Windows e aguarda aparelho.

## Próximas ações dentro do planejamento

1. Executar os casos restantes do [roteiro Android](../tecnica/android.md), vinculando resultados a #4/#16–#18/#38/#51.
2. Outro integrante reproduz o editor conforme [manual](guia-editor-de-fases.md), cobrindo #2/#22/#23/#25/#26.
3. Revisar composição e jogar as dez fases (#52/#53), registrando problemas concretos antes de recalibrar.
4. Testar tutorial com jogador não autor (#54), revisar arte (#27–#31), escutar áudio (#55) e aprovar narrativa (#56).
5. Encerrar cada issue somente com os seus critérios demonstrados; atualizar o Projects junto do encerramento.

Órbitas, rotação/faixa angular segura, portais, modo infinito, reputação e ferramentas avançadas de edição continuam condicionais e **não foram colocados em A Fazer**. A comparação de composição/narrativa com o GDD permanece pendente porque a referência não estava disponível nesta cópia.

## Manutenção e histórico

A [revisão de 31/10](revisao-issues-2026-10-31.md) contém a lista individual das 51 tarefas, PRs, evidências e pendências. [Revisão de 30/10](revisao-issues-2026-10-30.md), [histórico](historico-implementacao.md) e [plano temporário](plano-temporario-issue-4.md) são consultas históricas; não executar suas recomendações antigas como tarefas novas.

Preservar os arquivos locais preexistentes não rastreados em `Recursos/ModelosVisuais/` e `Recursos/Fases/fase_teste.json`. Nenhum foi incorporado à auditoria.
