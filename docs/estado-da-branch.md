# Estado atual e continuidade do ORBT

Atualizado em 26/10/2026. Fonte de acompanhamento: [Projects ORBT](https://github.com/orgs/EclipseEstudio/projects/1), issues e PRs do [repositório](https://github.com/EclipseEstudio/ORBT). Esta documentação distingue implementação integrada de aceite final.

## Base conferida

O PR #46 foi integrado à main em `a774a824b0a5824c0a049911383253c10b538d10` (22/10/2026 no horário de São Paulo). O checkout analisado está na branch `feat/issue-40-progresso-persistente`, commit `846785b`, cabeça desse PR. Não é uma nova implementação pendente de merge. Antes de desenvolver, atualizar a main e criar uma branch de trabalho sem descartar arquivos locais.

| Entrega | Integração | Estado funcional |
| --- | --- | --- |
| Núcleo, corpos, controles e primeira fase | PR #42, `d0c0cae` | JSON v1, gravidade/contatos, gestos, combustível, prévia, tempo, câmera, HUD, pausa e resultados implementados |
| Editor Godot | PR #43, `45466e2` | Criar/abrir/editar/validar/salvar/testar; carregador comum e teste isolado |
| Seleção/campanha | PR #44, `fcd576b` | Catálogo por ID, bloqueio, liberação, repetição e troca de mundos |
| Identidade visual mínima | PR #45, `6db0abb` | Seis sprites, marcas por função, tema e indicadores; revisão das imagens adiada |
| Progresso persistente | PR #46, `a774a82` | Conclusões/desbloqueios por ID, checksum, temporário, backup, recuperação e retentativa |

O catálogo real em `Recursos/Niveis.json` contém somente `teste_001`. Catálogos de duas/dez fases usados por testes/capturas não são campanha autoral entregue. No desktop há menu mínimo e seleção; no Android a primeira fase abre diretamente. Não há Continuar por checkpoint.

## Critério de status no Projects

- **Backlog:** demanda identificada ainda a detalhar.
- **A Fazer:** escopo definido e pronto para implementação.
- **Em Desenvolvimento:** implementação em andamento.
- **Em Revisão:** implementação integrada, com revisão, decisão de regra ou evidência de aceite pendente. Merge sozinho não conclui o aceite.
- **Concluído:** issue encerrada com evidência do seu escopo; não implica aceite global Android ou de todos os requisitos do GDD.

Na consulta inicial havia 41 issues: 21 encerradas e 20 abertas. Todas as abertas apareciam como A Fazer, apesar de terem implementação. As 20 abertas implementadas foram movidas para Em Revisão no Projects. As descrições originais das issues foram preservadas: o conector recusou edição com HTTP 403 (Resource not accessible by integration). As pendências reconciliadas estão na matriz abaixo e no README do Projects. Responsáveis existentes são preservados; não foram inventados prazos nem atribuídas aprovações humanas.

## Matriz das issues existentes

| Issue | Demanda | Estado de acompanhamento | Pendência / evidência necessária |
| --- | --- | --- | --- |
| [#1](https://github.com/EclipseEstudio/ORBT/issues/1) | Implementar corpos celestes, gravidade e contatos | Em Revisão | Aprovar modelo/tolerâncias (#13) e registrar integração no Android (#4). |
| [#2](https://github.com/EclipseEstudio/ORBT/issues/2) | Criar o editor de fases JSON como plugin da Godot | Em Revisão | Reprodução do ciclo criar/salvar/reabrir/testar por outro integrante (#25). |
| [#3](https://github.com/EclipseEstudio/ORBT/issues/3) | Produzir e integrar a identidade visual mínima em pixel art | Em Revisão | Revisão das imagens adiada; validar legibilidade/paleta/escala no Android e origem da propulsão legada. |
| [#4](https://github.com/EclipseEstudio/ORBT/issues/4) | Integrar e validar a primeira fase funcional no Android | Em Revisão | Gerar APK da revisão integrada; instalar e executar roteiro Android, registrar aparelho, versão, hash, resultados e reprodução por outro integrante. |
| [#5](https://github.com/EclipseEstudio/ORBT/issues/5) | Implementar seleção de fases e acesso à campanha | Em Revisão | Validar navegação pelo polegar (#38) e persistência após reabertura no Android (#40). Dez fases, checkpoints e menus completos são demandas complementares. |
| [#6](https://github.com/EclipseEstudio/ORBT/issues/6) | Implementar controle da nave por toque, mira e impulso | Em Revisão | Validar toque físico, direção/intensidade, cancelamento e desempenho/legibilidade da prévia no Android (#16–#18). |
| [#7](https://github.com/EclipseEstudio/ORBT/issues/7) | Definir propriedades dos corpos celestes no JSON | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#8](https://github.com/EclipseEstudio/ORBT/issues/8) | Definir região de proximidade dos corpos celestes | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#9](https://github.com/EclipseEstudio/ORBT/issues/9) | Definir regiões de contato, captura e perigo | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#10](https://github.com/EclipseEstudio/ORBT/issues/10) | Emitir eventos de proximidade e contato sem duplicação | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#11](https://github.com/EclipseEstudio/ORBT/issues/11) | Calcular o vetor de atração | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#12](https://github.com/EclipseEstudio/ORBT/issues/12) | Aplicar gravidade no passo fixo de física | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |
| [#13](https://github.com/EclipseEstudio/ORBT/issues/13) | Validar e registrar o modelo de gravidade da primeira fase | Em Revisão | Aprovar formalmente modelo gravitacional, parâmetros e tolerâncias; a implementação existe e permanece proposta documentada. |
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
| [#40](https://github.com/EclipseEstudio/ORBT/issues/40) | Respeitar desbloqueio e conclusão das fases | Em Revisão | Demonstrar conclusão/desbloqueio e reabertura real no Android; serviço persistente integrado no PR #46. |
| [#41](https://github.com/EclipseEstudio/ORBT/issues/41) | Abrir a fase selecionada pelo ID e limpar a tentativa anterior | Concluído | Issue encerrada no GitHub; conclusão preservada nesta reconciliação. |

Os itens encerrados foram preservados como registrados no GitHub. As pendências transversais de aparelho e aprovação de regras continuam cobertas pelas issues abertas, especialmente #4/#13/#37. Não reabrir ou encerrar em lote apenas por existir código ou PR integrado.

## Evidências disponíveis

Última execução integrada documentada em 22/10/2026, Godot 4.7.2 / Windows: 69 controles, 142 partida, 32 editor, 31 campanha, 38 visuais, 24 persistência e 23 pacote: **359 verificações aprovadas**. É evidência histórica; os testes não foram reexecutados na reconciliação documental de 26/10. O teste de ciclo do plugin tem registro separado de 12 verificações; não somá-lo novamente às 359.

O APK de 15/10 é anterior às últimas integrações. Pacote PCK executado no desktop não comprova APK atual nem execução Android. [android.md](android.md) mantém o roteiro e o histórico, não um aceite concluído.

## Próximas ações para retomar

1. Atualizar a base main preservando os arquivos locais e conferir alterações posteriores ao PR #46.
2. Priorizar #4: gerar APK da revisão integrada e registrar revisão, hash, modelo/Android/Godot, passos, esperado/observado e evidências. Exercitar também navegação #38 e persistência #40 com pelo menos duas fases autorais.
3. Resolver com a equipe #13/#17/#18/#37: modelo e tolerâncias, direção/intensidade, alcance/custo da prévia, tempo/deriva, contato contra origem, pouso sem combustível e contagem no pouso.
4. Outro integrante reproduz o editor (#2/#25). Revisar arte (#3/#27–#31) quando a revisão adiada for retomada.
5. Próxima implementação recomendada: checkpoints de pouso/fase e retomada (RF17 e parte do RF18). Antes do código, definir quando salvar checkpoint de fase, pouso sem saldo, restauração após derrota e relação com Reiniciar.
6. Expandir campanha até dez fases com solução e revisão por outra pessoa; depois completar menus, dicas, preferências, áudio e narrativa.

## Backlog complementar do GDD

| Frente | Requisito | Situação / próximo passo |
| --- | --- | --- |
| Checkpoints e Continuar | RF17 e parte de RF18 | Ausentes; definir contrato, invalidar estado incompatível, restaurar pausado e sem recarga/cobrança duplicada |
| Preferências e recuperação da tentativa | RF18 | Conclusão/desbloqueio persistem; preferências e tentativa pausada ainda não |
| Menus completos | RF19 | Menu mínimo/campanha existem; configurações/créditos e fluxo completo pendentes |
| Dez fases autorais | RF20 | Uma fase entregue; iniciar segunda fase para progressão real e depois balancear as dez |
| Dicas contextuais | RF21 | Há instruções mínimas no HUD; falta tutorial contextual com playtest |
| Música e efeitos/volumes | RF24 | Duas músicas e volumes separados persistidos pendentes |
| Narrativa | RF25 | Integração de piloto/corporação/retorno e desfecho pendente |
| Rotação/faixa segura/órbitas/portais/infinito | RF26–RF30 | Condicionais; não iniciar sem decisão de escopo e regras |

O GDD local é referência de requisitos, não evidência de funcionalidade. Recomendações acima não representam aprovação de regras ainda abertas.

## Regra de manutenção

A cada entrega, atualizar issue e Projects com implementação, PR, teste e pendência; atualizar este documento quando mudar a situação consolidada. Fechar uma issue somente com seu aceite demonstrado. Registros antigos ficam em [historico-implementacao.md](historico-implementacao.md); guias técnicos mantêm seus contratos e evidências datadas.

Preservar os arquivos locais preexistentes não rastreados: `Recursos/ModelosVisuais/` e `docs/orbt - game design document.md`. O plano temporário da #4 foi substituído por este documento e pelo roteiro Android.
