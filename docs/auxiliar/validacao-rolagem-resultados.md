# Rolagem da pausa e dos resultados — issue #51

Base `8f7f63f`, após integração do PR #82. O rodapé da partida crescia conforme a mensagem e o número de ações. Em telas curtas, pausa e resultados podiam cobrir o status ou ultrapassar a área segura quando o conteúdo era alto.

O rodapé agora usa um ScrollContainer com largura limitada à tela e sem rolagem horizontal. Na pausa e nos resultados, sua altura é limitada ao espaço abaixo do status, dentro da raiz segura do HUD; mensagens e ações ficam alcançáveis por rolagem. O conteúdo cabe sem rolagem quando há espaço. Durante o jogo, o rodapé mantém a altura do conteúdo e ignora entrada fora dos botões, preservando o gesto sobre as dicas. Nenhuma ação, mensagem autoral ou regra da partida foi alterada.

## Verificação

Godot 4.7.2/Windows: suíte completa com **2.725 verificações aprovadas**, incluindo 47 de layout dos resultados. O PCK exportado passou em 30 verificações gerais e nas mesmas 47 verificações de layout executadas externamente no desktop.

`tests/test_layout_resultados.gd` abre a última fase pelo controlador e testa pausa, derrota com mensagem extensa de teste e vitória final em viewports 180×240 e 180×390, com recortes simulados. Confere rodapé dentro da área segura, ausência de sobreposição com o status, alcance de cada botão por rolagem, tempo/combustível preservados e pausa mantida. Também injeta toque/cancelamento sobre o texto durante o jogo, comprovando que a nova estrutura não captura esse gesto. As comparações dos limites dos botões toleram erro de transformação inferior a 0,01 unidade lógica.

Capturas D3D12 reais em janela 360×480, viewport lógico 180×240 e área segura simulada `(8,16; 164×208)`. Progresso temporário em memória permite abrir a última fase; dados reais e arquivos autorais são preservados. Reproduzir com `godot --path . --script tests/capturar_layout_resultados.gd`; saídas em `.godot/resultados-*.png`.

- [Ações da pausa após rolagem](evidencias-resultados-2026-10-30/pausa-acoes.png).
- [Desfecho e ações quando cabem no painel](evidencias-resultados-2026-10-30/desfecho.png).

Em uma tela curta pode ser necessário rolar entre a mensagem e as ações; todas são verificadas individualmente no teste. Não houve aparelho Android conectado nesta entrega. Toque, legibilidade e recortes reais continuam pendentes nas #4/#51; capturas e testes desktop não encerram esse aceite.
