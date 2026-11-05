# Regras da campanha e estrelas

Atualizado em 05/11/2026. A campanha tem 20 fases e 60 estrelas opcionais. O objetivo de cada fase é chegar à Terra. A coleta oferece um segundo desafio para quem quiser repetir e melhorar o resultado.

## Progressão

As primeiras fases ensinam mira e força com trajetos curtos e espaço para errar. As seguintes introduzem pouso e decolagem, dois impulsos no mesmo voo, gravidade e órbitas. O trecho final combina essas ações com obstáculos, passagens menores e planejamento de combustível.

A primeira fase está disponível desde o início. Chegar à Terra conclui a fase e libera a seguinte, mesmo sem nenhuma estrela. Fases concluídas podem ser repetidas. Perder, reiniciar ou abandonar não conclui a fase nem confirma a coleta.

O menu **Jogar** abre a grade de fases. Cada cartão mostra número, estado e recorde de estrelas; a descrição acessível conserva o nome da fase. A coleção no cabeçalho soma os melhores resultados das fases do catálogo atual.

| Fase | Nome | Desafio principal |
| --- | --- | --- |
| 1 | Primeiro impulso | Aprender a lançar até a Terra. |
| 2 | Mira aberta | Mirar na diagonal e conhecer as estrelas opcionais. |
| 3 | Passagem larga | Cruzar uma abertura entre rochas. |
| 4 | Primeiro pouso | Pousar e decolar em outra direção. |
| 5 | Segundo impulso | Corrigir a trajetória durante o voo. |
| 6 | De lua em lua | Encadear dois pousos. |
| 7 | Escala no desvio | Usar um apoio para contornar uma barreira. |
| 8 | Corredor de retorno | Combinar desvio e correção em voo. |
| 9 | Curva gravitacional | Aproveitar a atração de uma lua. |
| 10 | Rasante solar | Usar a gravidade sem tocar no Sol. |
| 11 | Lua em movimento | Interceptar um apoio em órbita. |
| 12 | Janela orbital | Escolher quando decolar do planeta em movimento. |
| 13 | O Contorno | Contornar um obstáculo e voltar à rota. |
| 14 | Duas Rotas | Escolher uma passagem entre perigos. |
| 15 | Pouso de precisão | Alcançar as faixas seguras dos apoios. |
| 16 | Travessia orbital | Pousar em movimento entre obstáculos. |
| 17 | Arco entre rochas | Combinar atração gravitacional e passagem estreita. |
| 18 | Três escalas | Planejar três pousos e suas decolagens. |
| 19 | Cinturão em movimento | Desviar de rochas fixas e orbitais. |
| 20 | Última manobra | Combinar órbita, pousos e correção em voo. |

## Estrelas e repetição

- Cada fase da campanha tem três estrelas. Nenhuma é necessária para vencer ou desbloquear a próxima fase.
- A nave coleta ao passar pela estrela, que desaparece com um brilho curto. Cada estrela conta uma vez na tentativa.
- Coletar não fornece combustível nem oxigênio. A rota mais curta pode gastar poucos impulsos; desviar para coletar pode exigir correções, outros pousos ou mais tempo de voo.
- A contagem durante o voo é provisória. Só a chegada à Terra confirma o resultado.
- O jogo guarda o maior número de estrelas obtido numa única conclusão da fase. Uma repetição pior conserva o recorde. Resultados de tentativas diferentes não são somados.
- A coleção equivale à soma dos recordes: no máximo 60 estrelas nesta campanha. Não há compra ou gasto de estrelas nesta implementação.

Exemplo: chegar à Terra com duas estrelas salva 2/3. Perder depois de recolher três mantém 2/3. Vencer novamente com uma também mantém 2/3. Chegar com três melhora para 3/3.

## Tentativa, pausa e último pouso

Uma tentativa nova restaura posição, combustível, oxigênio, câmera e todas as estrelas. Pausar preserva a coleta. Explorar o mapa mantém o estado da tentativa e o oxigênio continua diminuindo durante o voo.

**Último pouso**, após derrota, restaura os recursos e as estrelas que estavam coletadas naquele checkpoint. Estrelas recolhidas depois desse pouso voltam ao mapa. O início também é um checkpoint válido. Checkpoints antigos sem informação de estrelas usam coleta vazia.

Na conclusão, o diálogo mostra a coleta da tentativa e o melhor resultado. **Repetir** inicia uma nova tentativa; **Próxima fase** abre a sucessora, quando houver.

## Salvamento e compatibilidade

Conclusões, desbloqueios e recordes são salvos neste aparelho. O progresso anterior é preservado ao atualizar o formato de salvamento. Fases removidas do catálogo mantêm seus dados no arquivo, mas não entram no total da coleção apresentada.

Se houver falha de gravação, o resultado vale na sessão e a interface oferece a retentativa de salvamento. Um arquivo principal inválido pode ser recuperado da última cópia válida. Versões desconhecidas são preservadas, sem sobrescrita automática.

Os testes de rotas e de coleta usam a simulação do jogo. O ajuste de dificuldade por jogadores e a validação de toque e desempenho no Android continuam necessários para o aceite no aparelho.
