# Regras da campanha e progressão

Estas regras descrevem o fluxo implementado em 29/10/2026. A seleção e o progresso persistente têm evidências em Windows; o aceite integrado Android permanece pendente. Os contratos de arquivos, serviços e recuperação estão na [documentação técnica da campanha](../tecnica/campanha.md).

## Navegação e tentativas

No computador, **Campanha** abre a seleção de fases. No Android, a primeira fase do catálogo abre diretamente, preservando o fluxo atual do protótipo.

**Seleção de fases**, na interface da partida, permite retornar à campanha durante o jogo, a pausa ou após o desfecho. A tentativa anterior é descartada. A seleção oferece **Atualizar lista**, para reler o conteúdo disponível, e **Voltar ao menu**.

Escolher uma fase começa uma tentativa com posição, combustível, tempo, contatos e câmera iniciais. Repetir uma fase não recupera o voo anterior. Não há comando **Continuar** por checkpoint.

## Acesso, conclusão e repetição

Cada fase apresenta ordem, nome e um dos seguintes estados:

| Estado | Acesso e comportamento |
| --- | --- |
| Bloqueada | Não pode ser aberta. |
| Disponível | Pode ser escolhida para começar uma tentativa. |
| Concluída | Pode ser jogada novamente pela ação **Repetir**. |

A primeira fase da lista é liberada. Vencer conclui a fase e libera a seguinte uma única vez. Repetir uma fase concluída não duplica a liberação, e concluir a última não cria outra fase. Perder ou abandonar uma tentativa não conclui a fase.

As conquistas pertencem à identidade estável da fase. Alterar seu nome, sua ordem ou seu conteúdo mantendo essa identidade não apaga conclusões e desbloqueios. O jogador só pode abrir fases presentes no catálogo atual e liberadas ou concluídas.

Se o catálogo estiver vazio, a seleção informa o estado vazio e permite voltar. Arquivos inválidos impedem apresentar uma campanha parcial; a seleção mostra o diagnóstico. Uma fase com conteúdo inválido também não inicia uma partida incompleta. Após corrigir os arquivos, **Atualizar lista** permite tentar novamente.

## Salvamento e recuperação

Conclusões e desbloqueios são salvos neste aparelho. Fechar completamente e reabrir o jogo restaura esse progresso quando o arquivo salvo é válido. O salvamento da campanha não guarda posição da nave, combustível ou tempo de uma tentativa em andamento.

Se houver falha de gravação, a vitória permanece válida na sessão atual. A interface avisa que o progresso não foi salvo e oferece **Tentar salvar novamente** quando a retentativa é possível. Enquanto o salvamento não tiver sucesso, fechar o aplicativo pode perder essa alteração.

Quando o arquivo principal está inválido, o jogo pode recuperar a última cópia válida. Essa recuperação pode perder a alteração mais recente que não chegou à cópia recuperada. Quando os arquivos disponíveis são inválidos ou usam uma versão incompatível, eles são preservados; o jogo avisa e usa progresso temporário para a sessão, sem sobrescrever automaticamente os arquivos existentes.

## Conteúdo entregue e aceite pendente

O catálogo real contém uma fase. As duas, três ou dez fases usadas em testes e capturas são dados de validação, não uma campanha autoral entregue.

Os quatro critérios de progresso da issue #40 foram demonstrados em Windows em 29/10/2026, incluindo primeira vitória, repetição, bloqueio, restauração e última fase. Consulte o [registro de aceite e evidências](../auxiliar/validacao-issue-40.md) e as [verificações técnicas datadas](../tecnica/campanha.md#evidências-e-aceite-pendente).

No Android, ainda é preciso validar navegação por toque, ergonomia, gravação, reabertura do aplicativo e recuperação de falhas conforme o [roteiro de exportação e aceite](../tecnica/android.md). Checkpoints de pouso, retomada de tentativa em pausa, preferências, dez fases autorais e menus completos permanecem pendentes; a entrega atual cobre a progressão da campanha.
