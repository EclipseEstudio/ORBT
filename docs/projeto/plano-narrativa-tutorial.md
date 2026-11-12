# Volta para casa: narrativa e tutorial

Direção definida em 11/11/2026. Este documento separa o destino narrativo planejado da implementação atual. Referências: `src/Narrativa/narrativa.gd`, `src/Nivel/`, `Recursos/Fases/`, `src/Tutorial/` e issues #54 e #56.

## Premissa

O desejo da personagem é voltar para casa. A Terra é o destino de toda a campanha, mas só é alcançada na fase 30. Cada fase anterior representa um trecho da viagem até um posto de reabastecimento. A história deve ser compreendida por poucas frases, pelo cenário e pelo avanço entre postos.

Lia pode continuar como nome da piloto já existente no código. A Corporação Horizonte e a entrega de suprimentos deixam de ser o centro da motivação. Não são necessários novos personagens ou diálogos extensos para explicar a viagem.

## Progressão proposta

| Momento | Apresentação | Função |
| --- | --- | --- |
| Início da jornada | “A Terra ainda está longe. Um impulso de cada vez. É hora de voltar para casa.” | Explicar o objetivo sem antecipar a chegada |
| Fases 1–10 | Postos próximos e rotas mais abertas | Ensinar a navegação e estabelecer a rotina de viagem |
| Fases 11–20 | Travessias mais longas, órbitas e passagens | Mostrar a distância percorrida através das mecânicas existentes |
| Fases 21–29 | Últimos postos, nebulosas e rotas exigentes | Reforçar que a personagem está perto de casa |
| Fases 1–29 concluídas | “Posto alcançado. Reabastecimento concluído. Próxima parada: mais perto de casa.” | Encerrar o trecho, salvar estrelas e preparar o próximo |
| Fase 30 concluída | Terra, seguida da arte da personagem descansando na praia: “Finalmente, em casa.” | Encerrar a campanha com uma recompensa visual tranquila |

Os postos terão aparência de pequenas estações esféricas artificiais: casco metálico, placas, faixa equatorial e luzes de docagem. A referência de escala/formato é um planeta artificial; sua função deve parecer acolhedora e utilitária. A Terra mantém aparência azul e verde distinta e fica reservada à última fase.

## Regras dos postos

- O posto é o objetivo de chegada das fases 1–29; não é mais um pouso comum nem um novo ponto obrigatório no meio da rota.
- Chegar ao posto conclui a fase e confirma as estrelas, como a chegada ao destino atual.
- O reabastecimento acontece na transição entre fases. A próxima começa com o combustível e o oxigênio definidos no seu JSON; não transfere excedentes nem muda o balanceamento.
- Pousos comuns continuam sem recarregar combustível. Tanques coletáveis continuam dando +1. O checkpoint de recuperação do último pouso permanece uma função distinta do posto narrativo.
- Preservar IDs das fases, ordem, geometrias das rotas, metas 30/60 e progresso salvo. A migração muda o tipo/visual do destino, não desloca os obstáculos.
- A bússola, dicas, resultados e acessibilidade devem dizer “posto” ou “destino” nas fases intermediárias e “Terra” apenas na final.

## Entrega atual: tutorial demonstrativo

O tutorial aparece automaticamente **dentro do diálogo da primeira fase**, após o título, somente com demonstrações animadas. Não há acesso no menu principal nem etapas de prática. Ao terminar, **Jogar** fecha o diálogo e libera a tentativa; fechar ou usar Voltar também o dispensa. A opção de ocultar dicas continua ocultando a apresentação da fase.

1. **Observar o lançamento:** um ponto animado toca e arrasta para baixo; a seta aponta para cima e a nave se move ao soltar. A seta representa direção de impulso, não uma previsão completa da trajetória.
2. **Observar o cancelamento:** o ponto retorna ao círculo inicial, sem lançar.

As duas demonstrações repetem automaticamente e incluem lembretes: cada impulso custa uma unidade, pouso não reabastece, O2 diminui em voo e a seta indica direção. Próximo, Voltar e Jogar permitem navegar sem executar gestos. Arrastar sobre a animação não controla a nave nem altera a etapa. O diálogo mantém a campanha pausada, preservando recursos, posição, checkpoint e progresso.

## Próximas entregas planejadas

| Entrega | Alterações | Aceite |
| --- | --- | --- |
| Destinos intermediários | Contrato de objetivo genérico no carregador/validador, tipo de posto na fábrica/editor, renderização, contato e bússola; migrar as fases 1–29 | Só a fase 30 contém a Terra como objetivo; rotas e progresso anteriores continuam válidos |
| Narrativa visível | Introdução dispensável, mensagens de posto/reabastecimento, revisão das 30 dicas e conclusões | Nenhuma fase intermediária anuncia chegada à Terra; reiniciar não repete mensagens indevidas |
| Desfecho | Gerar arte em pixel art da piloto descansando na praia e integrar uma tela final, após confirmar o resultado da fase 30 | Arte aparece apenas na vitória final; derrotar, repetir e sair preservam o progresso; ações para repetir e voltar continuam acessíveis |
| Aceite do tutorial | Jogador não autor, Android real, toque/mouse, telas pequenas, suspensão e Voltar | Jogador consegue cancelar e lançar sem orientação verbal externa |

A arte final deve mostrar areia, mar calmo, horizonte aberto, a personagem relaxada e o capacete ao lado. Paleta compatível com o jogo, clima de descanso e espaço para a frase e os botões. A produção e integração dessa arte pertencem à entrega do desfecho.

## Limite da implementação atual

Os JSONs e a condição de vitória ainda usam Terra em todas as fases. Os textos legados de carga médica também continuam no código. A substituição dos destinos e a praia estão planejadas, não implementadas nesta entrega do tutorial. Atualizar as regras e o catálogo quando a migração for realizada; não descrever o plano como comportamento já entregue.
