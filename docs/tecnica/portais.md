# Portais pareados

Fonte: `carregador_fase.gd`, `simulacao_voo.gd`, `nave.gd`, `portal_visual.gd` e documento do editor. Estão presentes nas fases avançadas e no exemplo fora do catálogo `demo_portais.json`.

```json
{
  "id": "portal_a", "type": "portal", "position": [60, 0],
  "mass": 0, "visual_radius": 12, "collision_radius": 12,
  "capture_radius": 0, "danger_radius": 0, "proximity_radius": 40,
  "target_id": "portal_b", "exit_degrees": 180
}
```

Configure o outro portal com ligação recíproca. Cada `exit_degrees` indica a saída do próprio portal: 0 direita, 90 baixo, -90 cima, 180 esquerda; intervalo -360–360. São estáticos, sem `orbit`/`rotation`, massa/captura/perigo zero. Não são apoios. A faixa de pouso é incompatível com seu tipo.

O gatilho usa colisão + raio da nave, com varredura por segmento. A saída fica a `collision_radius + raio_nave + 0,01` do destino, na direção definida nele. O carregador rejeita saída fora de `bounds` ou sobreposta a outro corpo na geometria inicial. Não prova segurança durante órbitas de outros corpos.

Somente voo/deriva atravessa. O primeiro contato decide; perigo precede portal no empate. Há no máximo uma travessia por passo e o deslocamento restante é descartado. A velocidade conserva módulo e assume direção de saída. Não custa combustível, não recarrega oxigênio e não cria checkpoint. Saída fora do gatilho evita retorno imediato, sem cooldown persistido.

O salto não é um segmento coletável. Rastro é interrompido. A previsão para ferramentas continua com separador não finito entre entrada/saída; a guia visual atual ignora gatilhos e não prevê teleporte.

O jogo representa os pares como buracos negro/branco com partículas, sem nomes/linhas de ligação no mapa. No editor, configure os dois IDs e direções; renomear atualiza referências. Pares inválidos bloqueiam salvar/testar. Testes: `test_portais.gd`, `test_editor.gd`, `test_campanha_30.gd` e `test_ajustes_interface_voo.gd`.
