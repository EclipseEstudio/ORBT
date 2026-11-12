# Interface, câmera e apresentação

Fonte: scripts de `src/MenuPrincipal/`, `src/Campanha/selecao_fases.gd`, `src/Nivel/`, `src/Visual/`, `src/Configuracoes/` e `src/Audio/`. Conferido em 10/11/2026.

| Tela | Estado implementado |
| --- | --- |
| Splash | Apresentação da sessão; imagem padrão de boot desativada |
| Menu | Fundo `Recursos/Sprites/fundo_menu_principal.png`, parallax, título ORBT clicável para créditos, Jogar e ícones de configurações/conquistas |
| Tutorial | Duas demonstrações animadas de impulso/cancelamento, com lembretes dos recursos, apenas no diálogo da primeira fase |
| Seleção | Grade de cinco colunas, três níveis, douradas nos cartões e totais no cabeçalho; bloqueios/metas por nível |
| Configurações | Música/efeitos, vibração, dicas e reset de progresso; preferências persistidas |
| Créditos | Participantes e marcas; fundo de estrelas |
| Conquistas | Medalha no menu; título, Voltar e lista vertical de nove cards com imagem, descrição, progresso e cadeado nas bloqueadas |
| Fase | Número no topo; explorar/pausar; combustível, O2, dicas e instrumentos |
| Pausa | Casa/seleção, reset e continuar; configurações; mundo congelado |
| Vitória | Título verde; três douradas e azul apenas se coletada; casa, repetir e próximo quando aplicável |
| Derrota | Título vermelho; motivo com rolagem, Último pouso, Repetir e retorno ao menu principal |

Menu/seleção não expõem retomada persistida, embora o controlador tenha API de recuperação. Falha ao salvar progresso exibe retentativa na seleção.

`src/Conquistas/conquistas.gd` deriva as conquistas dos recordes do catálogo; `tela_conquistas.gd` apresenta os cards usando tema, ícones pixelados, área segura e fundo de estrelas existentes. A lista reage a `progresso.alterado`; desbloqueadas usam cor e confirmação no lugar do cadeado. Voltar pelo cabeçalho ou pelo sistema fecha a sobreposição e devolve o foco à medalha. Créditos usam o título como entrada e restauram seu foco ao fechar.

O tutorial de `src/Tutorial/` aparece automaticamente no painel central de `DialogoDica` da primeira fase e pausa a campanha. A área animada não reconhece gestos nem comanda a nave real. Próximo/Voltar alternam as duas demonstrações sem exigir prática; Jogar, fechar ou Voltar nativo removem o diálogo e liberam a tentativa. Recursos, posição, checkpoint e progresso permanecem intactos. Perda de foco e suspensão congelam a animação. A preferência de dicas controla a apresentação automática. Direção narrativa e migração futura dos destinos: [plano](../projeto/plano-narrativa-tutorial.md).

## Mira e câmera

A mira desenha círculo de cancelamento, força numérica, linha de dez segmentos azuis (4–6 pixels) e guia reta de até 60 pixels lógicos. Contato potencial marca a guia; mirar para dentro do apoio mostra BLOQUEADO. Não há previsão gravitacional na interface.

`camera_nivel.gd` aproxima o voo e afasta segundo a força do arraste, com retorno suave. Exploração permite pan, pinça, roda e botões de zoom; voltar restaura acompanhamento. O título pode ser dispensado sem que o toque lance a nave. Arrastar sobre cartões rola e cancela seleção.

## Nebulosa e efeitos

`nebulosa.gd` e shader limitam visão em coordenadas de mundo junto da nave. Zoom e pan não revelam regiões externas. Instrumentos mostram Terra, tanques restantes e portais sem mostrar obstáculos. Bússolas ficam junto da nave com distância constante na tela; mira e força permanecem acima da máscara.

Estações são desenhadas em código; a nave usa `nave_detalhada.png`. Há rastro, propulsão pixelada e explosão. Portais usam partículas de entrada/saída, sem nomes/linhas no mapa. Esses efeitos não definem a geometria física.

O tema comum e ícones são gerados por `tema_visual.gd` e `icones_ui.gd`. Fonte comum: Press Start 2P; título ORBT usa atlas bitmap. Filtro nearest e áreas seguras preservam a leitura em viewport expandido. Inventário/procedência: [arte](../arte/README.md).

Textos explicativos dos diálogos de ajuda e do tutorial usam tamanho 7, reduzido de 8. Cabeçalhos e botões mantêm tamanho 8 e as áreas de toque existentes. Títulos de vitória, inclusive campanha concluída, usam `Tema.SUCESSO`; o título de fim de jogo usa `Tema.ERRO`.

## Áudio e feedback

`audio_jogo.gd` integra duas músicas e efeitos de botões, impulso, pouso, proximidade e resultados, nos canais Musica/Efeitos. Música continua na pausa; efeitos de simulação são suspensos. O controlador dispara vibração em lançamento, pouso, vitória e derrota quando habilitada e no Android.

Testes de layout/capturas cobrem proporções lógicas variadas; não equivalem a revisão de recortes, áudio ou ergonomia no aparelho. Consulte [validação pendente](../projeto/validacao-pendente.md).
