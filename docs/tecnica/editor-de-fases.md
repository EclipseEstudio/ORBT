# Plugin ORBT Fases

Fonte: `addons/orbt_editor/`. Manual de operação: [guia do editor](../guias/editor-de-fases.md).

| Arquivo | Responsabilidade |
| --- | --- |
| `plugin.cfg`, `plugin.gd` | Registro/habilitação, tela principal e execução do preview |
| `documento.gd` | Dados autorais, seleção, inserção/exclusão, duplicação, undo/redo e validação |
| `painel.gd` | Ações, diálogos, propriedades e rascunho |
| `mapa.gd` | Viewport 2D, seleção, arraste, zoom, raios e avisos geométricos |
| `teste.gd`, `teste.tscn` | Cena de execução isolada pelo carregador comum |

Scripts de edição usam `@tool`. O documento preserva dados JSON autorais; normalização física fica em `CarregadorFase`. A seleção distingue fase, Terra, corpos e estrelas. Alterações ficam no histórico e um rascunho local permite recuperar a sessão.

Salvar valida, escreve temporário e renomeia. Trocar de documento com alterações pede salvar/descartar/cancelar. Testar grava `.godot/orbt-editor-preview.json`, valida e instancia o nível, sem serviço de progresso real. Jogo e editor compartilham o contrato, sem carregador paralelo.

O painel suporta planetas, estações, sóis, asteroides e portais; satélite é apenas compatibilidade do carregador. Estrelas têm edição/mapa próprios. Tanques são campos da fase; nebulosa pode exigir JSON direto. A ausência de controle dedicado não significa ausência do recurso no jogo.

Os raios e as órbitas desenhados são inspeção inicial, não prova de rota ou segurança ao longo do movimento. Desativar o plugin não deve afetar o jogo; o preset exclui `addons/orbt_editor/*`.

Testes: `tests/test_editor.gd`, `test_editor_estrelas.gd` e `run_editor_plugin.ps1`. O harness cobre integração real no editor; reprodução humana por outro integrante continua necessária para avaliar o fluxo de autoria.
