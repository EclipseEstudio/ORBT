> Registro histórico. Descreve a revisão testada à época; consulte a [documentação atual](../../../README.md) para o comportamento vigente.

# Efeitos de voo — 05/11/2026

Implementação das três decisões aprovadas: rastro com espessura constante na tela, zoom congelado durante qualquer contato de mira e proximidade usando todos os corpos não-portal, incluindo a Terra.

| Captura | O que conferir |
| --- | --- |
| [Força baixa](mira-fraca.png) | Linha fina e predominantemente ciano; guia reta de comprimento fixo |
| [Força média](mira-media.png) | Gradiente alcança amarelo/laranja e a espessura aumenta |
| [Força máxima](mira-maxima.png) | Linha de 3 pixels lógicos; ponta e anel de saturação vermelhos |
| [Rastro em voo](rastro-voo.png) | Rota real após 70 passos de 1/60 s; cauda transparente e ponta ciano, atrás da nave |
| [Exploração](exploracao.png) | Zoom manual preservado; controles disponíveis sem mira |
| [Pausa](pausa.png) | Rastro limpo, sem trecho congelado atrás do diálogo |

Capturas reais da Godot 4.7.2 no Windows, renderizador Compatibility/OpenGL em Intel UHD Graphics, viewport lógico 180×320 e escala inteira 3×. Reproduzir com `tests/capturar_efeitos_voo.gd`. Usa a fase `teste_001` sem alterar seus dados autorais e desativa dicas somente na captura para facilitar a inspeção.

O rastro usa `Line2D`, buffer circular de 32 pontos de mundo e amostragem a 30 Hz, somente em voo/deriva com velocidade mínima de 8 unidades/s. A largura é de 2 pixels lógicos compensada pelo zoom, sem antialias. Pouso, baixa velocidade, pausa, perda de foco, reinício, parada e teleporte limpam o histórico.

O zoom varia entre 0,75× e 1,4× da base autoral, suavizado exponencialmente após a apresentação inicial. A distância é calculada até a superfície mais próxima, usando o maior raio visual/físico, normalizada pelo raio de proximidade. Exploração salva/restaura o zoom de voo e permite controle manual.

Validação: 56 verificações em `test_efeitos_voo.gd` cobrem intensidade/impulso, cores e larguras, monotonicidade/limites, Terra e portais, congelamento durante o toque, suavização independente da taxa de quadros, exploração, ordem/capacidade do buffer, espessura, deriva e limpeza. `test_portais.gd` também verifica a limpeza num teleporte real. A suíte completa passou com 3.041 verificações Godot, incluindo subprocessos, mais 14 verificações PowerShell de atualização Android e 31 do pacote exportado em ambiente isolado: 3.086 ao todo, sem falhas. As seis capturas foram inspecionadas.

APK local: `build/android/ORBT-0.3.2-qa.apk`, versão 0.3.2 / código 5, pacote `com.eclipseestudio.orbt`, certificado permanente e permissão de vibração verificados. SHA-256: `cf3cf47ce9e176edce22cb7ade175431566951f6ab731fe13908eb47eec271cc`. Inclui também os ajustes anteriores de preferências, atualização e consumo de oxigênio. Não foi publicado nesta etapa. Desempenho e conforto do zoom no aparelho Android ainda dependem de teste físico.
