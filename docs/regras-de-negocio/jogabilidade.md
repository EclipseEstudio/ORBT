# Regras de jogabilidade do ORBT

Estas regras descrevem o comportamento implementado no protótipo, conferido na documentação de 29/10/2026. Elas não substituem o GDD nem representam aceite final no Android. Os formatos de fase, cálculos e critérios determinísticos estão no [contrato técnico de fases e simulação](../tecnica/fases-e-simulacao.md).

## Objetivo e corpos celestes

O objetivo de cada fase é levar a nave até a Terra. A nave pode começar pousada em um planeta ou satélite seguro, ou parada em uma posição livre no espaço, com combustível e tempo de voo definidos pela fase. No início livre, ela aguarda o primeiro impulso sem se mover nem consumir tempo.

| Elemento | Regra no jogo |
| --- | --- |
| Terra | Chegar à sua região de captura durante uma tentativa ativa conclui a fase. |
| Planeta ou satélite | Permite pousar e lançar novamente enquanto houver combustível. O pouso não reabastece. |
| Sol ou asteroide | Entrar na região de perigo causa derrota. |
| Limites da fase | Sair do mundo com o centro da nave causa derrota; permanecer exatamente na borda ainda é permitido. |
| Proximidade | Produz um aviso ao se aproximar de um corpo. Não limita a gravidade nem substitui as regiões de contato. |

Os corpos permanecem parados nesta versão. Os corpos com massa positiva atraem a nave; o desenho de um sprite não define sua superfície física. As regiões de captura, colisão e perigo são parâmetros distintos da fase.

## Mira e impulsos

Pressione uma área livre da interface, arraste e solte para lançar a nave na direção oposta ao arraste. Um arraste maior aumenta a intensidade até o limite da fase. O mouse reproduz o gesto de toque no computador; o controle acompanha um toque por vez.

O círculo no início do gesto delimita a zona de cancelamento. Dentro dele, uma cruz indica que não há impulso válido. Voltar ao círculo antes de soltar cancela o lançamento. Para tentar novamente, solte e inicie outro gesto. Tocar nos botões da interface não lança a nave.

Na primeira fase, a instrução no rodapé acompanha o gesto: indica tocar e segurar, arrastar, voltar ao círculo para cancelar e soltar para lançar. Antes da soltura informa o custo de um combustível; depois do lançamento explica que pousar não recarrega. A dica não exige uma ação específica para liberar o controle e reaparece ao reiniciar a fase.

Um impulso em voo acrescenta velocidade à nave; não interrompe o movimento anterior nem oferece frenagem automática. A orientação visual da nave não restringe a direção do impulso.

## Combustível, pouso e deriva

- Cada impulso aceito consome uma unidade de combustível, independentemente de sua intensidade. Cancelar a mira não consome combustível. Pedidos ainda não aplicados são descartados sem cobrança ao pausar ou bloquear o controle.
- Esgotar o combustível permite continuar à deriva até o oxigênio acabar; ainda é possível chegar à Terra e vencer usando a última carga.
- Pousar em um apoio seguro zera a velocidade e preserva a posição relativa ao corpo. O combustível restante não é recarregado.
- **Regra do protótipo:** pousar em apoio seguro com saldo zero causa derrota por falta de combustível para decolar.
- Lançar em direção ao corpo de origem pode causar contato imediato e novo pouso. O impulso aceito continua sendo cobrado; pousar em apoio com saldo zero encerra a tentativa.

## Tempo, pausa e exploração

O oxigênio é um saldo único por tentativa, com a duração definida na fase. O primeiro lançamento inicia o consumo, que continua em voo, durante correções e à deriva. Pousar suspende o consumo; a próxima decolagem retoma o saldo restante. Nenhum impulso nem pouso recarrega o oxigênio. Observar o mapa ou cancelar a mira não interrompe o consumo durante o voo. Um contato alcançado dentro do tempo restante é resolvido antes do esgotamento. A pausa geral do jogo congela a simulação e o oxigênio.

**Pausar** cancela a mira e suspende a tentativa. Perder o foco ou suspender o aplicativo também pausa. Voltar ao aplicativo mantém a pausa até o jogador escolher **Retomar**.

**Configurações** no menu ou na pausa ajusta separadamente música e efeitos de 0 a 100%. Voltar das configurações mantém a partida pausada; os volumes permanecem no aparelho ao reabrir. Quando as preferências estiverem ausentes ou inválidas, o jogo usa 100% para ambos. A música continua durante a pausa; os efeitos da simulação aguardam a retomada. Com som desligado, textos e indicadores continuam disponíveis.

**Explorar mapa** permite arrastar a câmera e bloqueia novos lançamentos. A nave continua se movendo e o tempo de voo continua correndo. **Voltar à nave** restaura a mira.

## Vitória, derrota e reinício

Chegar à Terra vence a tentativa. Contato com perigo, saída dos limites, oxigênio esgotado ou pouso seguro sem combustível causam derrota. Cada tentativa termina uma única vez. O diálogo de fim de jogo mostra o motivo e oferece Último pouso, Repetir e Voltar ao menu; motivos longos têm rolagem.

**Reiniciar** começa uma nova tentativa com posição, orientação, combustível, tempo, câmera e contatos iniciais. A tentativa anterior não é retomada. Conclusões e desbloqueios da campanha seguem as [regras de progressão](campanha.md).

Na pausa, **Menu principal** encerra a cena atual e retorna ao menu. Após vitória, **Próxima fase** abre a sucessora, **Repetir** inicia novamente a mesma fase e **Seleção de fases** volta à campanha. Na última fase, a opção de próxima fase não é exibida. Na derrota, pode-se restaurar o checkpoint ou reiniciar.

O jogo guarda o início da fase e depois substitui esse ponto a cada pouso seguro. Após uma derrota, **Voltar ao último pouso** recupera o último ponto, posição e orientação, combustível e tempo registrados, sem repetir a mira ou um impulso. Um início livre também é recuperável. Se o último pouso ocorreu sem combustível, restaurá-lo mantém a derrota; use **Reiniciar** para voltar ao começo com o saldo inicial. Ao reabrir o jogo, **Continuar** recupera o checkpoint pausado. Dados incompatíveis ou danificados geram aviso e opção para reiniciar uma fase; o progresso de campanha é independente.

## Prévia, câmera e indicadores

Enquanto há um arraste válido, a mira mostra uma guia reta de 60 pixels lógicos na direção do impulso, independentemente da força e do zoom. A linha entre o ponto inicial do toque e o dedo usa um gradiente de ciano, amarelo, laranja e vermelho, com espessura de 1 a 3 pixels conforme a intensidade. Na zona morta, permanece fina e amarelo apagado. A força máxima acende um anel vermelho junto ao dedo. Cancelar, lançar, pausar, explorar ou encerrar a tentativa limpa a mira.

A câmera começa junto da nave, com a mira disponível imediatamente. O topo da partida mostra somente o número da fase. O painel informa combustível, tempo, direção e distância da Terra, proximidade de corpos e causa do desfecho. Os controles permitem pausar, explorar, recentralizar, reiniciar e retornar à seleção de fases.

Durante a partida, a câmera mantém a nave próxima e centralizada. Arrastar para lançar afasta a visão proporcionalmente à intensidade da força; um toque dentro da zona morta mantém o enquadramento próximo. Soltar ou cancelar retorna suavemente à visão próxima. A distância até os corpos não altera o zoom. A exploração usa zoom manual e, ao voltar à nave, restaura o zoom de voo antes de retomar o enquadramento próximo.

A nave deixa um rastro curto em voo ou à deriva, acima de uma velocidade mínima. Ele termina em ciano e desaparece na cauda, mantendo espessura de 2 pixels lógicos na tela. Pouso, pausa, reinício, fim da tentativa e passagem por portal limpam o trecho anterior.

O texto de distância indica a direção quando o centro da Terra sai da área segura ou fica encoberto pelos controles superiores ou pelo painel inferior. Sobreposição com o topo indica para cima; com o painel inferior, para baixo. A indicação orienta a busca pelo destino no mapa e não prevê uma rota de voo.

## Aceite e limites do protótipo

Ainda precisam de aceite da equipe e calibração no Android: direção livre oposta ao arraste, curva e valores de impulso, gravidade, contato contra a origem, pouso seguro sem combustível e suspensão da contagem no pouso. A prévia, os gestos, a pausa e a legibilidade também dependem de teste no aparelho.

As verificações e capturas em Windows estão registradas no [documento técnico](../tecnica/fases-e-simulacao.md#evidências-e-limites-de-aceite). O [roteiro Android](../tecnica/android.md) mantém os critérios de validação no telefone. Movimento dos corpos e portais não fazem parte desta versão implementada.
