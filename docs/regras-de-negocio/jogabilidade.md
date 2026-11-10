# Jogabilidade

Fonte: `src/ControladorJogo/partida.gd`, `src/Nave/nave.gd`, `gesto_mira.gd`, `simulacao_voo.gd`, `src/Nivel/carregador_fase.gd` e `interface_partida.gd`. Conferido em 10/11/2026.

## Objetivo e corpos

Chegar à região de captura da Terra conclui a fase. A campanha começa em estações; o formato também aceita início livre, parado até o primeiro impulso.

| Elemento | Regra |
| --- | --- |
| Planeta | Atrai e permite pousar; pode girar, orbitar e ter faixa segura |
| Estação | Apoio sem gravidade; não gira quando nenhum giro é configurado |
| Terra | Destino com atração forte de curto alcance; sem câmera lenta por proximidade |
| Sol | Atrai com massa positiva; zona de perigo fatal |
| Asteroide | Obstáculo fatal sem gravidade; pode orbitar |
| Portal | Par estático; transporta voo/deriva, preserva rapidez e impõe direção de saída |
| Nebulosa | Limita visão junto da nave, inclusive ao explorar; instrumentos não revelam obstáculos |

Satélites antigos são normalizados como planeta (massa positiva) ou estação (massa zero). Raios visuais, de colisão, captura e proximidade têm funções distintas.

## Mira e impulso

Pressione uma área livre, arraste e solte. O impulso é oposto ao arraste e cresce até o limite autoral. Mouse reproduz toque; somente um contato controla a mira. Botões/diálogos bloqueiam lançamentos através da interface.

Voltar ao círculo cancela. Solte e inicie outro gesto para tentar novamente. Cancelamentos e pedidos descartados antes de aplicar não cobram combustível.

A guia mede até 60 pixels lógicos, é reta e para no primeiro obstáculo detectado, considerando o raio da nave. Ignora gatilhos de portal e não prevê gravidade/movimento futuro. Mirar para dentro do apoio mostra vermelho e **BLOQUEADO**; soltar mantém o pouso sem custo. A linha de força tem dez segmentos azuis e largura de 4 a 6 pixels. O valor aparece acima do círculo.

Cada impulso aceito custa uma carga. Correção em voo soma velocidade; decolagem soma impulso e translação orbital do apoio. O giro transporta a nave pousada, mas não fornece velocidade tangencial à decolagem. Orientação visual não limita a direção do impulso.

## Recursos

Combustível inicial e oxigênio são autorais. Tanques acrescentam a quantidade configurada (os da campanha fornecem +1), uma vez por tentativa, e podem devolver controle à nave à deriva.

O primeiro impulso inicia o consumo de oxigênio. Correções não recarregam o saldo. Pouso suspende o consumo; decolagem retoma o restante. Fora de `bounds`, o consumo dobra, sem derrota imediata. Explorar/mirar durante voo mantém o consumo segundo o tempo da simulação.

Última carga em voo permite deriva e vitória. Pousar em apoio seguro sem combustível causa derrota por falta de combustível para decolar. Pouso não reabastece.

## Pouso, gravidade e tempo

Contato seguro vincula a nave ao apoio. Faixa angular configurada restringe novas chegadas: fora dela há derrota. A faixa gira com o corpo e não exige proa ou velocidade específicas.

Ao decolar, a gravidade do apoio de origem fica suspensa por 1,2 segundo da simulação. Retorna suavemente no segundo seguinte, limitada a 12 unidades de aceleração durante esse voo. Correções não renovam a proteção. Colisões e atração dos outros corpos continuam ativas.

Mirar reduz a escala da simulação a 25%. Aproximar-se dos demais obstáculos/corpos elegíveis em voo reduz gradualmente até 35%; Terra, estações e portais não provocam essa redução. Giro, órbitas, nave e oxigênio usam o mesmo tempo escalado. Pousada sem mira ativa, a nave acompanha o apoio em tempo normal.

Planetas/Terra sem rotação definida recebem 24 graus/s; planetas com faixa recebem 8. Em estações giratórias, o início é antecipado para deixar 0,35 segundo até a direção autoral. O mundo aguarda o título desaparecer para avançar.

## Pausa e câmera

Pausar, perder foco ou suspender o aplicativo cancela a mira e congela a tentativa. Retornar mantém a pausa até continuar. Configurações abertas pela pausa preservam esse estado.

Explorar bloqueia lançamentos e libera arraste/zoom da câmera, mantendo o mundo ativo. Voltar à nave restaura a mira. A câmera de voo começa próxima, afasta conforme a força do arraste e retorna ao soltar/cancelar; distância aos corpos não define zoom.

O título é texto, com leitura de 1,8 s e fade de 0,7 s, dispensável por toque sem lançar. HUD: número da fase, combustível, O2 e ações. Azuis não têm contador durante a fase. Bússolas junto da nave indicam Terra e, em nebulosas, tanques/portais. Mover o mapa não revela áreas além da máscara.

## Resultados

A tentativa termina uma única vez. Perigo, faixa inválida, oxigênio esgotado ou pouso sem combustível causam derrota, com explosão e causa visível.

| Situação | Ações |
| --- | --- |
| Pausa | Menu de fases, reiniciar, continuar e acesso a configurações |
| Vitória | Seleção, repetir e próximo quando houver sucessora; próximo bloqueado abre seleção |
| Última fase | Seleção e repetir; sem próximo |
| Derrota | Último pouso, repetir e menu principal |

Repetir restaura início, corpos, recursos, coletas e câmera. Último pouso recupera o checkpoint do início ou pouso mais recente com seus recursos, relógio e coletas. Restaurar saldo zero mantém derrota. Consulte [campanha e salvamento](campanha.md).
