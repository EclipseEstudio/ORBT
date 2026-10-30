# Regras da campanha e progressão

Estas regras descrevem o fluxo implementado em 29/10/2026. A seleção e o progresso persistente têm evidências em Windows; o aceite integrado Android permanece pendente. Os contratos de arquivos, serviços e recuperação estão na [documentação técnica da campanha](../tecnica/campanha.md).

## Navegação e tentativas

No menu, **Campanha** abre a seleção de fases no computador e no Android. **Continuar** aparece quando há checkpoint válido e recupera a tentativa pausada. O menu também oferece configurações e créditos.

**Seleção de fases**, na interface da partida, permite retornar à campanha durante o jogo, a pausa ou após o desfecho. A tentativa anterior é descartada. A seleção oferece **Atualizar lista**, para reler o conteúdo disponível, e **Voltar ao menu**.

Escolher uma fase começa uma tentativa com posição, combustível, tempo, contatos e câmera iniciais. Repetir uma fase não recupera o voo anterior; **Continuar** recupera o checkpoint salvo.

## Acesso, conclusão e repetição

Cada fase apresenta ordem, nome e um dos seguintes estados:

| Estado | Acesso e comportamento |
| --- | --- |
| Bloqueada | Não pode ser aberta. |
| Disponível | Pode ser escolhida para começar uma tentativa. |
| Concluída | Pode ser jogada novamente pela ação **Repetir**. |

A primeira fase da lista é liberada. Vencer conclui a fase e libera a seguinte uma única vez. Repetir uma fase concluída não duplica a liberação, e concluir a última não cria outra fase. Perder ou abandonar uma tentativa não conclui a fase.

Quando uma atualização acrescenta fases depois de uma já concluída, a próxima é liberada ao carregar ou atualizar o catálogo, preservando o progresso anterior. As fases seguintes continuam bloqueadas até as próximas vitórias.

As conquistas pertencem à identidade estável da fase. Alterar seu nome, sua ordem ou seu conteúdo mantendo essa identidade não apaga conclusões e desbloqueios. O jogador só pode abrir fases presentes no catálogo atual e liberadas ou concluídas.

Se o catálogo estiver vazio, a seleção informa o estado vazio e permite voltar. Arquivos inválidos impedem apresentar uma campanha parcial; a seleção mostra o diagnóstico. Uma fase com conteúdo inválido também não inicia uma partida incompleta. Após corrigir os arquivos, **Atualizar lista** permite tentar novamente.

## Salvamento e recuperação

Conclusões e desbloqueios são salvos neste aparelho. Fechar completamente e reabrir o jogo restaura esse progresso quando o arquivo salvo é válido. O salvamento da campanha não guarda posição da nave, combustível ou tempo de uma tentativa em andamento.

Se houver falha de gravação, a vitória permanece válida na sessão atual. A interface avisa que o progresso não foi salvo e oferece **Tentar salvar novamente** quando a retentativa é possível. Enquanto o salvamento não tiver sucesso, fechar o aplicativo pode perder essa alteração.

Quando o arquivo principal está inválido, o jogo pode recuperar a última cópia válida. Essa recuperação pode perder a alteração mais recente que não chegou à cópia recuperada. Quando os arquivos disponíveis são inválidos ou usam uma versão incompatível, eles são preservados; o jogo avisa e usa progresso temporário para a sessão, sem sobrescrever automaticamente os arquivos existentes.

## Conteúdo entregue e aceite pendente

O catálogo contém dez fases: a original, cinco mapas baseados no protótipo Python `dev-macb/orbt` e quatro mapas novos. Os mapas adaptados começam com a nave parada no espaço e três unidades de combustível, exceto **Deriva Final**, que começa com cinco. Os novos também começam em posição livre, com três unidades, ou quatro no retorno final. A gravidade e o tempo de voo passam a atuar após o primeiro impulso. A dica aparece enquanto a nave aguarda o lançamento ou está pousada.

| Ordem | Fase | Proposta |
| --- | --- | --- |
| 1 | Primeiro impulso | Rota inicial até a Terra com gravidade. |
| 2 | Tutorial | Contornar ou pousar no satélite central e alcançar a Terra à direita. |
| 3 | O Estilingue | Cruzar o corredor entre dois planetas e um satélite. |
| 4 | O Labirinto | Usar os satélites para atravessar os muros de asteroides. |
| 5 | O Sol | Contornar a estrela e passar pelos portões rochosos. |
| 6 | Deriva Final | Cruzar o campo dos dois sóis e corrigir o voo até a Terra. |
| 7 | O Contorno | Desviar de uma rocha e corrigir a direção. |
| 8 | Duas Rotas | Escolher contorno superior ou inferior. |
| 9 | Portas Gêmeas | Escolher uma passagem lateral ao redor de duas rochas. |
| 10 | Retorno à Terra | Combinar correção em voo e atração de dois planetas. |

**Explorar mapa** mostra a visão geral dos mapas maiores; **Voltar à nave** restaura o enquadramento de voo e o controle de lançamento. Os círculos dos planetas e sóis indicam proximidade e permanecem visíveis nesses mapas. O contato fatal com o Sol ocorre na superfície da estrela; seu anel maior é um aviso.

Nos cinco mapas adaptados, composição, muros e combustível seguem o modelo. Os corpos permanecem parados; órbitas e o portal opcional do protótipo não estão implementados. As quatro fases novas reutilizam perigos, correção e gravidade já conhecidos: a sétima é mais simples depois dos mapas densos; a oitava oferece duas rotas, a nona prolonga o obstáculo e a décima combina desvio com fontes gravitacionais. Dificuldade e legibilidade ainda precisam de playtest na #53.

Os quatro critérios de progresso da issue #40 foram demonstrados em Windows em 29/10/2026, incluindo primeira vitória, repetição, bloqueio, restauração e última fase. Consulte o [registro de aceite e evidências](../auxiliar/validacao-issue-40.md) e as [verificações técnicas datadas](../tecnica/campanha.md#evidências-e-aceite-pendente).

No Android, ainda é preciso validar navegação por toque, ergonomia, gravação, reabertura do aplicativo e recuperação de falhas conforme o [roteiro de exportação e aceite](../tecnica/android.md). A campanha de dez fases e sua revisão cruzada permanecem nas #52/#53.
