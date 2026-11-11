# Plugin ORBT Fases

Fonte: `addons/orbt_editor/`. Manual de operação: [guia do editor](../guias/editor-de-fases.md).

| Arquivo | Responsabilidade |
| --- | --- |
| `plugin.cfg`, `plugin.gd` | Registro/habilitação, tela principal e execução do preview |
| `documento.gd` | Dados autorais, seleção, inserção/exclusão, duplicação, undo/redo e validação |
| `painel.gd` | Ações, diálogos, propriedades e rascunho |
| `mapa.gd` | Viewport 2D, seleção, arraste, zoom, raios e avisos geométricos |
| `teste.gd`, `teste.tscn` | Cena de execução isolada pelo carregador comum |

Scripts de edição usam `@tool`. O documento preserva dados JSON autorais; normalização física fica em `CarregadorFase`. A seleção distingue fase, Terra, corpos, estrelas e tanques. A lista associa cada item à seleção por metadados. Os índices antigos de estrelas são preservados nos rascunhos; tanques usam uma faixa separada após o limite de 256 estrelas. Alterações ficam no histórico e um rascunho local permite recuperar a sessão.

Salvar valida, escreve temporário e renomeia. Trocar de documento com alterações pede salvar/descartar/cancelar. Testar grava `.godot/orbt-editor-preview.json`, valida e instancia o nível, sem serviço de progresso real. Jogo e editor compartilham o contrato, sem carregador paralelo.

O painel suporta planetas, estações, sóis, asteroides e portais; satélite é apenas compatibilidade do carregador. Estrelas e tanques têm inserção, seleção, arraste, edição, duplicação e exclusão próprios. Tanques continuam serializados em `fuel_pickups`, com carga inteira de 1 a 100. Inserção e duplicação respeitam os limites do carregador para os arrays de coletáveis.

As propriedades da fase oferecem ativação de nebulosa e raio de visão entre 45 e 300 unidades. Ativar cria `nebula.visibility_radius` com 120; desativar remove `nebula`. Ambas as ações participam do histórico. O mapa desenha o alcance inicial como referência e deixa a fase visível para autoria. A máscara de visão continua sendo executada pela cena comum de nível no preview.

O mapa usa as funções da simulação para mostrar corpos orbitais e faixas em `start.time_seconds`, no mesmo instante da nave inicial. Seleção/arraste usam a posição exibida; o documento aplica a transformação orbital inversa ao gravar a posição autoral, preservando centro/período/sentido. Arrastar a nave pousada move seu apoio; início livre altera apenas `start.position`. Os arrastes participam do histórico em um único grupo.

O controle de rotação consulta o carregador para refletir o giro efetivo quando os dados são válidos. Desligar grava `rotation.degrees_per_second: 0` em vez de remover `rotation`, preservando `initial_degrees` e evitando reativar os padrões de planetas/Terra. A leitura dos padrões não modifica o JSON autoral.

Os raios e as órbitas desenhados são inspeção inicial, não prova de rota ou segurança ao longo do movimento. Desativar o plugin não deve afetar o jogo; o preset exclui `addons/orbt_editor/*`.

Testes: `tests/test_editor.gd`, `test_editor_estrelas.gd`, `test_editor_recursos.gd` e `run_editor_plugin.ps1`. A suíte do editor cobre giro desligado, posições no tempo inicial e arrastes de nave/apoio, incluindo histórico e salvamento; com renderização, confere pixels de uma faixa em órbita e rotação. A suíte de recursos cobre controles e arraste de tanques, nebulosa, histórico, salvamento/reabertura, preview e rascunho. O harness cobre integração real no editor e, com renderização, captura os controles de tanque e nebulosa; reprodução humana por outro integrante continua necessária para avaliar o fluxo de autoria.
