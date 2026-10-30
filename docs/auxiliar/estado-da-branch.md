# Estado atual e continuidade do ORBT

Atualizado em 30/10/2026. Fonte de acompanhamento: [Projects ORBT](https://github.com/orgs/EclipseEstudio/projects/1), issues e PRs do [repositório](https://github.com/EclipseEstudio/ORBT). Esta documentação distingue implementação integrada de aceite final.

## Base conferida

O PR #47 integrou à `alpha` as entregas dos PRs #42–#46 e a documentação, no commit `bc2d2e4`. A integração reúne a base anteriormente publicada na `main` em `a774a824b0a5824c0a049911383253c10b538d10` (22/10/2026 no horário de São Paulo) e os documentos da `alpha` em `09cb305`. Os testes de aceite da #40 estão em `2dc4b5b`; os quatro critérios foram demonstrados no Windows, conforme [registro de execução](validacao-issue-40.md).

| Entrega | Integração | Estado funcional |
| --- | --- | --- |
| Núcleo, corpos, controles e primeira fase | PR #42, `d0c0cae` | JSON v1, gravidade/contatos, gestos, combustível, prévia, tempo, câmera, HUD, pausa e resultados implementados |
| Editor Godot | PR #43, `45466e2` | Criar/abrir/editar/validar/salvar/testar; carregador comum e teste isolado |
| Seleção/campanha | PR #44, `fcd576b` | Catálogo por ID, bloqueio, liberação, repetição e troca de mundos |
| Identidade visual mínima | PR #45, `6db0abb` | Seis sprites, marcas por função, tema e indicadores; revisão das imagens adiada |
| Progresso persistente | PR #46, `a774a82` | Conclusões/desbloqueios por ID, checksum, temporário, backup, recuperação e retentativa |

O catálogo real em `Recursos/Niveis.json` contém dez fases: a original, cinco mapas adaptados de `dev-macb/orbt/src/levels/__init__.py` e quatro novos mapas. Os IDs anteriores foram preservados, com corpos estáticos e rotas verificadas na Godot; órbitas e portal opcional permanecem fora desta adaptação. Saves da campanha anterior liberam a sucessora sem perder conclusões. Catálogos temporários de testes/capturas continuam separados desse conteúdo. O menu inicial é usado também no Android, com Campanha, configurações, créditos e Continuar quando houver checkpoint válido.

## Critério de status no Projects

- **Backlog:** demanda identificada ainda a detalhar.
- **A Fazer:** escopo definido e pronto para implementação.
- **Em Desenvolvimento:** implementação em andamento.
- **Em Revisão:** implementação integrada, com revisão, decisão de regra ou evidência de aceite pendente. Merge sozinho não conclui o aceite.
- **Concluído:** issue encerrada com evidência do seu escopo; não implica aceite global Android ou de todos os requisitos do GDD.

Na consulta de 26/10 havia 41 issues: 21 encerradas e 20 abertas. Todas as abertas apareciam como A Fazer, apesar de terem implementação. As 20 abertas implementadas foram movidas para Em Revisão no Projects. Naquela reconciliação, as descrições originais foram preservadas porque o conector recusou edição com HTTP 403 (Resource not accessible by integration). Em 29/10, a #40 recebeu evidência dos quatro critérios para encerramento. As pendências restantes estão na matriz abaixo. Responsáveis existentes são preservados; não foram inventados prazos nem atribuídas aprovações humanas.

## Matriz das issues existentes

| Issue | Demanda | Estado de acompanhamento | Pendência / evidência necessária |
| --- | --- | --- | --- |
| [#1](https://github.com/EclipseEstudio/ORBT/issues/1) | Implementar corpos celestes, gravidade e contatos | Em Revisão | Aprovar modelo/tolerâncias (#13) e registrar integração no Android (#4). |
| [#2](https://github.com/EclipseEstudio/ORBT/issues/2) | Criar o editor de fases JSON como plugin da Godot | Em Revisão | Reprodução do ciclo criar/salvar/reabrir/testar por outro integrante (#25). |
| [#3](https://github.com/EclipseEstudio/ORBT/issues/3) | Produzir e integrar a identidade visual mínima em pixel art | Em Revisão | Revisão das imagens adiada; validar legibilidade/paleta/escala no Android e origem da propulsão legada. |
| [#4](https://github.com/EclipseEstudio/ORBT/issues/4) | Integrar e validar a primeira fase funcional no Android | Em Revisão | APK integrado gerado em 29/10; instalar e executar roteiro Android, incluindo persistência após reabertura; registrar aparelho, versão, hash, resultados e reprodução por outro integrante. |
| [#5](https://github.com/EclipseEstudio/ORBT/issues/5) | Implementar seleção de fases e acesso à campanha | Em Revisão | Validar navegação pelo polegar (#38) e integração em aparelho (#4). Dez fases, checkpoints e menus completos são demandas complementares. |
| [#6](https://github.com/EclipseEstudio/ORBT/issues/6) | Implementar controle da nave por toque, mira e impulso | Em Revisão | Validar toque físico, direção/intensidade, cancelamento e desempenho/legibilidade da prévia no Android (#16–#18). |
| [#7](https://github.com/EclipseEstudio/ORBT/issues/7) | Definir propriedades dos corpos celestes no JSON | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#8](https://github.com/EclipseEstudio/ORBT/issues/8) | Definir região de proximidade dos corpos celestes | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#9](https://github.com/EclipseEstudio/ORBT/issues/9) | Definir regiões de contato, captura e perigo | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#10](https://github.com/EclipseEstudio/ORBT/issues/10) | Emitir eventos de proximidade e contato sem duplicação | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#11](https://github.com/EclipseEstudio/ORBT/issues/11) | Calcular o vetor de atração | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#12](https://github.com/EclipseEstudio/ORBT/issues/12) | Aplicar gravidade no passo fixo de física | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#13](https://github.com/EclipseEstudio/ORBT/issues/13) | Validar e registrar o modelo de gravidade da primeira fase | Concluído | PR #58 aprovado e integrado; decisão e cenários registrados em [validação da #13](validacao-issue-13.md). Android segue na #4. |
| [#14](https://github.com/EclipseEstudio/ORBT/issues/14) | Criar cenários de teste de gravidade, proximidade e contato | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#15](https://github.com/EclipseEstudio/ORBT/issues/15) | Organizar a nave e implementar vínculo de pouso | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#16](https://github.com/EclipseEstudio/ORBT/issues/16) | Controlar o ciclo do toque e o cancelamento pela zona morta | Em Revisão | Executar cancelamento, multitouch, GUI, suspensão e retomada com toque físico no Android. |
| [#17](https://github.com/EclipseEstudio/ORBT/issues/17) | Calcular direção e intensidade a partir do arraste | Em Revisão | Aprovar direção livre oposta ao arraste e calibrar intensidade/ergonomia no Android. |
| [#18](https://github.com/EclipseEstudio/ORBT/issues/18) | Exibir círculo de cancelamento e prévia de trajetória | Em Revisão | Validar alcance/tolerância, legibilidade e custo da prévia no Android. |
| [#19](https://github.com/EclipseEstudio/ORBT/issues/19) | Aplicar impulsos e controlar o consumo de combustível | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#20](https://github.com/EclipseEstudio/ORBT/issues/20) | Reproduzir os controles de toque com mouse para desenvolvimento | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#21](https://github.com/EclipseEstudio/ORBT/issues/21) | Criar a estrutura ativável do plugin de edição | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#22](https://github.com/EclipseEstudio/ORBT/issues/22) | Criar a cena de edição @tool sem executar a partida | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#23](https://github.com/EclipseEstudio/ORBT/issues/23) | Visualizar corpos, Terra e regiões físicas na viewport | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#24](https://github.com/EclipseEstudio/ORBT/issues/24) | Inserir, selecionar, mover e excluir objetos no editor | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#25](https://github.com/EclipseEstudio/ORBT/issues/25) | Editar propriedades e abrir/salvar fases JSON no plugin | Em Revisão | Outro integrante deve reproduzir edição, salvar/reabrir, alterações pendentes e retorno do teste sem alterar dados autorais. |
| [#26](https://github.com/EclipseEstudio/ORBT/issues/26) | Validar e testar a fase pelo carregador comum | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#27](https://github.com/EclipseEstudio/ORBT/issues/27) | Definir inventário e padrões dos recursos visuais | Em Revisão | Aprovar paleta/grade/escala no aparelho; inventário e fontes já estão integrados. |
| [#28](https://github.com/EclipseEstudio/ORBT/issues/28) | Criar o sprite legível e orientado da nave | Em Revisão | Aprovar orientação e leitura da nave no tamanho real, pouso/mira/voo no Android. |
| [#29](https://github.com/EclipseEstudio/ORBT/issues/29) | Criar sprites dos apoios, perigos e Terra | Em Revisão | Aprovar distinção entre apoio, perigo e Terra no Android e revisar autoria/licença da propulsão legada na entrega audiovisual. |
| [#30](https://github.com/EclipseEstudio/ORBT/issues/30) | Organizar variações de cor preservando contraste e função | Em Revisão | Aprovar as duas variações de apoio em tela real preservando identificação sem depender só da cor. |
| [#31](https://github.com/EclipseEstudio/ORBT/issues/31) | Integrar sprites e indicadores sem alterar a física | Em Revisão | Capturar mira/pouso/alerta/derrota no Android; validar margens, oclusão e leitura sem alterar física. |
| [#32](https://github.com/EclipseEstudio/ORBT/issues/32) | Definir e documentar o formato JSON das fases | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#33](https://github.com/EclipseEstudio/ORBT/issues/33) | Carregar e validar JSON para construir a fase | Em Revisão | Demonstrar carregamento offline no Android com os arquivos empacotados. |
| [#34](https://github.com/EclipseEstudio/ORBT/issues/34) | Posicionar a nave no apoio inicial e criar a Terra | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#35](https://github.com/EclipseEstudio/ORBT/issues/35) | Detectar saída dos limites do mundo | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#36](https://github.com/EclipseEstudio/ORBT/issues/36) | Detectar chegada à Terra e concluir a tentativa | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#37](https://github.com/EclipseEstudio/ORBT/issues/37) | Controlar estados, temporizador, desfechos e reinício da partida | Em Revisão | Registrar aceite das regras de tempo/deriva/pouso sem saldo/origem e demonstrar pausa/reinício/desfechos no Android. |
| [#38](https://github.com/EclipseEstudio/ORBT/issues/38) | Criar a tela de seleção de fases para uso pelo polegar | Em Revisão | Validar navegação pelo polegar, nomes longos, margens seguras e alvos de toque no Android. |
| [#39](https://github.com/EclipseEstudio/ORBT/issues/39) | Gerar cartões pelo catálogo de fases e progresso | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#40](https://github.com/EclipseEstudio/ORBT/issues/40) | Respeitar desbloqueio e conclusão das fases | Concluído | Quatro critérios demonstrados em 29/10 no Windows, com controlador reaberto em outro processo, vitória idempotente, repetição e última fase. Serviço persistente integrado no PR #46; [evidência](validacao-issue-40.md). Aceite integral Android permanece em #4/#38. |
| [#41](https://github.com/EclipseEstudio/ORBT/issues/41) | Abrir a fase selecionada pelo ID e limpar a tentativa anterior | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |

Os itens encerrados foram preservados como registrados no GitHub. As pendências transversais de aparelho e aprovação de regras continuam cobertas pelas issues abertas, especialmente #4/#13/#37. Não reabrir ou encerrar em lote apenas por existir código ou PR integrado.

## Evidências disponíveis

Execução integrada em 29/10/2026, Godot 4.7.2 / Windows: 69 controles, 142 partida, 32 editor, 31 campanha, 38 visuais, 28 persistência, nove reabertura em processo separado, 23 pacote e 11 ciclo do plugin: **383 verificações aprovadas**. Revisão, passos, resultados e saída estão no [aceite da #40](validacao-issue-40.md). O histórico de 22/10 permanece nos guias.

O APK de 29/10 foi gerado da revisão `846785b`, cujo conteúdo de jogo coincide com a `main` integrada em `a774a82`; assinatura e alinhamento foram verificados. Pacote PCK executado no desktop não comprova execução Android. [android.md](../tecnica/android.md) mantém hash, roteiro e histórico; instalação e teste em aparelho ainda pendentes.

## Próximas ações para retomar

1. #13 concluída pelo PR #58; manter o integrador compartilhado e o registro dos cenários ao recalibrar. A integração do PR #47 e a correção de mira `19af5c8` já ocorreram.
2. Priorizar #4: a [validação parcial Android de 30/10](validacao-android-2026-10-30.md) demonstrou instalação, primeira fase e recuperação do checkpoint inicial com comandos de toque. Exercitar toque físico, navegação #38 e persistência após reabertura, incluindo checkpoint intermediário e outras fases.
3. Resolver com a equipe #13/#17/#18/#37: modelo e tolerâncias, direção/intensidade, alcance/custo da prévia, tempo/deriva, contato contra origem, pouso sem combustível e contagem no pouso.
4. Outro integrante reproduz o editor (#2/#25). Revisar arte (#3/#27–#31) quando a revisão adiada for retomada.
5. #48 integrada pelo PR #59, #49 pelo PR #60 e #50 pelo PR #61; validar persistência e preferências em aparelho. #51 implementa menus e resultados para revisão; preservar o progresso existente.
6. #52 acrescentou quatro fases; revisar composição contra o GDD. A #53 registra [rotas, margens e ajustes parciais](balanceamento-issue-53.md); faltam playtest por outro integrante e validação em aparelho. A #54 adicionou tutorial contextual; playtest pendente. A #55 integrou áudio; escuta em aparelho pendente. A #56 propõe narrativa para revisão da equipe. O pipeline #57 foi integrado no PR #68 e passou na primeira execução.

A [revisão das issues de 30/10](revisao-issues-2026-10-30.md) detalha implementação parcial e pendências de #13/#48/#49/#51/#52/#53. Os recursos locais fora do catálogo (`Recursos/Fases/fase_teste.json` e `Recursos/ModelosVisuais/`) foram preservados fora desta entrega. O APK histórico não inclui as alterações de 30/10.

## Backlog complementar do GDD

Continuidade sobre `1833d57` (PR #74 integrado): a #53 recentraliza as rotas de referência de Tutorial e Sol e amplia os testes para combinar desvios negativos, zero e positivos. Suíte Windows: 1.618 verificações aprovadas. Evidências e limites em [balanceamento](balanceamento-issue-53.md#continuidade-após-pr-74--rotas-recentralizadas). Labirinto e playtest por outro integrante em aparelho continuam pendentes; mapas e física preservados.

| Frente | Requisito | Situação / próximo passo |
| --- | --- | --- |
| Checkpoints e Continuar | RF17 e parte de RF18 | #48 integrada; #49 implementa persistência, diagnóstico e Continuar pausado. Aceite Android pendente; menus completos na #51 |
| Preferências e recuperação da tentativa | RF18 | Checkpoint e preferências persistidos separadamente; validação em aparelho pendente |
| Menus completos | RF19 | Créditos e ações de pausa/resultados na #51; revisão e validação de toque em aparelho pendentes |
| Dez fases autorais | RF20 | Dez fases e rotas automatizadas na #52; balancear e revisar a campanha inteira na #53 |
| Dicas contextuais | RF21 | Tutorial contextual da primeira fase implementado na #54; revisão e playtest em aparelho pendentes |
| Música e efeitos/volumes | RF24 | Volumes separados na #50; duas músicas e efeitos sintetizados na #55, sujeitos a revisão e escuta em aparelho |
| Narrativa | RF25 | Piloto, corporação e mensagens propostas na #56; aprovação da equipe, GDD e legibilidade em aparelho pendentes |
| Rotação/faixa segura/órbitas/portais/infinito | RF26–RF30 | Condicionais; não iniciar sem decisão de escopo e regras |

O GDD local é referência de requisitos, não evidência de funcionalidade. Recomendações acima não representam aprovação de regras ainda abertas.

## Regra de manutenção

A cada entrega, atualizar issue e Projects com implementação, PR, teste e pendência; atualizar este documento quando mudar a situação consolidada. Fechar uma issue somente com seu aceite demonstrado. Registros antigos ficam em [historico-implementacao.md](historico-implementacao.md); guias técnicos mantêm seus contratos e evidências datadas.

Preservar os arquivos locais preexistentes não rastreados: `Recursos/ModelosVisuais/` e `docs/orbt - game design document.md`. O plano temporário da #4 foi substituído por este documento e pelo roteiro Android.
