# Áreas seguras e rolagem dos menus — #50/#51

Base `1604781`, após integração do PR #77 aprovado. O menu principal usava uma coluna central de tamanho mínimo, sem rolagem; configurações e créditos usavam a tela inteira sem descontar recortes e barras do Android. Conteúdo alto ou avisos longos podiam ultrapassar a área utilizável.

O menu principal agora contém uma margem segura e uma coluna com rolagem vertical, com narrativa e ações existentes. Configurações também permitem rolar até os volumes e Voltar. Créditos mantêm título e Voltar fora da rolagem do texto, dentro da área segura. As três telas se reajustam ao redimensionar e consultam a área segura durante a execução Android, inclusive quando as configurações são abertas na pausa. O fundo das telas de configurações/créditos continua preenchendo o viewport.

`src/Visual/area_segura_menu.gd` centraliza a conversão física→lógica antes usada no HUD, preservando o cálculo e o método público do HUD. As ações, persistência e regras da partida são preservadas. Os caminhos dos controles nos testes acompanham a nova estrutura do menu; os testes de preferências localizam os volumes pelo nome em vez da posição na árvore.

## Evidências e limites

Godot 4.7.2/Windows: suíte completa com 2.621 verificações aprovadas, incluindo dez de áreas dos menus; PCK exportado com 30 verificações de recursos e execução da primeira fase. A suíte das áreas dos menus também passou nas dez verificações contra o PCK isolado no desktop.

`tests/test_areas_menus.gd` usa viewport de 180×240 e área segura lógica simulada `(8,16; 164×208)`. Dez verificações conferem limites, rolagem exclusivamente vertical no menu, acesso ao reinício com aviso longo, acesso a configurações, volumes, Voltar e adaptação dos créditos ao redimensionar para 180×390. A suíte também conserva os testes de diagnóstico, narrativa, checkpoint, preferências e configurações na pausa.

Capturas feitas com D3D12 real em Windows, com viewport lógico de 180×240 e janela 360×480. A área segura foi simulada; não são capturas de Android. Reproduzir com `godot --path . --script tests/capturar_menus.gd`. As imagens ficam em `.godot/menu-*.png`.

| Cenário | Captura |
| --- | --- |
| Aviso de checkpoint em tela curta | [Início do menu](evidencias-menus-2026-10-30/diagnostico.png) |
| Ação de reinício após rolagem | [Reiniciar](evidencias-menus-2026-10-30/reiniciar.png) |
| Configurações | [Volumes](evidencias-menus-2026-10-30/configuracoes.png) |
| Configurações após rolar | [Voltar acessível](evidencias-menus-2026-10-30/configuracoes-voltar.png) |
| Créditos com título e retorno fixos | [Créditos](evidencias-menus-2026-10-30/creditos.png) |

Os recortes reais, mudanças das barras do sistema, gesto de rolagem pelo polegar e legibilidade em aparelho continuam pendentes nas #4/#50/#51. Os testes simulados não concluem esse aceite.
