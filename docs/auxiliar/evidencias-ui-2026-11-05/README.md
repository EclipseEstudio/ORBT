# Interface e voo — 05/11/2026

Godot 4.7.2 / Windows. Capturas reais pelo renderizador Compatibility/OpenGL 3.3, Intel UHD Graphics. As imagens usam escala inteira 3× e não receberam edição. A altura no nome corresponde à resolução lógica; a largura lógica é sempre 180 px.

| Tela | 240 px | 320 px | 390 px |
| --- | --- | --- | --- |
| Splash Eclipse Estudio | [imagem](splash-240.png) | [imagem](splash-320.png) | [imagem](splash-390.png) |
| Menu principal | [imagem](menu-240.png) | [imagem](menu-320.png) | [imagem](menu-390.png) |
| Configurações | [imagem](configuracoes-240.png) | [imagem](configuracoes-320.png) | [imagem](configuracoes-390.png) |
| Créditos | [imagem](creditos-240.png) | [imagem](creditos-320.png) | [imagem](creditos-390.png) |
| Seleção com cinco colunas | [imagem](fases-240.png) | [imagem](fases-320.png) | [imagem](fases-390.png) |
| Fase e HUD | [imagem](gameplay-240.png) | [imagem](gameplay-320.png) | [imagem](gameplay-390.png) |
| Mira com força saturada | [imagem](mira-forca-240.png) | [imagem](mira-forca-320.png) | [imagem](mira-forca-390.png) |
| Pausa | [imagem](pausa-240.png) | [imagem](pausa-320.png) | [imagem](pausa-390.png) |
| Oxigênio esgotado | [imagem](fim-de-jogo-240.png) | [imagem](fim-de-jogo-320.png) | [imagem](fim-de-jogo-390.png) |

Para reproduzir, executar a Godot com `--path . --rendering-method gl_compatibility --rendering-driver opengl3 --script tests/capturar_ui.gd -- 320`. Trocar o último argumento por 240 ou 390 para as demais alturas. O script salva em `.godot/ui-*.png`; copiar cada conjunto antes da próxima altura. O teste `tests/test_hud_voo.gd` cobre fonte e acentos, posições do HUD, bússola com zoom, linha de força, um gesto/uma carga, deriva até oxigênio zero e impulsos sem recarga do oxigênio. `tests/test_partida.gd` também verifica vitória usando a última carga.

Na execução inicial, a suíte parou em `test_portais.gd`. A execução individual identificou a mesma falha de compilação em três testes: `test_editor.gd`, `test_inicio_livre.gd` e `test_portais.gd`, todos dependentes de `addons/orbt_editor/documento.gd:113` (tipo da variável `primeiro` não inferido). Esses arquivos do editor já tinham alterações locais e foram preservados. As demais verificações foram executadas individualmente para conferir regressões além desse bloqueio.

As capturas foram revisadas para título e ações do menu, borda e navegação das configurações, cartões, ícones centralizados, legibilidade dos acentos, combustível/barra separados do rodapé e indicação de saturação da mira. Não foi realizado teste em aparelho Android nesta entrega.

Resultado final: **26 das 29 suítes do checkout passaram**, com **2.847 verificações**. As três suítes bloqueadas são as mesmas da execução inicial. O [resumo por suíte](verificacao.json) também registra **31 verificações de exportação aprovadas**, executadas contra `build/android/ORBT-ui-20261105.pck` em uma pasta isolada: **2.878 verificações aprovadas no total**. O pacote inclui a fonte e sua licença e exclui as referências visuais; o caminho opcional `fundo_menu.png` é permitido. Esse PCK serve à verificação desktop e não é um APK instalável.

O empacotamento ainda emitiu o erro preexistente do plugin do editor; a verificação independente do PCK passou. Para manter os arquivos temporários desta execução dentro do projeto, `APPDATA`, `LOCALAPPDATA`, `TEMP` e `TMP` foram redirecionados somente no processo de exportação para subpastas de `.godot/`. A configuração do sistema não foi alterada.

Ajuste posterior dos cabeçalhos: Configurações e Créditos agora seguem Fases, com seta de voltar de 28 × 28 px à esquerda, título em maiúsculas ao lado e margem de 8 px. O cabeçalho permanece fora da rolagem. As capturas dessas duas telas foram atualizadas nas três alturas. Passaram 133 verificações nos testes de áreas dos menus, retentativa de preferências, menus, HUD e voltar. O PCK acima corresponde à implementação anterior a esse ajuste dos cabeçalhos.

Preparação da versão 0.3.1 alpha: com a inclusão autorizada das alterações do editor, a variável `primeiro` passou a declarar o tipo `int`, eliminando o bloqueio de compilação. O teste de preferências foi atualizado para o novo cabeçalho, e a suíte inteira passou. O editor também passou nove verificações novas de desfazer/refazer, arraste agrupado, duplicação e ligação de pares de portais. A verificação atualizada do pacote exportado passou nas 31 verificações. O [resumo por suíte](verificacao.json) registra os resultados finais desta preparação e substitui os bloqueios históricos acima.
