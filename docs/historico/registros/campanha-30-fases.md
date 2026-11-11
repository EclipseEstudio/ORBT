> Registro histórico. Descreve a revisão testada à época; consulte a [documentação atual](../../README.md) para o comportamento vigente.

# Campanha de 30 fases

## Progressão e recursos

Três níveis de dez fases. O segundo exige as 30 douradas das primeiras dez fases; o terceiro exige as 60 douradas acumuladas das primeiras vinte fases. Cada dezena deve estar completa para avançar. As azuis são opcionais. Uma carga por impulso, independentemente da força; pousar conserva oxigênio, mas não repõe combustível. Todos os tanques fornecem exatamente +1. Coletas são confirmadas ao alcançar a Terra.

| # | Fase | Combustível inicial + coletável | Oxigênio | Foco |
|---|---|---|---|---|
| 1 | Primeiro impulso | 5 | 30 s | Mira e lançamento |
| 2 | Mira aberta | 3 | 25 s | Intensidade e primeira azul |
| 3 | Passagem larga | 3 | 25 s | Abertura entre pequenos asteroides |
| 4 | Primeiro pouso | 4 | 25 s | Estação intermediária |
| 5 | Segundo impulso | 4 +1 | 25 s | Correção em voo e tanque |
| 6 | Escalas em rotação | 5 | 25 s | Rotação de apoio |
| 7 | Escala no desvio | 4 | 25 s | Desvio, pouso e decolagem |
| 8 | Corredor de retorno | 4 +1 | 25 s | Velocidade acumulada |
| 9 | Curva gravitacional | 3 | 25 s | Atração planetária |
| 10 | Rasante solar | 3 | 25 s | Gravidade e perigo solar |
| 11 | Estação em movimento | 4 | 25 s | Interceptação orbital |
| 12 | Janela orbital | 3 | 25 s | Partida de apoio móvel |
| 13 | O Contorno | 4 | 20 s | Desvio com menos tempo |
| 14 | Duas Rotas | 4 +1 | 20 s | Caminhos e reabastecimento |
| 15 | Pouso de precisão | 5 | 25 s | Faixas seguras de pouso |
| 16 | Travessia orbital | 4 | 25 s | Órbita entre rochas |
| 17 | Arco entre rochas | 3 | 25 s | Gravidade com poucos impulsos |
| 18 | Três escalas | 6 +1 | 25 s | Pousos sucessivos |
| 19 | Cinturão em movimento | 4 | 25 s | Obstáculo orbital |
| 20 | Última manobra | 6 +1 | 25 s | Síntese do segundo nível |
| 21 | Fenda no Espaço | 3 | 25 s | Primeiro par de portais |
| 22 | Salto entre Rochas | 3 | 25 s | Portal atravessando cinturão |
| 23 | Névoa Cega | 4 | 25 s | Primeira nebulosa |
| 24 | Rota no Escuro | 4 | 25 s | Nebulosa e gravidade |
| 25 | Desvio Nebuloso | 3 +1 | 20 s | Desvio até tanque e escalas |
| 26 | Portal Invisível | 3 | 20 s | Portal localizado pelos instrumentos |
| 27 | Órbita Cega | 4 | 25 s | Nebulosa e planeta em rotação |
| 28 | Rede de Portais | 4 +1 | 25 s | Dois pares e atração solar |
| 29 | Travessia Extrema | 4 +1 | 20 s | Nebulosa, portal, asteroide orbital e tanque |
| 30 | O Grande Retorno | 5 +1 | 25 s | Nebulosa, rotação, estação orbital e dois pares |

## Visibilidade e apresentação

A nebulosa das fases 23, 24, 25, 26, 27, 29 e 30 limita a visão ao redor da nave em coordenadas de mundo. O zoom do mapa reduz proporcionalmente o círculo; mover a câmera não revela regiões novas. Fora do raio a máscara é completamente opaca. A bússola da Terra fica fixa no HUD; instrumentos mostram rumo e distância dos tanques restantes e dos dois portais mais próximos. São leituras de rádio, sem imagens dos obstáculos.

O título aparece centralizado durante 1,8 s e desaparece em 0,7 s. Depois vem a dica, quando habilitada, fechada pelo botão OK. As fases antigas mantêm seus IDs, preservando o progresso; fases com obstáculos modificados recebem nova versão de conteúdo para invalidar checkpoints incompatíveis.

As rochas grandes foram substituídas por grupos de pequenos asteroides de massa zero, inteiramente contidos nas áreas dos obstáculos originais. Isso também foi aplicado às fases de exemplo fora da campanha. Os novos obstáculos não recebem gravidade.

## Verificação reproduzível

Usar Godot 4.7.2 com `--headless --path . --script res://tests/<arquivo>`:

- `test_fases.gd`: rotas econômicas, coleta completa e tolerância de mira das vinte fases originais após a fragmentação.
- `test_campanha_30.gd`: tabela oficial de recursos, estrelas, geometria, progressão, todas as dez rotas novas, tanques acessíveis, saltos, nebulosa e tempo de apresentação.
- `test_portais.gd`: validação dos pares, teletransporte, conservação da rapidez, ausência de salto repetido, pausa e reinício.
- `test_campanha_layout.gd` e `test_estrelas_ui.gd`: seleção e estrelas em telas pequenas.
- `test_revisao_jogabilidade.gd`: integração das regras de progresso, recursos e catálogo.

Executar `capturar_campanha30.gd` com renderização `gl_compatibility` para checar pixels dentro/fora da máscara no voo e no mapa, além de gerar capturas de título e seleção em `.godot/`.

As rotas testemunha de coleta das fases 25, 29 e 30 usam respectivamente 4, 5 e 6 impulsos, coletando o tanque; terminam com aproximadamente 2,13 s, 1,92 s e 1,20 s de oxigênio e combustível zero. Sem o tanque essas mesmas rotas falham. Isso valida a viabilidade e a pressão de recursos do percurso proposto, sem afirmar que nenhuma rota mais econômica possa ser descoberta por jogadores.

Os testes verificam a física e a disponibilidade dos recursos. A dificuldade percebida, os tempos de reação e a orientação na névoa ainda devem ser acompanhados em testes com jogadores.

## Ferramentas de autoria

`node scripts/estruturar_campanha_30.mjs` recria as fases 21–30 e fragmenta as rochas das fases existentes. Em seguida, `scripts/calibrar_nivel3.gd` simula as rotas e posiciona as estrelas das fases novas que ainda não possuem estrelas. Essa recriação sobrescreve a autoria das fases novas; não executar sobre alterações manuais sem revisão. Para fragmentar apenas obstáculos existentes, usar `--somente-obstaculos`.
