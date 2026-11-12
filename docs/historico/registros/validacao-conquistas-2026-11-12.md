# Conquistas — validação de 12/11/2026

Revisão: alterações locais sobre `b9180b6`, branch `melhorias/tutorial-campanha-54`. Ambiente: Windows, Godot 4.7.2 stable. Sem commit, exportação ou publicação nesta entrega.

## Comportamento entregue

- O título ORBT abre os créditos por clique/toque ou ativação do botão via teclado, mantendo o visual do título.
- O botão de créditos foi substituído por uma medalha para abrir Conquistas.
- A tela usa fundo de estrelas, tema, ícones pixelados, área segura, cabeçalho com Voltar e lista vertical de cards. Cada card mostra imagem, título, descrição, progresso e cadeado/confirmacão.
- Nove conquistas: 30 amarelas de cada nível (três), marcos de 10/20/30 azuis (três), coleção completa de 30 azuis e vitórias com um único lançamento em 5/10 fases distintas.
- A primeira fase recebeu uma azul no desvio opcional de coleta, totalizando 30 azuis e 90 amarelas. `content_version` passou de 4 para 5; IDs e recordes anteriores continuam válidos.
- O progresso usa esquema 4, lê 1–4 e preserva os recordes anteriores. Saves legados não inventam vitórias com um lançamento. Vitória, estrelas e registro da fase com um lançamento são gravados juntos.
- A contagem considera impulsos efetivamente aplicados, inclusive correções; cancelamentos/pedidos descartados não contam. O checkpoint restaura a contagem de seu trecho; um checkpoint antigo usa contagem desconhecida até reiniciar.

Regras: [campanha e conquistas](../../regras-de-negocio/campanha.md). Contrato: [catálogo e persistência](../../tecnica/campanha.md).

## Testes

`tests/run.ps1` passou: **43 suítes GDScript, 3.476 verificações, zero falhas**, além de **30 verificações PowerShell de atualização Android**. Os números GDScript usam o resumo final de cada suíte, sem duplicar verificações de subprocessos. Logs locais em `.godot/`, incluindo `conquistas-suite-completa.log`.

`test_conquistas.gd` tem 97 verificações: marcos exatos e imediatamente anteriores, fases distintas, replay, reset, IDs fora do catálogo, migração 3→4, gravação agrupada, falha de escrita/retentativa, rejeição de registro inválido, navegação, foco, cards, contagem real de impulsos e validação/restauração de checkpoints. `test_fases.gd` comprova acesso à nova azul com a física e combustível existentes; `test_campanha_30.gd` verifica uma azul em cada fase.

`git diff --check` passou.

## Visual

`tests/capturar_conquistas.gd` gerou capturas com renderização Compatibility/OpenGL. Conferidos menu, créditos pelo título, topo/fim da lista e estados bloqueados/obtidos em 180×240, 180×320 e 180×390. Capturas locais: `.godot/conquistas-*.png`. A lista mantém a largura, permite alcançar o último card e preserva o botão Voltar no cabeçalho.

## Aceite restante

Falta conferir toque, rolagem, recortes e persistência no APK em aparelho real. Não houve exportação de APK nem validação com jogador nesta entrega. As conquistas são indicadores de progresso, sem premiação de recursos ou alteração das metas de desbloqueio.
