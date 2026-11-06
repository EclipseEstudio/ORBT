# Revisão de interface, física e campanha — 06/11/2026

## Interface e ambiente

O menu usa o fundo já fornecido, com deslocamento suave e estrelas adicionais em parallax. O título ORBT não possui emblema acima dele. As fases têm somente três camadas de estrelas, sem planetas decorativos. Câmera e giroscópio alteram apenas o desenho em ceu_parallax.gd. O sensor foi habilitado; sua ausência preserva o parallax da câmera.

A integração de velocidade angular usa radianos por segundo, limite de 0,7 radianos, suavização e recentralização para conter deriva. O fundo obedece à pausa. Os números do HUD ficam sem caixas, preservando a sombra do texto. O menu de pausa abre a seleção; a seleção não cria controles de checkpoint.

## Contrato de fase

O JSON continua no esquema 1. Todos os arquivos distribuídos passam a iniciar em estação e tiveram content_version incrementado para rejeitar checkpoints com geometria anterior.

| Campo | Contrato |
| --- | --- |
| bodies[].type | planet, station, sun, asteroid ou portal; Terra reservada a goal. |
| Estação | Massa zero, pousável; aceita órbita e rotação prescritas. |
| start | Na campanha, body_id da estação e angle_degrees. Posições livres e apoios antigos continuam aceitos para compatibilidade de ferramentas. |
| goal.mass | Mínimo normalizado de 180000. Respeita physics.gravity_constant. |
| gravity_radius | Alcance opcional, cobre capture_radius e vai até 10000. Na Terra, padrão de capture_radius + 38. |
| stars[].type | gold ou blue; ausência significa gold. |
| fuel_pickups | Lista opcional de até 256 tanques com IDs únicos, position, radius e amount inteiro entre 1 e 100. |
| initial_fuel | Saldo específico da fase; coletáveis não são criados implicitamente. |

O leitor converte satellite legado em planeta quando há massa e em estação quando não há. O editor oferece somente os tipos atuais. O seletor de estrela distingue dourada e azul; tanques existentes aparecem no mapa e nas propriedades da fase.

Tanques e estrelas usam varredura do trecho percorrido. O salto de portal não é um trecho coletável; coletáveis também não podem ocupar a saída do portal. Cada ID conta uma vez na tentativa. Tanques são recolhidos antes de resolver o contato final, inclusive chegada ou pouso.

## Tempo e lançamento

Partida._physics_process() escala o delta e chama avancar(), mantendo a simulação compartilhada com os testes. Não altera Engine.time_scale, controles ou menus. Mira: 0,25; a proximidade de planetas, sóis e asteroides pode reduzir a simulação entre 0,35 e 1,0, mas a Terra não reduz a velocidade; pousada sem mirar: 1,0. Oxigênio, nave, órbitas e rotações usam o mesmo delta escalado.

Nave.velocidade_apoio() transmite somente translação orbital. A posição pousada acompanha a superfície giratória; o giro não acrescenta velocidade ao lançamento. A vibração de pouso, colisão e chegada usa a preferência e a permissão Android já existentes.

## Progressão e persistência

O catálogo conta douradas e azuis separadamente. Cada bloco de dez exige arredondar para cima 80% do total dourado para acessar o próximo. Com três por fase, o requisito é 24/30. A seleção mostra um divisor antes das fases 11 e 21 com a meta do bloco anterior. Concluir registra a sucessora como liberada; pode_abrir() também avalia os portões. Repetir melhora recordes sem somar tentativas nem gastar estrelas. Azuis não abrem fases: o contador no cabeçalho mede somente as azuis descobertas, enquanto os cartões mostram apenas as douradas.

O save usa esquema 3: melhores_estrelas para douradas e melhores_azuis para conquistas secundárias. Migra esquemas 1/2 após validar checksum, preserva backup e grava conclusão e ambas as coletas numa geração. Versões futuras não são sobrescritas. A abertura reavalia o portão de estrelas e a fase anterior mesmo para fases concluídas em saves antigos, sem apagar recordes.

Checkpoints guardam combustiveis_coletados. A validação permite saldo até o inicial mais as cargas dos tanques comprovadamente recolhidos; rejeita IDs inexistentes/duplicados. Retomar restaura a coleta para impedir reabastecimento repetido; reiniciar restaura todos os tanques.

## Validação

tests/run.ps1 inclui test_revisao_jogabilidade.gd: limites 23/30 e 24/30, segundo portão, azuis sem efeito na progressão, save/migração, estações em toda a campanha, validação e varredura de tanques, checkpoint com combustível extra, retorno da pausa e sensor.

test_fases.gd percorre as vinte fases em rotas econômicas e de três douradas, com variações pequenas na mira; o saldo inclui cargas realmente recolhidas. Os testes de rotação conferem que o giro não adiciona força. Giroscópio/vibração e balanceamento com jogadores ainda exigem aceite no Android.

A cena da nave na praia permanece para depois.
