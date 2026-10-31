# Rotação e pouso por faixa angular

[Issue #92](https://github.com/EclipseEstudio/ORBT/issues/92), em revisão no Projects. Etapa autorizada em 31/10/2026 na continuidade das órbitas do PR #91. Implementação opcional; aceite visual, ergonomia, balanceamento e Android ficam para depois.

## Usar

Abra `Recursos/Fases/demo_rotacao.json` no **ORBT Fases** e clique em **Testar fase**. A demonstração fica fora da campanha e não tem rota de vitória calibrada.

No inspetor de um corpo, ative **Rotação do corpo**. Em planetas e satélites também é possível ativar **Faixa segura de pouso**. A faixa verde identifica o setor permitido. Sem faixa configurada, toda a superfície continua permitindo pouso. A rotação pode existir sem órbita e sem restrição de pouso; a faixa pode existir sem rotação.

```json
"rotation": {"degrees_per_second": 30, "initial_degrees": 0},
"landing_zone": {"center_degrees": -90, "half_width_degrees": 45}
```

`degrees_per_second` e `initial_degrees` aceitam valores finitos entre -360 e 360. O ângulo inicial assume zero quando omitido; velocidade é obrigatória. Valores positivos giram no sentido horário da tela. Rotação superficial não altera os raios nem a massa.

`landing_zone` é exclusiva de planetas e satélites. `center_degrees` define o centro do setor na superfície local (-90 aponta para cima no instante de rotação zero). `half_width_degrees` define a metade da abertura, entre 0,01 e 180; 45 representa um setor de 90 graus. As bordas são inclusivas. O setor gira junto com o corpo. Fora dele, um novo contato encerra a tentativa com **Pouso fora da faixa segura**. Isso não depende do ângulo da proa nem da velocidade de chegada; essas regras não foram acrescentadas.

A faixa é verificada no instante de contato, usando o segmento relativo compartilhado pela simulação e pela prévia. A prévia termina nesse primeiro contato; não classifica o desfecho por cor. O arco verde indica o setor no instante atual.

A nave já pousada acompanha a rotação mantendo seu ponto de superfície e orientação radial. Decolar soma ao impulso as velocidades de translação orbital e tangencial da superfície. Entrar na faixa não modifica combustível. Pausa congela o giro; reinício volta ao instante zero. Checkpoints preservam o relógio e o deslocamento relativo já girado, mantendo compatibilidade com a persistência orbital. A regra angular vale para chegada: não expulsa a nave inicialmente apoiada fora do setor.

Incrementar `content_version` ao introduzir rotação/faixa em uma fase publicada. Nenhuma das dez fases da campanha foi modificada. Não há torque, deformação, faixa angular da proa, gravitação mútua ou portais nesta etapa.

## Verificação local

Godot 4.7.2/Windows: 24 verificações novas de rotação e 2.098 verificações existentes de órbitas, partida, checkpoints, editor e campanha, sem falhas (2.122 no total). Cobrem validação, ângulos/bordas, transporte, orientação, velocidade herdada, pausa, recuperação/reinício e classificação do contato. O primeiro ensaio local de decolagem após recuperação não aguardava a apresentação da câmera; o ensaio foi corrigido para habilitar a entrada antes do lançamento.

Aceite Android, leitura visual dos arcos, desempenho e balanceamento ficam pendentes. Sem novo APK nesta entrega.
