# Editor de fases JSON

Implementação de #2 e #21–#26 integrada pelo PR #43 em `45466e2`, em Godot 4.7.2. Estado conferido em 26/10/2026; reprodução por outro integrante permanece pendente (#2/#25). O plugin é uma ferramenta interna para o contrato v1 de [fases e simulação](fases-e-simulacao.md). O aceite Android de #4 continua independente e pendente.

Para instruções completas de uso, consulte o [manual do editor de fases](guia-editor-de-fases.md). Esta página registra contexto técnico, implementação e roteiro para reprodução do aceite.

## Abrir, ativar e desativar

Abra `project.godot` com Godot 4.7.2 e selecione **ORBT Fases** na barra superior, junto de 2D/3D/Script. O plugin vem habilitado. Em **Projeto > Configurações do Projeto > Plugins**, ative ou desative **ORBT Fases**. Desativar remove a interface sem excluir fases e sem modificar o fluxo do jogo. A estrutura segue o [plugin de tela principal da Godot](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/making_main_screen_plugins.html).

O editor desenha dados estáticos: não instancia nave, corpos físicos, áudio ou controlador da partida. As alterações ficam em uma cópia autoral na memória. Um rascunho local em `.godot/orbt-editor-sessao.json` preserva dados, caminho e seleção ao desativar/reabrir; esse cache não substitui salvar o JSON nem entra no Git/exportação. Não há propriedades de portais, órbitas ou rotação de corpos.

## Criar e editar

1. Clique em **Nova fase**. Ela começa como cópia da fase de exemplo, com outro ID/nome e sem caminho de salvamento.
2. Selecione **Fase** na lista para editar ID, nome, ordem, versões, combustível, tempo, limites, física, parâmetros da nave e apoio inicial. As unidades e os limites são os do contrato v1. IDs precisam permanecer únicos no catálogo; o editor não cadastra automaticamente uma fase no catálogo.
3. Escolha planeta, satélite, Sol ou asteroide e use **Inserir corpo**. O corpo aparece no centro visível, com ID único. Selecione-o na lista ou pelo círculo no mapa. Arraste para mover ou edite posição, massa e raios nas propriedades. O ID permanece estável durante o movimento.
4. Selecione **Terra** para editar destino e raios. O triângulo amarelo identifica a nave inicial; o quadrado destaca o corpo selecionado. A roda amplia o mapa; o botão central arrasta a visualização; **Enquadrar mapa** mostra os limites.
5. As caixas **Visual**, **Colisão**, **Captura**, **Proximidade** e **Perigo** controlam separadamente os contornos. Para distinguir raios coincidentes, ative um por vez. Proximidade não limita a gravidade.
6. **Excluir selecionado** confirma a remoção de um corpo. A Terra é permanente. Se excluir o apoio inicial, o diagnóstico identifica `start.body_id`; escolha outro planeta/satélite antes de salvar ou testar. Renomear o apoio atualiza essa referência.

Inserir no centro pode criar sobreposição com outro objeto. Mova o novo corpo e confira os diagnósticos antes de testar. Trocar o tipo de um corpo também exige ajustar massa, captura e perigo conforme o contrato; o editor não altera esses valores silenciosamente.

## Arquivos e alterações pendentes

**Abrir** aceita JSON válido pelo mesmo carregador do jogo. Erros de leitura, sintaxe, schema ou geometria mostram o diagnóstico e preservam a edição atual. **Salvar como** escolhe um arquivo `.json` e confirma sobrescrita no diálogo. **Salvar** atualiza o arquivo aberto. A gravação usa arquivo temporário ao lado do destino e só depois substitui o anterior; uma falha mantém a cópia em memória marcada como alterada.

Antes de abrir outro arquivo ou criar nova fase com alterações pendentes, escolha **Salvar**, **Descartar** ou **Cancelar**. Cancelar o diálogo de salvamento também cancela a troca. Um ponto junto ao caminho indica alterações. Valores numéricos são escritos com precisão completa; espaços e ordem das chaves podem mudar ao salvar, preservando valores e campos adicionais.

Salve fases em `Recursos/Fases/`. Para disponibilizá-las no jogo, acrescente o ID/caminho a `Recursos/Niveis.json`, respeitando o contrato do catálogo. O editor não implementa campanha ou progresso.

## Validar, jogar e voltar

**Validar** e a atualização automática usam `CarregadorFase.validar`: IDs, referências, números finitos, raios, versões, início, Terra e zonas incompatíveis. Erros mostram campo/objeto e bloqueiam salvar/testar. Os mesmos erros também bloqueiam o jogo. Avisos adicionais não bloqueiam: passagem com folga menor que o diâmetro da nave, visuais sobrepostos (incluindo destino encoberto) e centro de corpo fora dos limites. Órbitas e decoração independente não fazem parte do schema implementado. Validade geométrica não demonstra solução.

**Testar fase** grava uma cópia temporária em `.godot/orbt-editor-preview.json` e inicia a cena de teste pelo editor. Essa cena valida novamente a cópia e instancia `Nivel.tscn`, a mesma construção usada no jogo. Não usa controlador de campanha, checkpoints ou serviço de progresso. Encerre uma execução existente antes de iniciar outra.

Use **Voltar ao editor**, Esc ou F8 para encerrar o teste. A edição e a seleção permanecem no painel. Movimento, consumo, vitória, derrota e reinício só afetam a tentativa. Ao reativar a tela, a Godot pode manter o foco na aba Jogo; selecione novamente **ORBT Fases**.

## Verificação e reprodução

Execute `tests/run.ps1` para controles, partida e editor. `tests/run_editor_plugin.ps1` abre a Godot real para dois ciclos de ativação/desativação e testa as decisões de salvar/descartar/cancelar. Execute esse segundo script com outros editores do mesmo projeto fechados: ele habilita temporariamente o plugin de testes e restaura `project.godot` em `finally`. Passe `-Capturar` para usar renderização real e salvar `.godot/editor-orbt.png`. Ambos aceitam `-Godot` com o caminho completo do executável.

`tests/run_exportacao.ps1` confere também a exclusão do plugin e da cena de teste. Exportação Android permanece sem dependência da ferramenta.

Em 22/10/2026, Godot 4.7.2 / Windows: 68 verificações de controles, 142 de partida, 32 de editor, 12 de ciclo do plugin com captura e 12 do pacote exportado passaram. A captura foi inspecionada. Não constitui aceite Android nem reprodução por outro integrante.

Para aceite por outro integrante: criar fase, inserir dois corpos, mover/excluir um, ajustar ID/nome/combustível/tempo, salvar, fechar/reabrir e comparar os parâmetros. Provocar referência inválida ao excluir o apoio e confirmar que o teste bloqueia; cancelar abertura com trabalho pendente; testar fase válida, vencer/perder e voltar. Registrar revisão, Godot, passos, resultados e captura. Essa reprodução humana continua pendente; as issues não foram encerradas automaticamente.
