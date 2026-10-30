# Balanceamento da campanha — issue #53

Avaliação em 30/10/2026, Windows, Godot 4.7.2, base `2b2fffe` com alterações deste PR. A suíte passou com 1.175 verificações; a rota completa e as alternativas de 8/9 foram executadas por `tests/test_fases.gd`. Para reproduzir a medição, executar `godot --headless --path . --script tests/medir_balanceamento.gd`. O programa usa a mesma simulação da partida e as rotas de referência, repetindo cada etapa com desvios de 0,25° até 4° em cada sentido. Outras etapas permanecem na rota nominal, com reajuste por posição no Labirinto.

O PCK exportado passou em 23 verificações de empacotamento e 490 verificações de rotas executadas no pacote no desktop. O resultado não é teste de APK ou toque em aparelho.

Os valores são as maiores variações consecutivas aprovadas na amostra, não garantias para todas as combinações ou forças. `4` significa pelo menos 4° testados; o primeiro desvio reprovado encerra a busca naquele sentido. Um pouso seguro diferente do planejado é contado como rota de referência não concluída, embora possa permitir outra solução. Isto não mede destreza nem precisão em pixels no Android.

| Fase | Impulsos e destino de cada etapa; saldo final | Margem por etapa: negativa / positiva |
| --- | --- | --- |
| Primeiro impulso | 80, Terra; 4 | 4 / 3,75° |
| Tutorial | 260, Terra; 2 | 2,5 / 0,75° |
| O Estilingue | 260, Terra; 2 | 1 / 1° |
| O Labirinto | 260 apoio 1, 260 apoio 2, 260 Terra; 0 | 0,75 / 1°; 0,75 / 0,25°; 3,25 / 4° |
| O Sol | 260, Terra; 2 | 0,5 / 2° |
| Deriva Final | 260 em voo, 130 Terra; 3 | 2 / 1,75°; 4 / 4° |
| O Contorno | 100 em voo, 80 Terra; 1 | 4 / 3,75°; 4 / 4° |
| Duas Rotas | 100 em voo, 80 Terra; 1 | 4 / 3,75°; 4 / 4° |
| Portas Gêmeas | 100 em voo, 80 Terra; 1 | 4 / 3,75°; 4 / 4° |
| Retorno à Terra | 100 em voo, 80 Terra; 2 | 4 / 3,75°; 4 / 4° |

Os ângulos, passos e pontos de pouso estão na [tabela de rotas](../tecnica/campanha.md#fases-autorais-e-rotas-de-referência). Cada impulso custa uma unidade; a primeira etapa em voo usa 90 passos na Deriva Final e 120 nos quatro mapas finais. As fases 8 e 9 também têm rotas opostas verificadas com ±1° em cada etapa.

## Ajuste e limitações

Nas fases Tutorial, Estilingue e Sol, o raio visual e de colisão da Terra passou de 16 para 32 unidades e o de captura de 16 para 40. Isso ampliou a chegada e tornou o alvo maior visivelmente; as rochas, fontes, combustível e impulso foram preservados. Na rota nominal, as margens eram 0,75/0,75°, 0,5/0,5° e 0,5/0,5°; passaram a 2,5/0,75°, 1/1° e 0,5/2°, respectivamente. Não se alterou o saldo de referência.

O Tutorial ainda pode pousar no apoio com +1°; isso não é derrota. No Sol, −0,75° da rota nominal colide com `asteroide_015`. No Labirinto, +0,5° na segunda etapa falha a rota e −1° termina em recaptura do apoio no terceiro impulso sem combustível. Esses pontos continuam para análise com jogadores: não há evidência suficiente para afirmar que a campanha dispensa precisão excessiva ou que as rotas medidas sejam as únicas soluções.

As três fases alteradas passam de `content_version` 2 para 3. Um checkpoint da versão anterior é recusado com diagnóstico e requer reinício seguro; conclusões e desbloqueios por ID permanecem. A suíte testa essa incompatibilidade.

## Roteiro de revisão cruzada

### Continuidade após PR #74 — rotas recentralizadas

Na base `1833d57`, a rota de referência do Tutorial passou de −14,5° para −15,25° e a do Sol de +11,7° para +12,45°. A varredura de 0,25° mede, respectivamente, margens negativas/positivas de 1,75°/1,5° e 1,25°/1,25°. Os tempos nominais são 99 passos (1,65 s) e 156 passos (2,60 s), com saldo 2 em ambos. As tabelas anteriores registram a medição histórica.

Esta entrega altera as referências de teste e documentação; os mapas e controles do jogador permanecem iguais. A melhora é na margem simétrica comprovada das soluções de referência, sem aumentar a largura física dos corredores. As rotas antigas de ambas as fases e os desvios extras anteriores continuam cobertos.

O teste agora combina desvio negativo, zero e positivo em cada etapa, incluindo combinações intermediárias antes ausentes. Tutorial exige ±1,5° e Sol ±1,25°. Uma tentativa de recentralizar também a segunda etapa do Labirinto ampliou sua margem isolada para ±0,5°, mas falhou em seis combinações da rota completa; foi descartada. O Labirinto conserva os ângulos e tolerâncias anteriores e passa nas 27 combinações de três etapas. Sua limitação de precisão permanece aberta.

Godot 4.7.2/Windows: suíte completa com 1.618 verificações aprovadas, incluindo 879 de rotas; varredura das dez rotas sem falhas nominais. O PCK exportado passou em 23 verificações de recursos e 879 de rotas no desktop. Não houve playtest Android nesta continuidade. A #53 permanece aberta para revisão cruzada e avaliação da precisão exigida em aparelho.

Outro integrante deve usar um APK gerado da revisão aprovada, anotar hash, versão Godot, modelo do aparelho e Android, e percorrer todas as fases em sequência. Para cada fase, registrar tentativas, impulsos e pousos, saldo, dificuldades de mira, esperado/observado e evidências; testar pelo menos as duas alternativas das fases 8/9 e as situações identificadas acima. Os ângulos do registro são do impulso: o arraste no jogo é na direção oposta. O fluxo de duas correções usa tempo de voo como orientação; a pessoa deve poder testar outras soluções legítimas sem depender de passos exatos.

O resultado automatizado é evidência parcial. Revisão por outro integrante, rota prática no aparelho, equilíbrio e conclusão sem precisão excessiva continuam pendentes na #53. A comparação da composição com o GDD também continua pendente na #52.
