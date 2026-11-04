# UI e HUD em pixel art

O redesign se limita à apresentação: não muda física, recursos, progressão, salvamentos nem os sinais de navegação.

- **Splash:** a imagem padrão de inicialização da engine fica desativada para evitar duplicação; a apresentação da sessão mostra as marcas Eclipse Estudio e Godot; duração de 1,5 s na primeira abertura da sessão, antecipável por toque ou confirmação. A marca Eclipse em `Recursos/Sprites/eclipse-estudio.svg` é uma proposta vetorial criada para esta tela, substituível pela identidade oficial do estúdio. A marca Godot reutiliza o recurso existente do projeto.
- **Menu:** cenário espacial desenhado em código, somente título ORBT em fonte bitmap própria (atlas 5×7, sem fontes externas) e exatamente três ações na horizontal, embaixo. Jogar tem maior área e fundo ciano. Configurações e créditos usam ícones.
- **Fases:** botão de retorno por ícone e título à esquerda; quatro colunas com rolagem vertical. Disponível: ciano e play; concluída: amarelo e check; bloqueada: cinza e cadeado. O nome completo e o estado ficam na descrição acessível de cada botão. O catálogo é relido e reconciliado com o progresso sempre que a seleção é aberta; não há botão de atualização manual.
- **Gameplay:** combustível e tempo exatos acompanhados de ícones; pausa no canto superior direito; distância/direção do destino embaixo do status; exploração à esquerda da pausa; reinício durante a tentativa somente no menu de pausa. A ajuda inicial aparece em popup durante seis segundos ativos da fase e desaparece com fade, sem interceptar gestos. O contador congela na pausa e não reinicia ao resetar a mesma tentativa. Alertas importantes, vitória e derrota continuam explicados.
- **Pausa:** diálogo modal centralizado, com fundo escurecido e três ações: Continuar, Resetar e Voltar ao menu. Os botões chamam as ações existentes da partida. O diálogo recebe os toques, respeita a área segura e impede que eles alcancem a nave.
- **Checkpoint:** Continuar fica fixo na parte inferior da seleção de fases. Salvar último pouso, diagnósticos e Reiniciar fase ficam na área de rolagem, quando necessários. A recuperação e a retentativa conservam o comportamento anterior de salvamento.
- **Conclusão:** diálogo no mesmo estilo da pausa, com Próxima fase, Repetir e Voltar ao menu. Na última fase, informa a conclusão da campanha e não oferece próxima fase. A progressão continua sendo registrada pelo controlador existente.

`src/Visual/icones_ui.gd` gera texturas de 12×12 em memória. Elas não dependem da disponibilidade de glifos no Android. Os controles preservam descrições de acessibilidade, estados de hover, foco, pressionado e desabilitado. O tema comum está em `src/Visual/tema_visual.gd`.

As áreas seguras continuam sendo calculadas pelas rotinas existentes. Os testes verificam layouts em alturas lógicas de 240, 320 e 390, estados da campanha, navegação e passagem de gestos. `tests/capturar_ui.gd`, executado com renderizador real, salva splash, menu, fases, gameplay e pausa em `.godot/ui-*.png`.

Validação visual no desktop não substitui revisão de recortes, contraste e ergonomia no Android.

Explorar oferece zoom por pinça com dois dedos, roda do mouse e botões +/−. Os limites são 0,05× e 4×; voltar à nave restaura o zoom de voo. Créditos usam o fundo estrelado e mostram apenas os nomes dos participantes.
