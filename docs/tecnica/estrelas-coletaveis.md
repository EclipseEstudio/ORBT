# Estrelas coletáveis

Implementado em 05/11/2026. A campanha contém 20 fases com três estrelas cada. O objetivo continua sendo a Terra; as estrelas são opcionais e não alteram a física ou os recursos da nave.

## Dados e autoria

O JSON v1 aceita o campo opcional `stars`; ausência equivale a uma lista vazia. Cada item tem `id`, `position: [x, y]` e `radius`. O carregador valida IDs únicos, números finitos, raio positivo, limites e sobreposição inicial com corpos e saídas de portais. O limite do contrato é 256 estrelas, embora a campanha use três. `NivelRes.estrelas` contém posições normalizadas como `Vector2`.

No editor **ORBT Fases**, use **Inserir estrela**, selecione no mapa ou na lista e ajuste ID, posição e raio. Arrastar, duplicar, excluir, desfazer, refazer, salvar e testar usam os mesmos dados e o mesmo carregador. Nenhuma estrela é incluída em `bodies`: elas não atraem, não capturam e não bloqueiam a nave.

## Coleta e ordem dos eventos

`SimulacaoVoo` devolve `segments` com os trechos físicos realmente percorridos. `Nave.trecho_percorrido` é emitido antes de resolver contato. `Partida` testa cada estrela contra esses segmentos usando o raio da estrela somado ao raio da nave, ordena os encontros e emite `estrela_coletada(id)`. Isso evita atravessar uma estrela entre dois passos sem recolhê-la.

O trecho termina no primeiro contato, inclusive com Terra ou perigo. O deslocamento instantâneo entre portais não faz parte dos segmentos coletáveis. A coleta anterior à chegada no mesmo passo participa da vitória. `Partida.estrelas_coletadas` é o conjunto da tentativa e a única fonte do estado visual.

Reinício limpa o conjunto. Pausa e exploração preservam-no. Checkpoints guardam os IDs; restaurar o último pouso recoloca as estrelas coletadas depois dele. Checkpoints legados sem esse campo usam uma lista vazia, validada contra os IDs atuais da fase.

## Recordes e persistência

O controlador confirma a coleta somente no evento de vitória, usando `concluir_com_estrelas(id, itens, quantidade)`. O recorde é o máximo obtido numa única conclusão. O total apresentado na seleção soma os recordes das fases do catálogo atual, limitado à quantidade autoral de cada fase.

O save de progresso passa ao esquema 2, acrescentando `melhores_estrelas`. A leitura verifica o checksum do esquema 1 antes de migrá-lo, preservando conclusões, liberações e cópia anterior. Vitória e recorde são gravados juntos. Backup, retentativa e proteção contra versões desconhecidas continuam ativos.

Os recordes pertencem ao ID estável da fase. Alterar a posição de uma estrela mantendo o ID da fase não apaga o recorde. Use outro ID para tratar uma revisão como desafio independente.

## Verificação

- `tests/test_fases.gd`: rotas das 20 fases e coleta opcional.
- `tests/test_estrelas.gd`: validação, coleta contínua, contato, portal e checkpoint.
- `tests/test_progresso_estrelas.gd`: recordes, migração, recuperação e integração com vitória/derrota.
- `tests/test_estrelas_ui.gd`: contagem, grade e resultado em 180×240, 180×320 e 180×390.
- `tests/test_editor_estrelas.gd`: autoria, histórico, mapa, lista e salvamento.

Os testes automatizados verificam regras e soluções reproduzíveis. Não substituem playtest de dificuldade e ergonomia no telefone.
