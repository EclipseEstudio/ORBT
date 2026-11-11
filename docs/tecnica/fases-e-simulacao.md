# Fases JSON e simulação

Fonte normativa: `src/Nivel/carregador_fase.gd`, `nivel_res.gd`, `src/Nave/simulacao_voo.gd`, `nave.gd` e `src/ControladorJogo/partida.gd`. Conferido em 10/11/2026.

## Formato v1

Fases são objetos JSON. O carregador retorna `{"nivel": NivelRes, "erros": []}` ou nível nulo com diagnósticos. Jogo e editor usam esse mesmo contrato. Coordenadas/raios são unidades de mundo; arraste e zona morta são unidades lógicas da tela; tempos são segundos da simulação.

| Campo | Regra |
| --- | --- |
| `schema_version` | Exatamente 1 |
| `id`, `name` | Strings não vazias |
| `content_version`, `order` | Inteiros positivos, até 1.000.000 |
| `initial_fuel` | Inteiro positivo, padrão 5 |
| `flight_timeout` | 0,01 a 3.600; saldo de oxigênio da tentativa |
| `bounds` | `position: [x,y]`, `size: [w,h]`, dimensões positivas; fora dele o oxigênio dobra |
| `physics` | `gravity_constant`: 0–1.000; `softening`: 1–10.000 |
| `ship` | `radius`, `mass`, `dead_zone`, `max_drag`, `max_impulse`: 0,01–1.000; arraste máximo maior que zona morta |
| `start` | `body_id` seguro + `angle_degrees` (-360–360), ou `position: [x,y]`; formas mutuamente exclusivas |
| `start.time_seconds` | Opcional, 0–86.400; relógio inicial de órbitas/giro |
| `bodies` | Array de corpos; Terra fica exclusivamente em `goal` |
| `goal` | Corpo normalizado como `earth` |
| `stars`, `fuel_pickups` | Arrays opcionais, até 256 itens de cada; [coletáveis](estrelas-coletaveis.md) |
| `nebula` | Opcional; `visibility_radius` obrigatório entre 45 e 300 |
| `camera` | Opcional: `zoom` positivo até 4; `overview` com posição e tamanho positivo |
| `tutorial`, `notes` | Metadados usados pela interface/autoria; sem a validação numérica dos parâmetros físicos |

Vetores precisam de dois números finitos entre -1.000.000 e 1.000.000. Não há exigência genérica de IDs sequenciais ou de exatamente três estrelas: isso pertence ao conteúdo da campanha.

## Corpo

Cada corpo tem `id`, `type`, `position`, `mass`, `visual_radius`, `collision_radius`, `capture_radius`, `danger_radius` e `proximity_radius`. IDs são únicos entre corpos e Terra. Campos de raio/massa têm máximo 1.000.000; visual, colisão e proximidade são positivos; os demais podem ser zero.

| Tipo | Restrições/normalização |
| --- | --- |
| `planet`, `station` | Captura cobre colisão; perigo zero; estação exige massa zero |
| `satellite` | Legado: normalizado para planeta se massa positiva, estação se zero |
| `sun`, `asteroid` | Perigo cobre colisão, captura zero; asteroide exige massa zero |
| `earth` | Criada por `goal`; massa elevada a pelo menos 180.000; alcance padrão de gravidade = captura + 38 |
| `portal` | Massa/captura/perigo zero, destino recíproco, direção de saída; sem órbita/giro |

Proximidade cobre o raio de contato. `show_proximity` opcional é booleano. `gravity_radius`, quando definido, cobre a captura e não ultrapassa 10.000. Planetas/Terra sem `rotation` recebem giro de 24 graus/s, ou 8 quando têm faixa; estações permanecem sem giro padrão.

Extensões: [órbita](orbitas.md), [rotação/faixa](rotacao-e-pouso.md), [portal](portais.md). Início e Terra devem estar dentro de `bounds`. O início não pode sobrepor outro contato. Zonas de corpos são verificadas com margem para a nave; sobreposição entre dois perigos é permitida. As checagens iniciais não demonstram segurança de toda uma órbita.

## Integração e contatos

A gravidade soma `G * M * r / (|r|² + softening²)^(3/2)` das fontes elegíveis. Estações, asteroides e portais não atraem. `gravity_radius` corta a contribuição fora do alcance. Só o apoio de origem recebe a folga de decolagem: 1,2 s sem atração, retorno suave de 1 s e limite 12 durante o voo.

O passo usa Euler semi-implícito: atualiza velocidade pela aceleração e depois posição. A partida escala o delta conforme mira/proximidade. `project.godot` não sobrescreve a taxa padrão de física. A varredura entre começo/fim do passo considera o raio da nave e o movimento relativo dos corpos.

O primeiro contato prevalece. Em empate dentro da tolerância, perigo precede Terra e depois os demais corpos. Apoios usam maior raio entre colisão/captura; perigos usam `danger_radius`; portais usam colisão. Faixas seguras são avaliadas no instante interpolado do contato. Sair de `bounds` não emite derrota; a partida aumenta o consumo de oxigênio.

O relógio começa em `start.time_seconds` (padrão zero) e avança também pousado/pronto, exceto pausa, título e desfecho. Oxigênio é um saldo separado e só diminui em voo após lançamento. Contato alcançado no passo limitado pelo oxigênio é resolvido antes da verificação final de esgotamento.

## Guia e previsão

`Nave.obter_guia_mira()` produz um segmento de até 60 pixels lógicos com teste dos obstáculos atuais; não integra gravidade e não prevê portais. `prever_trajetoria()` usa o integrador em cópia independente e mantém compatibilidade com ferramentas/testes. A previsão pode conter `Vector2(INF, INF)` separando trechos de teleporte; consumidores devem ignorar ligações com pontos não finitos.

## Compatibilidade e validação

`NivelRes.dados_autorais` preserva o objeto de autoria; valores normalizados podem diferir dele. Incrementar `content_version` quando mudanças invalidarem checkpoints; preservar `id` mantém progresso. Um JSON válido não comprova solução, dificuldade adequada ou desempenho. Consulte [testes](../guias/testes.md) e [validação pendente](../projeto/validacao-pendente.md).
