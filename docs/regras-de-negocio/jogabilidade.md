# Regras de jogabilidade do ORBT

Estas regras descrevem o comportamento implementado no protótipo, conferido na documentação de 29/10/2026. Elas não substituem o GDD nem representam aceite final no Android. Os formatos de fase, cálculos e critérios determinísticos estão no [contrato técnico de fases e simulação](../tecnica/fases-e-simulacao.md).

## Objetivo e corpos celestes

O objetivo de cada fase é levar a nave até a Terra. A nave pode começar pousada em um planeta ou satélite seguro, ou parada em uma posição livre no espaço, com combustível e tempo de voo definidos pela fase. No início livre, ela aguarda o primeiro impulso sem se mover nem consumir tempo.

| Elemento | Regra no jogo |
| --- | --- |
| Terra | Chegar à sua região de captura conclui a tentativa, mesmo sem combustível restante. |
| Planeta ou satélite | Permite pousar e lançar novamente enquanto houver combustível. O pouso não reabastece. |
| Sol ou asteroide | Entrar na região de perigo causa derrota. |
| Limites da fase | Sair do mundo com o centro da nave causa derrota; permanecer exatamente na borda ainda é permitido. |
| Proximidade | Produz um aviso ao se aproximar de um corpo. Não limita a gravidade nem substitui as regiões de contato. |

Os corpos permanecem parados nesta versão. Os corpos com massa positiva atraem a nave; o desenho de um sprite não define sua superfície física. As regiões de captura, colisão e perigo são parâmetros distintos da fase.

## Mira e impulsos

Pressione uma área livre da interface, arraste e solte para lançar a nave na direção oposta ao arraste. Um arraste maior aumenta a intensidade até o limite da fase. O mouse reproduz o gesto de toque no computador; o controle acompanha um toque por vez.

O círculo no início do gesto delimita a zona de cancelamento. Dentro dele, uma cruz indica que não há impulso válido. Voltar ao círculo antes de soltar cancela o lançamento. Para tentar novamente, solte e inicie outro gesto. Tocar nos botões da interface não lança a nave.

Um impulso em voo acrescenta velocidade à nave; não interrompe o movimento anterior nem oferece frenagem automática. A orientação visual da nave não restringe a direção do impulso.

## Combustível, pouso e deriva

- Cada impulso aceito consome uma unidade de combustível, independentemente de sua intensidade. Cancelar a mira não consome combustível. Pedidos ainda não aplicados são descartados sem cobrança ao pausar ou bloquear o controle.
- O último impulso é executado normalmente. Com saldo zero, a nave continua voando sob gravidade, em deriva, e não pode receber novos impulsos. Ainda é possível chegar à Terra e vencer.
- Pousar em um apoio seguro zera a velocidade e preserva a posição relativa ao corpo. O combustível restante não é recarregado.
- **Regra do protótipo:** pousar em apoio seguro com saldo zero causa derrota por falta de combustível para decolar.
- Lançar em direção ao corpo de origem pode causar contato imediato e novo pouso. O impulso aceito continua sendo cobrado; se ele esgotar o combustível, aplica-se a mesma regra de derrota no apoio seguro.

## Tempo, pausa e exploração

Cada impulso aceito reinicia o tempo de voo com a duração definida na fase. O tempo diminui durante o voo e a deriva. Ficar pousado suspende a contagem até a próxima decolagem. Observar o mapa ou cancelar a mira não reinicia o tempo. Um contato alcançado dentro do tempo restante é resolvido antes do esgotamento do tempo.

**Pausar** cancela a mira e suspende a tentativa. Perder o foco ou suspender o aplicativo também pausa. Voltar ao aplicativo mantém a pausa até o jogador escolher **Retomar**.

**Explorar mapa** permite arrastar a câmera e bloqueia novos lançamentos. A nave continua se movendo e o tempo de voo continua correndo. **Voltar à nave** restaura a mira.

## Vitória, derrota e reinício

Chegar à Terra vence a tentativa. Contato com perigo, saída dos limites, tempo esgotado ou pouso seguro sem combustível causam derrota. Cada tentativa termina uma única vez e apresenta a causa do resultado.

**Reiniciar** começa uma nova tentativa com posição, orientação, combustível, tempo, câmera e contatos iniciais. A tentativa anterior não é retomada. Conclusões e desbloqueios da campanha seguem as [regras de progressão](campanha.md).

O jogo guarda o início da fase e depois substitui esse ponto a cada pouso seguro. Após uma derrota, **Voltar ao último pouso** recupera o último ponto, posição e orientação, combustível e tempo registrados, sem repetir a mira ou um impulso. Um início livre também é recuperável. Se o último pouso ocorreu sem combustível, restaurá-lo mantém a derrota; use **Reiniciar** para voltar ao começo com o saldo inicial. Ao reabrir o jogo, **Continuar** recupera o checkpoint pausado. Dados incompatíveis ou danificados geram aviso e opção para reiniciar uma fase; o progresso de campanha é independente.

## Prévia, câmera e indicadores

Enquanto a mira está fora da zona de cancelamento, a prévia mostra a trajetória estimada a partir da nave, considerando sua velocidade atual e a gravidade. Ela cobre até três segundos e termina no primeiro contato ou limite. A prévia não consome combustível nem movimenta o mundo; cancelar, lançar, pausar, explorar ou encerrar a tentativa limpa o indicador.

A câmera apresenta a Terra no início e depois volta à nave para habilitar a mira. O painel da partida informa combustível, tempo, direção e distância da Terra, proximidade de corpos e causa do desfecho. Os controles permitem pausar, explorar, recentralizar, reiniciar e retornar à seleção de fases.

## Aceite e limites do protótipo

Ainda precisam de aceite da equipe e calibração no Android: direção livre oposta ao arraste, curva e valores de impulso, gravidade, contato contra a origem, pouso seguro sem combustível e suspensão da contagem no pouso. A prévia, os gestos, a pausa e a legibilidade também dependem de teste no aparelho.

As verificações e capturas em Windows estão registradas no [documento técnico](../tecnica/fases-e-simulacao.md#evidências-e-limites-de-aceite). O [roteiro Android](../tecnica/android.md) mantém os critérios de validação no telefone. Movimento dos corpos e portais não fazem parte desta versão implementada.
