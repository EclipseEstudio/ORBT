# Regras de jogabilidade do ORBT

Estas regras descrevem o comportamento implementado no protótipo, conferido na documentação de 29/10/2026. Elas não substituem o GDD nem representam aceite final no Android. Os formatos de fase, cálculos e critérios determinísticos estão no [contrato técnico de fases e simulação](../tecnica/fases-e-simulacao.md).

## Objetivo e corpos celestes

O objetivo de cada fase é levar a nave até a Terra. A nave pode começar pousada em um planeta ou satélite seguro, ou parada em uma posição livre no espaço, com combustível e tempo de voo definidos pela fase. No início livre, ela aguarda o primeiro impulso sem se mover nem consumir tempo.

| Elemento | Regra no jogo |
| --- | --- |
| Terra | Chegar à sua região de captura durante uma tentativa ativa conclui a fase. |
| Planeta ou satélite | Permite pousar e lançar novamente enquanto houver combustível. O pouso não reabastece. |
| Sol ou asteroide | Entrar na região de perigo causa derrota. |
| Espaço aberto | Não há borda visível nem derrota imediata por sair da região autoral. Fora dela, o consumo de oxigênio dobra; ao retornar, volta ao normal. A nave continua em voo até chegar à Terra, colidir ou esgotar o oxigênio. |
| Proximidade | Produz um aviso ao se aproximar de um corpo. Não limita a gravidade nem substitui as regiões de contato. |

Estações ficam sem rotação por padrão, inclusive nas fases iniciais. Giros e órbitas explicitamente definidos na fase são preservados. Planetas e Terra sem giro definido recebem 24 graus por segundo, ou 8 nos planetas com faixa segura. A nave pousada acompanha a superfície sem consumir combustível ou oxigênio. Nas estações com giro, a posição inicial deixa apenas 0,35 segundo até a direção de saída prevista; o mundo aguarda o título desaparecer para começar a se mover. A fase Janela orbital já começa na janela de lançamento. Os corpos com massa positiva atraem a nave; o desenho de um sprite não define sua superfície física. As regiões de captura, colisão e perigo são parâmetros distintos da fase.

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
- Mirar para dentro do apoio mostra uma guia curta vermelha, uma cruz e o aviso **BLOQUEADO**. Soltar nessa direção mantém o pouso sem gastar combustível nem ativar o oxigênio. A direção é conferida novamente no passo de aplicação para considerar o giro da superfície.
- Ao decolar, a atração gravitacional do apoio de origem fica suspensa por 1,2 segundo e retorna suavemente durante o segundo seguinte, limitada a 12 unidades de aceleração durante esse voo. Isso dá espaço para a nave sair da captura. Correções não renovam a proteção; outros corpos, perigos e colisões continuam ativos.

## Tempo, pausa e exploração

O oxigênio é um saldo único por tentativa, com a duração definida na fase. O primeiro lançamento inicia o consumo, que continua em voo, durante correções e à deriva. Pousar suspende o consumo; a próxima decolagem retoma o saldo restante. Nenhum impulso nem pouso recarrega o oxigênio. Observar o mapa ou cancelar a mira não interrompe o consumo durante o voo. Um contato alcançado dentro do tempo restante é resolvido antes do esgotamento. A pausa geral do jogo congela a simulação e o oxigênio.

**Pausar** cancela a mira e suspende a tentativa. Perder o foco ou suspender o aplicativo também pausa. Voltar ao aplicativo mantém a pausa até o jogador escolher **Retomar**.

**Configurações** no menu ou na pausa ajusta separadamente música e efeitos de 0 a 100%. Voltar das configurações mantém a partida pausada; os volumes permanecem no aparelho ao reabrir. Quando as preferências estiverem ausentes ou inválidas, o jogo usa 100% para ambos. A música continua durante a pausa; os efeitos da simulação aguardam a retomada. Com som desligado, textos e indicadores continuam disponíveis.

**Explorar mapa** permite arrastar a câmera e bloqueia novos lançamentos. A nave continua se movendo e o tempo de voo continua correndo. **Voltar à nave** restaura a mira.

## Vitória, derrota e reinício

Chegar à Terra vence a tentativa. Contato com perigo, oxigênio esgotado ou pouso seguro sem combustível causam derrota. Cada tentativa termina uma única vez. O diálogo de fim de jogo mostra o motivo e oferece Último pouso, Repetir e Voltar ao menu; motivos longos têm rolagem.

**Reiniciar** começa uma nova tentativa com posição, orientação, combustível, tempo, câmera e contatos iniciais. A tentativa anterior não é retomada. Conclusões e desbloqueios da campanha seguem as [regras de progressão](campanha.md).

Na pausa e na conclusão, as ações aparecem apenas como ícones na mesma linha: **Menu de fases** à esquerda, **Resetar/Repetir** no centro e **Continuar/Próxima fase** à direita. O menu encerra a tentativa e retorna à campanha. Após vitória, **Próxima fase** abre a sucessora e **Repetir** inicia novamente a mesma fase. Na última fase, a opção de próxima fase não é exibida. Na derrota, pode-se restaurar o checkpoint ou reiniciar.

O jogo guarda o início da fase e depois substitui esse ponto a cada pouso seguro. Após uma derrota, **Voltar ao último pouso** recupera o último ponto, posição e orientação, combustível e tempo registrados, sem repetir a mira ou um impulso. Um início livre também é recuperável. Se o último pouso ocorreu sem combustível, restaurá-lo mantém a derrota; use **Reiniciar** para voltar ao começo com o saldo inicial. Ao reabrir o jogo, **Continuar** recupera o checkpoint pausado. Dados incompatíveis ou danificados geram aviso e opção para reiniciar uma fase; o progresso de campanha é independente.

## Prévia, câmera e indicadores

Enquanto há um arraste válido, a mira mostra uma guia reta de até 60 pixels lógicos na direção do impulso, independentemente da força e do zoom. A guia para no primeiro obstáculo, considerando o tamanho da nave, e marca o contato em amarelo; contra o próprio apoio, fica curta e vermelha. Ela não prevê curvas gravitacionais. A linha de força entre o toque e o dedo usa dez segmentos em tons de azul, com espessura de 4 a 6 pixels conforme a intensidade. Cancelar, lançar, pausar, explorar ou encerrar a tentativa limpa a mira.

A câmera começa junto da nave, com a mira disponível imediatamente. O topo da partida mostra somente o número da fase. O painel informa combustível, tempo, direção e distância da Terra, proximidade de corpos e causa do desfecho. Os controles permitem pausar, explorar, recentralizar, reiniciar e retornar à seleção de fases.

Durante a partida, a câmera mantém a nave próxima e centralizada. Arrastar para lançar afasta a visão proporcionalmente à intensidade da força; um toque dentro da zona morta mantém o enquadramento próximo. Soltar ou cancelar retorna suavemente à visão próxima. A distância até os corpos não altera o zoom. A exploração usa zoom manual e, ao voltar à nave, restaura o zoom de voo antes de retomar o enquadramento próximo.

A nave deixa um rastro curto em voo ou à deriva, acima de uma velocidade mínima. Ele termina em ciano e desaparece na cauda, mantendo espessura de 2 pixels lógicos na tela. Pouso, pausa, reinício, fim da tentativa e passagem por portal limpam o trecho anterior.

A seta azul da Terra permanece ao redor da nave, acima dos demais indicadores. Nas nebulosas, as outras bússolas também acompanham a nave: dourado para combustível, roxo para entrada de portal e branco para saída. A distância dos ponteiros à nave permanece constante na tela mesmo ao mudar o zoom. A mira e a barra de força ficam acima da fumaça. A barra de oxigênio traz a identificação **O2**.

Os pares de portais exibem um buraco negro com partículas sendo sugadas e um buraco branco expelindo partículas, sem nomes ou textos de ligação sobre o mapa. O efeito é visual e não acrescenta gravidade nem custo de combustível ao teleporte.

O título da fase pode ser dispensado imediatamente com um toque ou clique. O mesmo toque não inicia um lançamento. No menu de fases, arrastar sobre um cartão rola a lista e cancela sua seleção; um toque simples continua abrindo a fase. A barra lateral ocupa três pixels lógicos.

## Aceite e limites do protótipo

Ainda precisam de aceite da equipe e calibração no Android: direção livre oposta ao arraste, curva e valores de impulso, gravidade, contato contra a origem, pouso seguro sem combustível e suspensão da contagem no pouso. A prévia, os gestos, a pausa e a legibilidade também dependem de teste no aparelho.

As verificações e capturas em Windows estão registradas no [documento técnico](../tecnica/fases-e-simulacao.md#evidências-e-limites-de-aceite). O [roteiro Android](../tecnica/android.md) mantém os critérios de validação no telefone.
