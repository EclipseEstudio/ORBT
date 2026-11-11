# Rotação e faixa de pouso

Fonte: `carregador_fase.gd`, `nivel_res.gd`, `simulacao_voo.gd` e `nave.gd`.

```json
"rotation": {"degrees_per_second": 30, "initial_degrees": 0},
"landing_zone": {"center_degrees": -90, "half_width_degrees": 45}
```

Giro: velocidade obrigatória entre -360 e 360 graus/s; ângulo inicial opcional entre -360 e 360, padrão zero. Positivo gira no sentido horário da tela. Sem configuração, planetas/Terra recebem 24 graus/s, ou 8 se têm faixa; estações permanecem sem giro padrão. Portais rejeitam rotação.

Faixa: permitida em planetas, estações e satélites legados. Centro entre -360 e 360; meia abertura entre 0,01 e 180. Meia abertura 45 representa setor de 90 graus; bordas são inclusivas. O setor acompanha o giro. Fora dele, novo contato causa **Pouso fora da faixa segura**. Não avalia proa nem velocidade e não expulsa nave já apoiada.

A nave pousada acompanha a superfície e mantém orientação radial. **A decolagem atual herda somente a translação orbital**, sem a velocidade tangencial superficial. `velocidade_superficie()` existe como utilitário, mas não é somada em `Nave.velocidade_apoio()`.

Estações giratórias antecipam a posição inicial em 0,35 s de giro. `start.time_seconds` define o relógio de início; o título suspende o avanço do mundo. Pausa congela giro, reinício restaura início autoral e checkpoint recompõe relógio/posição relativa.

O editor oferece controles de giro/faixa e arco visual. Exemplo fora do catálogo: `demo_rotacao.json`. Rotação/faixas também aparecem na campanha. Testes: `test_rotacao.gd`, `test_decolagem.gd`, `test_revisao_jogabilidade.gd` e `test_campanha_30.gd`.
