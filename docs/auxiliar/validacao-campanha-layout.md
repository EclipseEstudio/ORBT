# Seleção de fases com avisos longos — issue #38

Base `bc7361e`, após integração do PR #78. O cabeçalho, a descrição do progresso e os diagnósticos ficavam fora da rolagem dos cartões. Em uma tela curta, esses textos podiam ocupar o espaço da lista e empurrar as ações para fora da área segura.

A campanha agora rola cabeçalho, avisos e cartões no mesmo conteúdo. Tentar salvar novamente, Atualizar lista e Voltar ao menu ficam no rodapé. O espaço disponível para cartões deixa de depender da altura dos avisos. A lista usa o cálculo compartilhado de área segura dos menus e acompanha o foco; não há rolagem horizontal.

Uma falha de abertura traz o diagnóstico para a tela. A retentativa de salvamento traz seu resultado para a tela; o deslocamento aguarda a atualização das alturas dos containers. Atualizar o catálogo retorna ao início da lista. IDs, bloqueio, repetição, progresso e abertura única são preservados. Alvos de Jogar/Repetir continuam com altura mínima de 48 unidades lógicas.

## Validação

Godot 4.7.2/Windows: suíte completa com **2.633 verificações aprovadas**, incluindo 12 de layout da campanha. O PCK exportado passou em 30 verificações e nos mesmos 12 testes de layout executados externamente contra o pacote isolado, no desktop.

`tests/test_campanha_layout.gd` usa viewport 180×240 com área segura lógica `(8,16; 164×208)`, dez itens, nome longo e descrições/diagnósticos extensos. Confere rodapé dentro da área segura, espaço para o botão de 48 unidades, quebra de linha, acesso ao último cartão, abertura única pelo ID, nova tentativa após falha, visibilidade dos avisos e lista vazia. Salvamento é simulado em memória; o teste não reproduz falha física de armazenamento.

Capturas com D3D12 real em janela 360×480, usando viewport lógico 180×240 e recortes simulados. Catálogo e nomes são alterados somente em memória para montar o cenário; arquivos autorais e progresso real são preservados. Reproduzir com `godot --path . --script tests/capturar_campanha_layout.gd`; saídas em `.godot/campanha-*.png`.

| Cenário | Evidência |
| --- | --- |
| Aviso longo com ações fixas | [Avisos](evidencias-campanha-layout-2026-10-30/avisos.png) |
| Último botão alcançado por rolagem | [Décima fase](evidencias-campanha-layout-2026-10-30/decima-fase.png) |
| Nome longo quebrado em linhas | [Nome longo](evidencias-campanha-layout-2026-10-30/nome-longo.png) |
| Falha de abertura trazida para a tela | [Diagnóstico](evidencias-campanha-layout-2026-10-30/erro-abertura.png) |

Em telas curtas, o cartão pode precisar de rolagem para alternar entre nome/estado e botão. A validação pelo polegar, recortes reais e legibilidade no Android continua pendente na #38/#4. Os testes e capturas desktop não encerram esse aceite.
