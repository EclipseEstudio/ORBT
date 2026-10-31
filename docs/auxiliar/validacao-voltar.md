# Botão Voltar e Escape — issue #51

Base `cc449e9`, após integração do PR #80. O projeto não tratava o pedido nativo de Voltar. A saída automática da Godot foi desativada em `application/config/quit_on_go_back`; o controlador agora recebe `NOTIFICATION_WM_GO_BACK_REQUEST` e aplica o fluxo abaixo. Escape usa o mesmo fluxo, sem sair do aplicativo desktop no menu principal.

| Contexto | Resultado |
| --- | --- |
| Configurações abertas no menu ou na pausa | Fecha somente configurações, pelo mesmo método de Voltar; mantém volumes e estado da partida. |
| Créditos abertos | Fecha créditos e mantém menu. |
| Seleção de fases | Abre menu principal. |
| Fase jogando | Pausa e cancela gesto/pedidos pendentes sem cobrar impulso. |
| Fase já pausada | Mantém pausa; Retomar continua sendo explícito. |
| Resultado de vitória/derrota | Abre campanha, libera mundo anterior e preserva progresso. |
| Menu principal sem tela auxiliar | Voltar nativo encerra o aplicativo; Escape mantém o menu desktop. |

O processamento de Voltar é adiado e limitado a uma ação por quadro. Repetições de Escape são ignoradas; pedidos durante a abertura de uma fase são ignorados. O controlador recebe entrada durante a pausa, enquanto Mundo e Interface preservam o processamento pausável; nave, propulsão e efeitos da simulação não passam a executar por herança durante a pausa.

## Verificação

Godot 4.7.2/Windows: `tests/run.ps1` passou com 2.664 verificações, incluindo 18 de Voltar. O PCK exportado passou em 30 verificações gerais e 17 de navegação executadas com `tests/test_voltar.gd -- --sem-subprocesso`. A saída em processo separado é validada somente na suíte do checkout; os testes não fazem parte do pacote.

`tests/test_voltar.gd` injeta a notificação nativa e eventos Escape em Windows, cobrindo telas auxiliares, repetição, campanha, lançamento pendente, posição/tempo/combustível, animação pausada, retomada explícita e resultados. A saída no menu é exercitada em processo separado com limite de um segundo: o pedido precisa encerrar o processo antes do limite. Nenhuma notificação foi produzida por um botão físico Android nesta entrega.

Capturas D3D12 reais no desktop, com notificações injetadas pelo script `tests/capturar_voltar.gd`:

- [Menu após Voltar da campanha](evidencias-voltar-2026-10-30/menu-apos-campanha.png).
- [Partida ainda pausada após fechar configurações por Voltar](evidencias-voltar-2026-10-30/pausa-apos-fechar.png).

Reproduzir com `godot --path . --script tests/capturar_voltar.gd`; saídas em `.godot/voltar-*.png`. O roteiro Android ainda deve verificar botão/gesto nativo, abertura/fechamento das telas, pausa e saída no menu principal. #4/#51 permanecem abertas para essa validação física.

Referência da API: [SceneTree.quit_on_go_back](https://docs.godotengine.org/en/stable/classes/class_scenetree.html#class-scenetree-property-quit-on-go-back) e [notificação de Voltar em Node](https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-constant-notification-wm-go-back-request).
