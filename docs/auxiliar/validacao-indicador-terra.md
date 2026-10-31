# Direção da Terra encoberta pela interface — issue #31

Em 31/10/2026, sobre a `alpha` com o PR #85 integrado (`00b10a1`), foi corrigida a indicação de direção quando o centro da Terra fica atrás dos controles. Antes, o HUD verificava apenas o retângulo de combustível/tempo e os limites do viewport inteiro. O botão de pausa, as barras e o painel inferior podiam esconder o destino sem oferecer indicação.

O cálculo passa a usar a área segura aplicada à raiz do HUD e os retângulos visíveis do status, barras, botão de pausa, distância e alertas. Um centro encoberto no topo recebe seta para cima; no painel inferior, para baixo. Um centro fora da área segura recebe a direção correspondente, inclusive diagonal. Espaços livres entre controles não são considerados uma obstrução do topo. A indicação continua baseada no centro do destino; não garante que todo o sprite/rótulo esteja visível e não calcula uma rota de voo.

## Regressão e verificação

Godot 4.7.2, Windows. `tests/test_visual.gd` posiciona a câmera de uma fase real em um SubViewport 180 × 390 para colocar a Terra atrás da pausa, das barras e do botão Reiniciar durante a pausa. Os três casos falharam antes da correção e passaram depois. A suíte também confere recuos da área segura, os limites inferior/direito, indicação diagonal e ausência de seta em área livre.

- Suítes completas: **2.747 verificações, zero falhas**.
- Pacote exportado: **30 verificações, zero falhas**.
- A rota de referência, o custo de um impulso e a vitória permanecem cobertos pela suíte visual e pelas rotas da campanha. Dados físicos e arquivos de fase não foram alterados.

Capturas geradas por `tests/capturar_indicador_terra.gd`, com simulação interrompida e câmera posicionada deliberadamente para reproduzir a sobreposição:

| Caso | Captura |
| --- | --- |
| Terra atrás do botão superior; seta para cima | [Controle superior](evidencias-indicador-terra-2026-10-31/indicador-terra-controle-superior.png) |
| Terra atrás do botão Reiniciar na pausa; seta para baixo | [Painel de pausa](evidencias-indicador-terra-2026-10-31/indicador-terra-painel-pausa.png) |

As capturas são do Windows, na proporção 180 × 390. O teste Android e o relato do usuário registrados no PR #85 antecedem esta correção. A revisão geral de oclusão, leitura dos sprites, ergonomia e validação desta mudança no aparelho continuam pendentes na #31; esta entrega não conclui seu aceite completo.
