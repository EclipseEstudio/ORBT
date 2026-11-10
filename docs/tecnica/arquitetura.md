# Arquitetura

Fonte: `project.godot`, cenas e scripts de `src/` e `addons/orbt_editor/`. Conferido em 10/11/2026.

A cena principal é `src/ControladorJogo/main.tscn`. Os autoloads `GLOBAL` e `UTILITARIO` resolvem `src/global.gd` e `src/utilitario.gd` pelos UIDs registrados. O controlador mantém mundo e interface separados para trocar telas sem deixar a simulação anterior ativa.

| Módulo | Responsabilidade e arquivos principais |
| --- | --- |
| Controlador | `controlador_jogo.gd`: navegação, abertura de fases, serviços de disco, áudio e confirmação de vitória |
| Partida | `partida.gd`: estados JOGANDO/PAUSADO/PERDIDA/CONCLUIDA, oxigênio, coletas, contatos e checkpoint |
| Nave | `nave.gd`: POUSADA/EM_VOO/A_DERIVA/PRONTA, fila de impulsos, transporte e orientação |
| Entrada | `entrada_nave.gd`, `gesto_mira.gd`: toque/mouse, zona morta, cancelamento e intensidade |
| Simulação | `simulacao_voo.gd`: gravidade, integração, órbitas, giro, varredura, portais e previsão para ferramentas |
| Dados de fase | `carregador_fase.gd`, `nivel_res.gd`: validação, cópia normalizada e início |
| Montagem do nível | `gerenciador_de_nivel.gd`, `nivel.gd`, `CorpoEstelar/`: catálogo, instanciação e apresentação dos corpos |
| Campanha | `catalogo.gd`, `progresso_sessao.gd`, `progresso_persistente.gd`, `checkpoint_persistente.gd` |
| Interface | `interface_partida.gd`, `dialogo_pausa.gd`, seleção, menu, configurações e créditos |
| Visual | `src/Visual/`: tema, ícones, sprites, nebulosa, bússolas, efeitos e parallax |
| Áudio | `audio_jogo.gd`: duas músicas, efeitos e integração com estado/volumes |
| Autoria | `addons/orbt_editor/`: plugin, documento, mapa, painel e cena de teste |

## Fluxo de execução

1. O gerenciador lê `Recursos/Niveis.json`; o controlador carrega preferências, progresso e checkpoint.
2. A seleção relê o catálogo, reconcilia o progresso e pede abertura por ID. O controlador verifica bloqueios antes de instanciar.
3. O carregador valida o JSON e entrega `NivelRes`. A nave recebe cópias de corpos; a tentativa não modifica os dados autorais.
4. A entrada prepara um pedido identificado. `Nave.avancar()` aplica a fila uma vez e integra o movimento; `Partida` controla o passo e o oxigênio.
5. Trechos percorridos alimentam coletas antes do contato final. A partida decide pouso, derrota ou vitória; o controlador confirma recordes na vitória.
6. Apresentação lê estado e sinais. Pausa cancela a mira e congela o mundo; controles necessários ao diálogo continuam processando.

A guia exibida pela mira usa `obter_guia_mira()`, sem simulação gravitacional. `prever_trajetoria()` e `SimulacaoVoo.prever()` continuam disponíveis para testes/ferramentas e não representam a guia visual atual.
