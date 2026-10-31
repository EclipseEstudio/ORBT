# Órbitas e corpos móveis

[Issue #90](https://github.com/EclipseEstudio/ORBT/issues/90), em revisão no Projects. Implementação autorizada em 31/10/2026 após o PR #89. Esta decisão inclui órbitas circulares antes condicionais. O aceite Android foi adiado pelo usuário; a implementação não representa esse aceite.

## Usar

No **ORBT Fases**, abra `Recursos/Fases/demo_orbitas.json` e clique em **Testar fase**. O exemplo tem planeta, satélite e asteroide móveis e fica separado das dez fases da campanha. A demonstração não tem uma rota de vitória calibrada.

Selecione um corpo ou a Terra e ative **Movimento orbital**. Edite o centro, o período em segundos e o sentido. Desative a opção para retornar ao comportamento estático. O editor desenha a circunferência e a posição inicial; o movimento é executado ao testar a fase.

## Dados e regras

Campo opcional de cada corpo ou `goal`:

```json
"orbit": {
  "center": [30, 250],
  "period_seconds": 12,
  "clockwise": true
}
```

`position` permanece a posição no instante zero. O raio e o ângulo inicial são calculados em relação a `center`. O raio mínimo é 0,01; o período deve ser finito entre 1 e 86.400 segundos. `clockwise` é booleano e assume `true` quando omitido. Em coordenadas de tela, o sentido horário aumenta o ângulo.

As órbitas são circulares e prescritas ao redor de centro fixo; a massa continua afetando a nave, sem alterar a órbita de outros corpos. Não há órbita hierárquica, gravitação mútua, rotação superficial nem portais nesta etapa.

O relógio avança apenas durante a partida ativa, inclusive enquanto a nave está pousada ou pronta. Observar e explorar não congelam os corpos. Pausa e desfecho congelam o relógio. Reinício volta ao instante zero. A nave pousada conserva o deslocamento relativo ao centro do apoio, acompanha sua translação e herda sua velocidade tangencial na decolagem, somada ao impulso. O tempo de voo continua suspenso durante pouso.

A prévia parte do instante atual e simula posições futuras dos corpos em cópia independente. Contatos são calculados por segmentos relativos entre as posições no começo e fim do passo, inclusive para perigos que atinjam uma nave parada ou transportada. Essa é uma aproximação discreta do arco entre passos; não é detecção contínua exata do arco circular. Configurações extremas e trajetórias que se cruzam exigem revisão de conteúdo; o editor valida a geometria inicial, sem comprovar segurança durante toda a órbita.

Checkpoints incluem `tempo_simulacao`; recuperação reposiciona os corpos antes de restaurar a nave no apoio. Checkpoints antigos sem o campo assumem instante zero. Ao transformar uma fase publicada em orbital, incrementar `content_version` para invalidar checkpoints anteriores dessa fase. IDs e progresso de campanha permanecem independentes.

## Verificação desta entrega

Godot 4.7.2/Windows: 20 verificações novas de órbitas, 158 de partida, 19 de checkpoint persistente, 42 de editor e 1.859 de fases, sem falhas (2.098 no total). Cobrem órbita/velocidade, dados inválidos, transporte pousado, pausa, herança na decolagem, equivalência inicial prévia/voo, preservação dos dados, recuperação/reinício e contato relativo com obstáculo móvel. Importação concluída sem erro de script. A primeira execução do ensaio novo comparava um tempo absoluto sem considerar o passo inicial da engine; foi corrigida para usar o relógio observado. A primeira regressão reposicionava apoios estáticos e foi corrigida antes da execução aceita.

Validação visual, teste em aparelho, desempenho da prévia orbital e balanceamento da demonstração ficam pendentes. Não foi executado o roteiro Android nem uma nova campanha manual.
