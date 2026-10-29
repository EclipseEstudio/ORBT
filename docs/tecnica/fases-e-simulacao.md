# Fases e simulação — contrato de protótipo v1

Implementado em 14/10/2026 para integrar #15–#20 às dependências #7–#14 e #32–#37. Este documento registra o contrato JSON, a arquitetura e a resolução determinística da simulação. O comportamento esperado pelo jogador está nas [regras de jogabilidade](../regras-de-negocio/jogabilidade.md). As escolhas do protótipo continuam sujeitas ao aceite da equipe e à calibração no Android; o GDD original permanece preservado.

## Formato e validação

`Recursos/Niveis.json` mapeia IDs estáveis para caminhos `res://Recursos/Fases/*.json`. Não é mais um agrupamento de fases embutidas. O antigo cadastro global `CorposEstelares.json` foi migrado para a lista de corpos de cada fase, permitindo dois corpos do mesmo tipo com propriedades distintas.

O arquivo `Recursos/Fases/teste_001.json` é o exemplo executável. `CarregadorFase.carregar(caminho)` e `CarregadorFase.validar(dados)` retornam `{nivel, erros}`; `nivel` só é preenchido quando todos os campos e relações são válidos. Esse validador é o contrato comum do jogo e do [editor de fases](editor-de-fases.md). A suíte `tests/test_partida.gd` constrói exemplos inválidos a partir do exemplo válido.

| Campo | Tipo, unidade e regra |
| --- | --- |
| `schema_version` | Número inteiro, exatamente 1; nenhuma migração implícita |
| `content_version`, `order` | Inteiros positivos até 1.000.000 |
| `id`, `name` | Textos obrigatórios não vazios; ID único no catálogo |
| `bounds.position`, `bounds.size` | Vetores `[x,y]`; dimensão positiva. Centro da nave determina saída; borda exata ainda pertence ao mundo |
| `initial_fuel` | Inteiro entre 1 e 1.000.000; único campo físico com padrão autoral: 5 |
| `flight_timeout` | Número de segundos entre 0,01 e 3.600; exemplo usa 30 |
| `physics.gravity_constant` | G entre 0 e 1.000; exemplo usa 1 |
| `physics.softening` | Suavização entre 1 e 10.000 unidades de mundo; exemplo usa 8 |
| `ship.radius`, `ship.mass` | Números entre 0,01 e 1.000; exemplo: raio 8 e massa 1 |
| `ship.dead_zone`, `ship.max_drag` | Unidades lógicas do viewport, entre 0,01 e 1.000; máximo maior que zona morta; exemplo 10/80 |
| `ship.max_impulse` | Impulso entre 0,01 e 1.000; exemplo 80. Variação de velocidade = impulso / massa da nave |
| `start.body_id` | Referência a planeta/satélite seguro |
| `start.angle_degrees` | Ângulo entre −360 e 360; zero aponta à direita, −90 para cima |
| `goal` | Objeto com os campos de corpo abaixo, sem necessidade de `type`; sempre Terra |
| `bodies` | Lista de corpos com IDs distintos entre si e distintos da Terra |
| `tutorial`, `notes` | Textos opcionais de autoria; separados das regras físicas |

Coordenadas ficam entre −1.000.000 e 1.000.000. Números devem ser finitos; booleanos e textos não são números. Grandezas de mundo são unidades convencionais do jogo (apresentadas como metros na interface), não uma simulação astronômica em escala real. Combustível é uma contagem abstrata.

Cada corpo exige:

| Campo | Regra |
| --- | --- |
| `id` | Texto não vazio e único |
| `type` | `planet`, `satellite`, `sun` ou `asteroid`; `earth` é reservado para `goal` |
| `position` | `[x,y]` no mundo |
| `mass` | 0 a 1.000.000; asteroide e Terra exigem zero |
| `visual_radius` | Positivo até 1.000.000; altera somente o desenho |
| `collision_radius` | Positivo até 1.000.000; superfície física |
| `capture_radius` | 0 a 1.000.000; apoios/Terra exigem valor ≥ colisão; perigos exigem zero |
| `danger_radius` | 0 a 1.000.000; Sol/asteroide exigem valor ≥ colisão; apoios/Terra exigem zero |
| `proximity_radius` | Positivo até 1.000.000 e pelo menos o raio de contato; não altera gravidade |

O validador rejeita arquivo ausente/malformado, versão incompatível, campos inválidos, IDs duplicados, referência inicial inválida, nave inicial fora dos limites ou dentro de outro contato, Terra fora dos limites e interseção entre zonas de contato expandidas pelo raio da nave. Isso previne contatos ambíguos no conteúdo autoral. A resolução física também tem desempate determinístico para cenários sintéticos. Parâmetros de movimento, rotação e portais não são implementados nesta versão.

O recurso validado mantém uma cópia dos dados autorais. Cada nave recebe uma cópia das fontes; posição, velocidade, combustível, gestos e tempo ficam no estado da tentativa. A simulação não escreve no JSON e não produz saves/checkpoints.

## Modelo físico e decisão de arquitetura

A fórmula adotada para teste de #13 é a candidata do GDD:

```text
r_i = posição da fonte i − posição da nave
a = soma(G × massa_i × r_i / (|r_i|² + epsilon²)^(3/2))
v_nova = v + a × dt
p_nova = p + v_nova × dt
```

Usa-se Euler semi-implícito, a 60 passos fixos/s, sem amortecimento ou frenagem gratuita. A aceleração não é multiplicada pela massa da nave. O impulso é dividido por essa massa exatamente uma vez. Apenas os corpos com massa positiva atraem; gravitação mútua e movimento dos corpos não são simulados.

Nave e corpos agora são `Node2D`, com atualização explícita em `SimulacaoVoo`. Isso evita misturar a integração nativa de `RigidBody2D` com outra física de previsão. Sprites, fogo e RCS foram preservados; a orientação da nave em voo é visual e não altera a direção livre do impulso. O pouso preserva orientação radial e posição relativa no apoio estático.

Contato é testado no segmento do passo, contra círculos expandidos pelo raio da nave. A captura usa o maior entre raio de colisão e captura; perigos usam o raio fatal. O contato mais cedo vence. Para frações iguais dentro de `1e-6`: perigo antes de Terra antes de apoio. Saída dos limites vence empate com contato. Colisão ocorre no segmento mesmo se a nave atravessaria todo o corpo em um único passo.

Ao sair da origem, a captura é ignorada somente se a nave está fora da superfície sólida e o movimento aponta para fora. Um impulso para dentro produz contato imediato, sem imunidade temporal à colisão. O consumo já confirmado não é revertido pelo contato; o resultado segue as [regras de pouso e combustível](../regras-de-negocio/jogabilidade.md#combustível-pouso-e-deriva).

## Pedidos de impulso e estado da tentativa

- Cada pedido carrega um ID monotônico. Repetições são rejeitadas antes e depois da aplicação, inclusive após reinício. Cancelar a mira não gera pedido; cancelar outro gesto no mesmo passo preserva um lançamento já solicitado. Pausa, perda de foco e bloqueio de controle descartam pedidos ainda não processados sem cobrança.
- A física aceita cada pedido uma vez, desconta uma unidade e emite a confirmação que reinicia o temporizador. Correção em voo soma o incremento à velocidade existente; decolagem parte de velocidade zero do apoio estático.
- `Partida` mantém os estados `JOGANDO`, `PAUSADO`, `PERDIDA` e `CONCLUIDA`; `Nave` distingue pouso, voo e deriva. O saldo zero bloqueia a entrada, mas não interrompe a integração física. Pousar zera a velocidade e guarda ID/posição relativa do apoio.
- O temporizador é ativado e reiniciado pela confirmação do impulso. Só é decrementado fora do pouso. A deriva reutiliza o tempo restante do último lançamento, sem temporizador adicional. Cada passo é limitado ao tempo restante; contato dentro desse passo é resolvido antes do timeout.
- A pausa cancela a entrada e congela a árvore da simulação. `Partida` e HUD continuam processando os controles de retomada. As notificações de perda de foco/suspensão acionam a pausa; o retorno de foco não altera o estado. A exploração desabilita o controle da nave sem pausar a árvore.
- A finalização emite um único evento de conclusão ou perda e mantém o resultado estável. O reinício reconfigura a nave com os dados autorais e restaura posição, orientação, combustível, tempo, vínculos, alertas, câmera e gestos.

As condições de vitória, derrota, consumo e retomada estão centralizadas nas [regras de jogabilidade](../regras-de-negocio/jogabilidade.md), incluindo o pouso sem combustível adotado pelo protótipo.

## Implementação da prévia e apresentação

O círculo da mira fica no ponto inicial do toque, em coordenadas lógicas de tela. O traçado nasce na nave, inclui sua velocidade atual quando está em voo e usa o mesmo integrador/contatos da execução.

São até 180 passos (3 s a 60 Hz), com pontos a cada três passos e atualização limitada a 15 Hz. O primeiro contato ou limite encerra a previsão. Cancelar, lançar, pausar, explorar ou terminar limpa o indicador. A prévia usa apenas dados locais, sem cobrar combustível nem mover o mundo.

A câmera apresenta a Terra por 1,2 s antes de voltar à nave e habilitar a entrada. A transformação da câmera não altera as unidades lógicas do gesto. Os indicadores e controles disponíveis ao jogador estão descritos nas [regras de apresentação](../regras-de-negocio/jogabilidade.md#prévia-câmera-e-indicadores).

## Evidências e limites de aceite

Na Godot 4.7.2/Windows, a rota do exemplo, partindo da superfície de `origem` em `(90,222)` e aplicando `(0,-80)`, chega à Terra com um impulso. Foi repetida com saldos iniciais 5 e 1. O teste compara o voo com cada ponto amostrado da prévia usando erro menor que 0,001 unidade de mundo. Fontes simétricas, centro, distância, velocidade alta, contato contra origem, desempate, limites, pausa, deriva, timeout, repetição de evento e reinícios têm verificações automatizadas.

As capturas de mira/pausa/vitória foram verificadas no renderizador Mobile/D3D12 e também geradas com Compatibility/OpenGL em Intel UHD Graphics. O ambiente restrito impediu o cache de shaders em `user://`; os PNGs foram gerados normalmente em `.godot/`. Isso não substitui medir desempenho, ergonomia e suspensão no Android.

Ainda precisam de aceite da equipe: mapeamento livre, curva/valores de impulso, gravidade, regra contra origem, contato seguro sem saldo e contagem no pouso. Nenhuma issue foi encerrada apenas por esses testes. O APK de depuração foi gerado e verificado em 15/10/2026; instalação e aparelho de referência permanecem pendentes, conforme [android.md](android.md). Campanha, editor e progresso persistente já estão integrados pelos PRs #43/#44/#46. Checkpoints e recursos condicionais continuam pendentes. Consulte [estado-da-branch.md](../auxiliar/estado-da-branch.md) para o estado consolidado em 26/10/2026.

Referências da engine: [pausa e modos de processamento](https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html), [Camera2D](https://docs.godotengine.org/en/stable/classes/class_camera2d.html), [fluxo de entrada](https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html).
