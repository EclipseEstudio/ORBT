# Estrelas e tanques coletáveis

Fonte: `carregador_fase.gd`, `partida.gd`, `nave.gd`, `progresso_sessao.gd`, `progresso_persistente.gd` e scripts visuais de coletáveis.

## Contrato

| Array opcional | Campos por item | Restrições |
| --- | --- | --- |
| `stars` | `id`, `position: [x,y]`, `radius`, `type` opcional | Tipo `gold` (padrão) ou `blue`; raio 0,01–1.000 |
| `fuel_pickups` | `id`, `position: [x,y]`, `radius`, `amount` | Raio 0,01–1.000; quantidade inteira 1–100 |

Cada lista aceita até 256 itens e IDs não vazios, únicos dentro da lista e de até 256 caracteres. Objetos devem caber nos limites e não sobrepor corpos/saídas de portais na configuração inicial. São independentes de `bodies` e não atraem nem bloqueiam a nave. `NivelRes` normaliza posições para `Vector2`.

Na campanha há três douradas por fase e azul nas fases 2–30. Totais e recursos atuais: [catálogo](../projeto/catalogo-fases.md).

## Coleta

`SimulacaoVoo` devolve `segments` realmente percorridos. `Nave` emite `trecho_percorrido` antes do contato final; `Partida` usa interseção de círculo com raio do coletável mais raio da nave. Estrelas são ordenadas pela fração de encontro. A coleta anterior à chegada no mesmo passo conta para a vitória.

Teleporte retorna somente o segmento até a entrada; o salto espacial não coleta. IDs já recolhidos são ignorados. Tanques incrementam combustível imediatamente e mudam A_DERIVA para EM_VOO. Douradas/azuis só são confirmadas como recordes na vitória, por `concluir_com_coletas()`.

Pausa preserva conjuntos. Reinício limpa. Checkpoint guarda IDs e restaura o conjunto do pouso, recolocando coletas posteriores. Recordes usam progresso esquema 3; esquemas antigos são migrados. Reposicionar estrelas sem mudar ID da fase não apaga recordes.

## Editor e verificação

O editor insere, seleciona, move, duplica e exclui estrelas, incluindo escolha `gold`/`blue`. `fuel_pickups` é exposto nos dados/propriedades da fase; não há ferramenta dedicada de inserção de tanque no mapa. A configuração de nebulosa pode exigir edição direta do JSON.

Suítes: `test_estrelas.gd`, `test_editor_estrelas.gd`, `test_estrelas_ui.gd`, `test_progresso_estrelas.gd`, `test_revisao_jogabilidade.gd` e `test_campanha_30.gd`.
