# Órbitas circulares

Fonte: `carregador_fase.gd`, `simulacao_voo.gd`, `nave.gd` e `partida.gd`. Órbitas estão implementadas e aparecem na campanha, além do exemplo `Recursos/Fases/demo_orbitas.json` fora do catálogo.

```json
"orbit": {"center": [30, 250], "period_seconds": 12, "clockwise": true}
```

Campo opcional de corpos/`goal`, exceto portal. `position` é a posição no instante zero; raio é a distância até `center` e deve ser pelo menos 0,01. Período: 1–86.400 s. Sentido booleano, horário por padrão em coordenadas de tela.

A posição é prescrita por centro fixo e relógio da simulação. Massa não altera órbitas de outros corpos; não há gravitação mútua ou órbitas hierárquicas. O relógio parte de `start.time_seconds`, avança pousado/pronto e usa a escala da partida. Título, pausa e desfecho suspendem avanço. Reinício volta ao tempo inicial autoral.

A nave pousada acompanha translação e giro do apoio. Decolar herda a velocidade orbital, somada ao impulso, sem herdar a velocidade da rotação superficial. Contatos usam segmentos relativos ao movimento dos centros entre começo/fim do passo, uma aproximação discreta do arco circular.

Checkpoints preservam relógio e posição relativa. A previsão de ferramentas usa cópia dos corpos; a guia reta do jogador não prevê órbitas. O editor configura movimento/centro/período/sentido e desenha a órbita, sem executar a simulação na edição. Validação inicial não garante segurança de cruzamentos durante todo o período.

Ao mudar geometria/tempo de uma fase publicada, revise `content_version`. Testes: `test_orbitas.gd`, `test_checkpoints.gd`, `test_checkpoint_persistente.gd`, `test_fases.gd` e `test_campanha_30.gd`.
