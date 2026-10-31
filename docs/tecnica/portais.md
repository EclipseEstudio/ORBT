# Portais pareados

[Issue #94](https://github.com/EclipseEstudio/ORBT/issues/94), em revisão no Projects. Continuidade autorizada em 31/10/2026 após o PR #93. Implementação opcional; testes de aceite visual, ergonomia, desempenho e Android ficam para depois.

## Usar

Abra `Recursos/Fases/demo_portais.json` no **ORBT Fases** e clique em **Testar fase**. Um arraste máximo para a esquerda lança para a direita, atravessa o par e chega à Terra. A demonstração fica fora das dez fases da campanha.

No editor, escolha o tipo `portal` e insira dois corpos. Configure `target_id` em cada um com o ID do outro. `exit_degrees` define a direção de saída DESTE portal: zero é direita, 90 é baixo, -90 é cima e 180 é esquerda. Renomear um portal no inspetor atualiza as referências dos demais. O jogo mostra dois anéis, uma seta de saída e o nome da ligação; o editor mostra a seta e os raios. Um par incompleto bloqueia salvar/testar e apresenta diagnóstico.

## Contrato

```json
{
  "id": "portal_a", "type": "portal", "position": [60, 0],
  "mass": 0, "visual_radius": 12, "collision_radius": 12,
  "capture_radius": 0, "danger_radius": 0, "proximity_radius": 40,
  "target_id": "portal_b", "exit_degrees": 180
}
```

Os portais são estáticos, sem órbita, rotação ou faixa de pouso. Exigem massa, captura e perigo iguais a zero. O gatilho usa `collision_radius` mais o raio da nave, com varredura por segmento; o raio de proximidade continua sendo apenas aviso. IDs devem ser únicos, o destino deve ser outro portal e a ligação precisa ser recíproca. `exit_degrees` deve ser finito entre -360 e 360.

A saída é colocada a `collision_radius + raio_nave + 0,01` do centro do destino, na direção configurada. O carregador rejeita saídas fora dos limites ou sobrepostas a outro corpo na configuração inicial. A geometria pode mudar se outros corpos orbitarem; contatos após a saída são resolvidos no passo seguinte. Não se comprova segurança da saída durante toda a órbita de outros corpos.

## Regras da travessia

Somente a nave em voo/deriva atravessa portais. Não são apoios e não transportam uma nave ainda pousada ou pronta. O primeiro contato do passo decide a interação; perigo vence empate com portal. Há no máximo uma travessia por passo. O restante do deslocamento daquele passo não é integrado depois da saída. A velocidade mantém seu módulo e assume a direção de saída; não conserva a direção de entrada. O portal não cobra combustível nem reinicia o temporizador, não cria checkpoint e não altera o estado de voo/deriva. A saída fora do gatilho evita retorno imediato ao mesmo par.

A prévia usa a mesma regra e continua após a saída. Um marcador interno não finito separa os trechos para que o desenho não ligue os portais com uma linha física. Consumidores de `PackedVector2Array` da prévia devem ignorar segmentos com pontos não finitos. Os mapas anteriores, sem portais, não produzem esse marcador. O corpo real não é alterado pela prévia.

Pausa, reinício e checkpoints usam as regras existentes; não há estado de cooldown para persistir. Recomeçar/restaurar o último pouso volta ao checkpoint existente, não à saída do portal. Incrementar `content_version` ao adicionar portais em uma fase publicada.

## Verificação local

Godot 4.7.2/Windows: 22 verificações novas de portais e 2.122 existentes em rotação, órbitas, partida, checkpoints, editor e fases, zero falhas (2.144). Cobrem dados/referências inválidos, saídas bloqueadas, contato rápido, saída sem repetição imediata, renomeação no editor, pausa, reinício, combustível/tempo e equivalência da prévia com a rota de vitória. A primeira tentativa da prévia no ensaio local arrastava na direção contrária ao impulso testado; o gesto do ensaio foi corrigido antes dos resultados aceitos.

Sem novo APK nem aceite Android nesta entrega. Não inclui portais móveis, ligações em rede, conservação da orientação de entrada ou efeitos sonoros novos.
