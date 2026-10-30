# Área segura das configurações na pausa — issue #50

Base `0a70437`, após integração do PR #79. Ao abrir configurações na pausa, a tela era criada dentro da raiz do HUD, já recuada pela área segura. A margem interna das configurações repetia o recuo calculado a partir do viewport inteiro. Isso diminuía o espaço disponível e impedia o fundo de cobrir a tela inteira em aparelhos com recortes/barras.

A tela de configurações agora é filha direta do CanvasLayer do HUD, como irmã da raiz recuada. Assim, o fundo cobre o viewport e a própria tela aplica a área segura uma única vez. A verificação de abertura duplicada acompanha a nova posição. O teste de preferências acessa a tela nessa posição; regras de pausa, volumes e persistência são preservadas.

## Verificação

Godot 4.7.2/Windows: suíte completa com **2.646 verificações aprovadas**. A suíte de áreas dos menus passou de dez para 23 verificações, incluindo fase aberta pelo controlador, configurações na pausa em alturas lógicas 240 e 390, limites exatos da tela/margem, abertura repetida, Voltar acessível por rolagem e preservação de pausa, combustível e área do HUD ao fechar. Os testes de preferências continuam verificando volumes, checkpoint/progresso e pausa após fechar.

O mesmo teste de áreas foi executado com a implementação anterior: **quatro falhas**, correspondentes ao fundo e à margem em ambas as alturas; com a correção, **zero falhas**. O PCK exportado passou em 30 verificações; a suíte de áreas passou nas 23 contra esse pacote isolado no desktop.

Capturas com D3D12 real em Windows, viewport lógico 180×240 e 180×390, janela ampliada duas vezes e área segura simulada `(8,16; 164×altura−32)`. Reproduzir com `godot --path . --script tests/capturar_configuracoes_pausa.gd`; imagens em `.godot/configuracoes-pausa-*.png`.

| Cenário | Evidência |
| --- | --- |
| Tela curta: retorno alcançado por rolagem | [Voltar](evidencias-configuracoes-pausa-2026-10-30/tela-curta-voltar.png) |
| Tela alta: conteúdo dentro de um único recuo | [Configurações](evidencias-configuracoes-pausa-2026-10-30/tela-alta.png) |

Os recortes são simulados; não houve teste Android nesta entrega. Recortes reais, barras do sistema, toque e legibilidade continuam pendentes nas #4/#50. A issue não é encerrada por estas evidências desktop.
