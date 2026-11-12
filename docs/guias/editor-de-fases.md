# Criar e editar fases

Fonte: `addons/orbt_editor/painel.gd`, `documento.gd`, `mapa.gd` e `teste.gd`. Use a Godot 4.7.2, abra `project.godot` e selecione **ORBT Fases** na barra superior. O plugin está habilitado na configuração do projeto.

Os rótulos dos campos, tipos de corpos e cores das estrelas aparecem em português. As chaves e os valores do JSON permanecem no formato do jogo; os identificadores e textos autorais são preservados.

## Fluxo de autoria

1. Use **Nova fase** ou **Abrir…** para editar um JSON. Uma nova fase parte do exemplo e recebe ID/nome próprios de rascunho.
2. Selecione **Fase** e ajuste ID estável, nome, ordem, combustível inicial, oxigênio (`flight_timeout`), limites, física, nave e início.
3. Insira/mova corpos; configure Terra, raios, órbita, rotação e faixa segura quando aplicável.
4. Insira estrelas e escolha **Dourada** ou **Azul**. A campanha atual usa três douradas e uma azul em cada uma das 30 fases.
5. Use **Inserir tanque** para adicionar combustível coletável. Para limitar a visão, selecione **Fase**, ative **Nebulosa** e ajuste o raio de visão.
6. Clique em **Validar** e corrija erros. **Salvar como…** grava em `Recursos/Fases/`. Teste antes de incluir no catálogo.
7. Para aparecer na campanha, adicione manualmente o par ID/caminho em `Recursos/Niveis.json`. Salvar um arquivo não o cadastra.

Exemplo de entrada do catálogo:

```json
"minha_fase": "res://Recursos/Fases/minha_fase.json"
```

O ID do arquivo precisa coincidir com a chave. A ordem define a sequência e as metas são avaliadas em blocos de dez; inserir/reordenar fases altera a progressão. Preservar ID conserva recordes. Revise `content_version` ao mudar conteúdo incompatível com checkpoints antigos.

## Ferramentas

| Ação | Operação |
| --- | --- |
| Selecionar | Lista ou clique no mapa; Fase, Terra, corpo, estrela ou tanque |
| Mover | Arrastar objeto; arrastar nave inicial move o apoio, quando vinculada |
| Navegar | Botão central arrasta mapa; roda ajusta zoom; Enquadrar mapa mostra limites |
| Inserir corpo | Tipos Planeta, Estação espacial, Sol, Asteroide e Portal |
| Inserir estrela | Item independente de `bodies`, com ID, posição, raio e tipo |
| Inserir tanque | Cria tanque no centro visível do mapa, com carga inicial de +1 |
| Editar | Painel de propriedades; vetores/dicionários são divididos em campos |
| Histórico | Desfazer, refazer e duplicar selecionado |
| Excluir | Selecionar e confirmar; Terra não é removível |

A legenda liga/desliga visual, colisão, captura, proximidade e perigo, sem modificar o JSON. O mapa mostra um retrato no tempo inicial da fase (`start.time_seconds`, zero quando ausente): corpos orbitais, faixas e nave usam esse mesmo instante. Não demonstra uma solução nem simula movimento durante a edição. Arrastar um corpo orbital converte o ponto exibido para a posição autoral no tempo zero, preservando centro, período e sentido da órbita.

Arrastar a nave inicial move seu apoio, preservando o vínculo e o ângulo de saída; em início livre, altera somente `start.position`. Cada arraste pode ser desfeito em uma única ação.

## Mecânicas e campos especiais

| Recurso | Configuração |
| --- | --- |
| Início pousado | `start.body_id` seguro e `angle_degrees`; zero é direita, -90 cima |
| Início livre | `start.position`, sem misturar apoio/ângulo |
| Relógio inicial | `start.time_seconds`; afeta órbitas/giro |
| Órbita | Ative Movimento orbital; configure centro, período e sentido |
| Giro/faixa | Controles do corpo; setor é local à superfície e gira com ela |
| Portal | Dois corpos recíprocos, `target_id` e `exit_degrees`; sem órbita/giro |
| Tanque | **Inserir tanque**, depois selecione pela lista/mapa e edite Identificador, Posição, Raio de coleta e Carga de combustível (inteiro de 1 a 100) |
| Nebulosa | Em **Fase**, ative **Nebulosa** e ajuste **Raio de visão (unidades)** entre 45 e 300; o valor inicial é 120 |

Tanques podem ser arrastados, duplicados e excluídos com o mesmo histórico das estrelas. O raio de coleta aceita de 0,01 a 1.000 unidades. O editor respeita o limite de 256 itens por tipo de coletável.

**Rotação do corpo** reflete o giro efetivo, inclusive o padrão de planetas/Terra sem configuração explícita. Desmarcar grava velocidade zero e preserva a orientação inicial; remover a configuração do JSON reativa o padrão do carregador. Desfazer recupera a configuração anterior.

Com nebulosa ativa, um círculo roxo marca o alcance da visão na posição inicial da nave. O mapa de autoria continua mostrando a fase inteira; **Testar fase** permite conferir a máscara durante o jogo. Desativar nebulosa remove a configuração da fase; desfazer recupera o raio anterior.

O editor preserva campos adicionais carregados, mas não expõe todos como ferramentas visuais. Consulte o [contrato completo](../tecnica/fases-e-simulacao.md) para edição direta. `flight_timeout` é o saldo da tentativa, não um tempo reiniciado a cada impulso. A Terra recebe atração mínima na normalização; não é um destino sem gravidade.

## Validação e salvamento

Erros bloqueiam salvar/testar e identificam campo/objeto. Avisos geométricos orientam inspeção sem comprovar impossibilidade. **Dados válidos para teste** não comprova rota, dificuldade ou desempenho. Excluir apoio não escolhe substituto: corrija `start.body_id`.

Abrir/criar outra fase com alterações pendentes oferece salvar, descartar ou cancelar. A gravação usa temporário e renomeação. O marcador de alteração indica diferenças em relação à última gravação. A sessão tem rascunho local em `.godot/orbt-editor-sessao.json`, que não substitui salvar o JSON autoral.

## Testar e retornar

**Testar fase** usa `.godot/orbt-editor-preview.json` e a cena comum de nível, em cópia independente. Não altera o arquivo autoral, o catálogo ou o progresso real. Pare a execução para voltar ao editor; a cena oferece **Voltar ao editor** e também pode ser encerrada com F8. Edição/seleção permanecem no painel.

Teste lançamento, coletas, limites/oxigênio, pouso, portais, reinício e vitória; confira máscara/zoom quando houver nebulosa. Exemplos fora do catálogo podem ser abertos sem adicioná-los à campanha. Automação: [testes](testes.md); implementação: [editor técnico](../tecnica/editor-de-fases.md).
