# Manual do editor de fases ORBT

Este manual explica como criar, editar, validar, salvar e testar fases do ORBT no plugin **ORBT Fases** da Godot. Ele cobre o editor disponível no projeto: composição visual dos corpos, propriedades JSON, validação pelo carregador do jogo e execução de uma cópia temporária.

O plugin foi desenvolvido para Godot 4.7.2 e para o contrato JSON v1 descrito em [fases-e-simulacao.md](../tecnica/fases-e-simulacao.md). O editor é uma ferramenta de autoria: não altera a física, não completa uma campanha e não substitui testes de jogabilidade no telefone.

## 1. Preparar e abrir o editor

1. Abra a pasta do projeto ORBT no Godot 4.7.2. Não abra só uma cena; o plugin precisa do projeto completo para localizar o carregador, os recursos e as cenas do jogo.
2. Espere a importação inicial terminar. Se o projeto pedir para importar recursos, deixe o processo concluir.
3. Na barra de telas do editor, selecione **ORBT Fases**. A aba fica junto de **2D**, **3D** e **Script**.
4. O plugin vem habilitado no projeto. Para alterar sua ativação, abra **Projeto > Configurações do Projeto > Plugins** e marque ou desmarque **ORBT Fases**.

Ao abrir o plugin pela primeira vez, ele carrega `Recursos/Fases/teste_001.json`. Você pode usá-lo como referência antes de criar uma fase. Desativar e reativar a tela preserva a sessão local, inclusive a fase selecionada e o caminho em edição.

### Áreas da tela

| Área | Uso |
| --- | --- |
| Barra superior | Criar, abrir, salvar, validar e testar a fase; mostra o caminho ou “Nova fase”. Um ponto `●` indica alterações ainda não salvas. |
| Ferramentas do mapa | Escolher o tipo de corpo, inserir ou excluir corpos e enquadrar os limites. |
| Lista à esquerda | Selecionar **Fase**, **Terra** ou um dos corpos. A seleção também pode ser feita clicando no objeto no mapa. |
| Propriedades | Editar os campos da seleção. Dicionários e vetores aparecem como campos separados, por exemplo `bounds.position.x` e `ship.radius`. |
| Mapa à direita | Conferir posição, limites, raios visuais e físicos, ponto inicial e seleção. |
| Diagnósticos abaixo do mapa | Exibe erros bloqueantes, avisos geométricos e o resultado da validação mais recente. |

## 2. Criar uma fase

1. Clique em **Nova fase**. A nova edição começa como cópia dos dados do exemplo, mas recebe o ID `nova_fase`, o nome `Nova fase` e fica sem arquivo de destino.
2. Selecione **Fase** no alto da lista à esquerda.
3. Edite pelo menos `id`, `name`, `order`, `initial_fuel`, `flight_timeout`, `bounds`, `physics`, `ship` e `start`.
4. Escolha **Salvar como…** para dar um nome ao arquivo. Salve em `Recursos/Fases/` com extensão `.json`, por exemplo `orbita_inicial.json`.
5. Valide a fase, corrija os erros e execute **Testar fase** antes de adicioná-la ao catálogo.

Salvar como arquivo não cadastra automaticamente uma fase para o menu do jogo. A ligação com a campanha é feita em `Recursos/Niveis.json`, conforme a seção [Disponibilizar a fase no jogo](#9-disponibilizar-a-fase-no-jogo).

## 3. Navegar e compor o mapa

### Selecionar e mover

- Clique numa navegação da lista para selecionar **Fase**, **Terra** ou um corpo. Também é possível clicar num corpo no mapa.
- Arraste um corpo no mapa para mudar sua posição. Arrastar a nave inicial move o corpo ao qual ela está vinculada; ajuste `start.angle_degrees` nas propriedades da fase para mudar a posição da nave ao redor desse apoio.
- Se corpos ou raios ficarem fora de vista, clique em **Enquadrar mapa**. O botão central do mouse arrasta a visualização sem mover os objetos.
- Use a roda do mouse para ampliar ou reduzir. O zoom mantém sob o cursor a região do mundo que estava apontada.

O mapa é um desenho de dados estáticos. Ele não executa a gravidade, não desenha a trajetória da nave e não representa uma solução. A posição da nave inicial é indicada por um triângulo amarelo; o corpo selecionado tem um quadrado amarelo.

### Inserir corpos

1. Na ferramenta acima do mapa, escolha `planet`, `satellite`, `sun` ou `asteroid`.
2. Clique em **Inserir corpo**. O editor cria o novo corpo no centro visível do mapa e seleciona-o.
3. Edite o ID, a posição, a massa e os raios no painel de propriedades.
4. Mova o corpo se ele cobrir outro objeto ou ficar sobre o início, a Terra ou uma zona de contato incompatível.

O ID é gerado como `planet_1`, `satellite_1`, `sun_1` ou `asteroid_1`, usando o primeiro número livre para aquele tipo. O modelo inicial preenche os raios e propriedades essenciais para o tipo selecionado, mas esses valores ainda precisam ser ajustados à intenção da fase. Corpos perigosos começam com zona fatal e sem captura; apoios começam com captura e sem zona fatal.

### Excluir corpos

1. Selecione um corpo na lista ou no mapa.
2. Clique em **Excluir selecionado…** e confira o diálogo antes de confirmar.
3. Se o corpo excluído era o apoio inicial, selecione outro planeta/satélite seguro e atualize `start.body_id` na fase.

A Terra é um campo de destino, não um corpo removível. O editor preserva a referência ao apoio excluído para que a validação indique o problema; não escolhe outro apoio automaticamente.

## 4. Entender a legenda do mapa

As caixas **Visual**, **Colisão**, **Captura**, **Proximidade** e **Perigo** ligam ou desligam os contornos correspondentes. Essas caixas alteram somente o desenho do editor; não alteram os valores do JSON. Desmarque camadas sobrepostas para inspecionar cada raio com clareza.

| Contorno | Significado no jogo |
| --- | --- |
| Visual | Extensão usada para desenhar o corpo. Não define sua colisão. |
| Colisão | Raio da superfície sólida. A nave tem seu próprio raio, que participa do contato. |
| Captura | Distância que permite pousar em apoio seguro ou chegar à Terra. Para estes objetos, deve ser igual ou maior que o raio de colisão. |
| Proximidade | Distância usada pelo aviso de proximidade. Não muda a força gravitacional. |
| Perigo | Zona fatal de Sol ou asteroide. Deve ser igual ou maior que a superfície de colisão desses perigos. |

O ponto de início amarelo inclui o raio do corpo e o raio da nave. A direção corresponde a `start.angle_degrees`. A moldura cinza mostra `bounds.position` e `bounds.size`.

## 5. Editar propriedades

Selecione **Fase**, **Terra** ou um corpo para preencher o painel de propriedades. Os campos numéricos usam controles incrementais; os vetores e dicionários são divididos em propriedades aninhadas. Por exemplo, editar `physics.gravity_constant` não exige escrever o objeto JSON inteiro.

### Propriedades da fase

| Campo | O que controla | Regra principal |
| --- | --- | --- |
| `id` | Identidade estável usada pelo catálogo e progresso. | Texto não vazio e único em `Recursos/Niveis.json`. |
| `name` | Nome apresentado à pessoa que joga. | Texto não vazio. |
| `schema_version` | Versão do formato JSON. | Deve permanecer em `1`; o controle é somente leitura. |
| `content_version` | Versão autoral do conteúdo. | Inteiro positivo. Não migra nem altera progresso por si só. |
| `order` | Ordem da fase na seleção. | Inteiro positivo. |
| `initial_fuel` | Combustível no início de cada tentativa. | Inteiro de 1 a 1.000.000; o padrão do exemplo é 5. |
| `flight_timeout` | Tempo de voo após um impulso. | De 0,01 a 3.600 segundos; o exemplo usa 30. |
| `bounds.position.x/y` | Canto de origem do retângulo do mundo. | Coordenadas dentro de ±1.000.000. |
| `bounds.size.x/y` | Largura e altura do mundo. | Valores positivos. |
| `physics.gravity_constant` | Intensidade comum da gravidade. | De 0 a 1.000. |
| `physics.softening` | Suavização da gravidade perto de uma fonte. | De 1 a 10.000 unidades de mundo. |
| `ship.radius` | Raio físico da nave. | De 0,01 a 1.000. |
| `ship.mass` | Massa usada para dividir o impulso. | De 0,01 a 1.000. |
| `ship.dead_zone` | Arraste mínimo para aceitar um impulso. | De 0,01 a 1.000 unidades lógicas. Deve ser menor que `ship.max_drag`. |
| `ship.max_drag` | Arraste que atinge intensidade máxima. | De 0,01 a 1.000 unidades lógicas; maior que `dead_zone`. |
| `ship.max_impulse` | Impulso máximo aplicado à nave. | De 0,01 a 1.000. |
| `start.body_id` | ID do planeta/satélite de partida. | Deve apontar para um corpo seguro existente. |
| `start.angle_degrees` | Direção radial da posição inicial. | De −360 a 360 graus; zero aponta à direita e −90 aponta para cima. |
| `tutorial` | Instrução curta exibida no jogo. | Texto opcional. |
| `notes` | Anotações de autoria. | Texto opcional. |

As grandezas de mundo são unidades convencionais do protótipo, não quilômetros ou metros astronômicos em escala real. Combustível é uma contagem abstrata. `dead_zone` e `max_drag` usam unidades lógicas de tela; os demais valores posicionais e raios usam unidades do mundo.

### Propriedades de um corpo e da Terra

| Campo | O que controla | Regra principal |
| --- | --- | --- |
| `id` | Referência estável do objeto. | Texto não vazio; sem duplicatas entre corpos e Terra. |
| `type` | Aparência e classe física do corpo. | `planet`, `satellite`, `sun` ou `asteroid`. A Terra fica em `goal` e não tem `type`. |
| `position.x/y` | Centro no mapa. | Coordenadas finitas dentro de ±1.000.000. |
| `mass` | Fonte de atração gravitacional. | De 0 a 1.000.000; asteroide e Terra exigem zero. |
| `visual_radius` | Raio do desenho. | Positivo até 1.000.000. |
| `collision_radius` | Raio da superfície física. | Positivo até 1.000.000. |
| `capture_radius` | Zona de pouso ou chegada. | 0 a 1.000.000; apoio e Terra exigem pelo menos o raio de colisão; perigos exigem zero. |
| `danger_radius` | Zona fatal. | 0 a 1.000.000; Sol/asteroide exigem pelo menos o raio de colisão; apoio/Terra exigem zero. |
| `proximity_radius` | Zona do aviso de proximidade. | Positivo, até 1.000.000, e pelo menos o maior raio de contato pertinente. |

Para um corpo seguro, `capture_radius` deve cobrir `collision_radius` e `danger_radius` fica em zero. Para Sol ou asteroide, `danger_radius` cobre `collision_radius` e `capture_radius` fica em zero. A Terra é configurada em **Terra** e segue as regras de destino indicadas acima.

Trocar o tipo de um corpo não recalcula seus outros valores. Depois da troca, ajuste massa, captura, perigo e os raios conscientemente. Por exemplo, mudar um planeta para asteroide não zera automaticamente a massa nem cria uma configuração fatal válida.

## 6. Validar a fase

O editor valida automaticamente após as alterações e também oferece o botão **Validar**. Os resultados aparecem abaixo do mapa.

- **ERRO** bloqueia salvar e testar. O diagnóstico informa o campo ou objeto, por exemplo `start.body_id`, um ID duplicado ou um número fora do limite.
- **AVISO** não bloqueia. Ele aponta uma situação geométrica que merece inspeção, mas não determina sozinho que a fase é impossível.
- **Dados válidos para teste** significa que o JSON passou pelo carregador; não prova que exista uma rota solucionável ou divertida.

O validador bloqueia, entre outros casos:

- JSON malformado, versão de schema incompatível ou propriedades essenciais ausentes;
- campos obrigatórios vazios, números não finitos, valores ou raios fora das regras;
- IDs duplicados, tipo não suportado ou referência inicial sem corpo seguro correspondente;
- nave inicial fora dos limites, dentro de outro contato ou partida em zona incompatível;
- Terra fora do mundo ou sobreposição incompatível entre zonas expandidas pelo raio da nave.

O validador avisa sobre corpos fora dos limites, objetos com visuais sobrepostos e passagens estreitas para a nave. Revise também se os alertas de proximidade fazem sentido, se o destino fica visível e se os corpos não ocultam o ponto inicial. O editor não mede dificuldade, não verifica uma solução completa nem executa análise de desempenho.

## 7. Salvar, abrir e proteger alterações

### Salvar

- **Salvar** grava no arquivo atualmente aberto. Para uma fase nova, ele abre o diálogo **Salvar como…**.
- **Salvar como…** escolhe o arquivo de destino. O diálogo filtra arquivos `.json` e começa em `Recursos/Fases/`.
- A gravação valida os dados antes. Se houver erros, nada é salvo e os diagnósticos aparecem no painel.
- Antes de substituir um arquivo existente, confirme a sobrescrita no diálogo do sistema.
- O editor escreve primeiro um temporário junto ao arquivo de destino e só então o renomeia para o destino. Uma falha de escrita ou substituição mantém os dados autorais anteriores.

Os valores numéricos são gravados com precisão completa. A formatação, a indentação e a ordem das chaves podem mudar; campos adicionais preservados pelo JSON continuam nos dados. O editor não mantém comentário JSON, pois comentários não fazem parte do formato JSON padrão.

### Abrir e alterações pendentes

**Abrir…** carrega um JSON existente usando o mesmo validador do jogo. Se a leitura, o JSON ou a validação falhar, a edição corrente permanece no painel e o diagnóstico informa o erro.

Se tentar abrir outro arquivo ou criar outra fase com mudanças pendentes, escolha:

- **Salvar**: grava primeiro a fase atual e só continua se a gravação der certo.
- **Descartar**: abandona as mudanças ainda não salvas e executa a ação solicitada.
- **Cancelar**: permanece na edição atual.

Cancelar o diálogo de seleção de arquivo ou o diálogo de gravação também cancela a troca pendente. O ponto `●` junto do caminho ou do título **Nova fase** indica que o conteúdo difere da última gravação.

### Rascunho de sessão

O plugin guarda um rascunho local em `.godot/orbt-editor-sessao.json`, incluindo os dados em edição, arquivo associado e seleção. Isso permite reabrir o editor com a sessão anterior, mas o rascunho **não substitui Salvar**: mantenha uma cópia `.json` na pasta de projeto. Arquivos sob `.godot/` são locais e ignorados pelo Git; não são incluídos no APK.

## 8. Testar uma fase e voltar ao editor

1. Salve a fase para manter um arquivo autoral recuperável.
2. Confira que não há erros e clique em **Testar fase**. O botão fica desabilitado enquanto o carregador encontrar erros.
3. O plugin escreve os dados atuais em `.godot/orbt-editor-preview.json`, uma cópia temporária separada do JSON autoral.
4. O teste recarrega e valida essa cópia e cria a mesma cena de nível usada pelo jogo. Jogue para verificar controles, gravidade, tempo, pouso, perigos, derrota e vitória.
5. Clique em **Voltar ao editor** no rodapé da cena de teste. Você também pode usar `Esc` ou `F8` para encerrar a execução.
6. Se a Godot permanecer na aba **Jogo**, selecione novamente **ORBT Fases**. A edição e a seleção continuam no painel.

O teste não inicia a campanha, não altera o catálogo, não conclui ou desbloqueia fases e não usa o serviço de progresso do jogador. Movimento, combustível, vitória e derrota pertencem à tentativa temporária e não escrevem no JSON autoral. Encerre uma execução em andamento antes de iniciar outro teste; se o editor informar isso, pare a cena atual e tente novamente.

## 9. Disponibilizar a fase no jogo

Depois de validar e testar a fase:

1. Confira que o `id` dentro do arquivo é único e combine com o ID de catálogo escolhido.
2. Mantenha o arquivo em `Recursos/Fases/` e salve.
3. Abra `Recursos/Niveis.json` num editor de texto e adicione o par de ID e caminho `res://` correspondente, por exemplo:

   ```json
   {
     "teste_001": "res://Recursos/Fases/teste_001.json",
     "orbita_inicial": "res://Recursos/Fases/orbita_inicial.json"
   }
   ```

4. Garanta que a vírgula e as aspas estejam corretas e que o caminho aponte ao arquivo salvo.
5. Execute o projeto pela cena principal. A tela de seleção lê o catálogo, ordena por `order` e depois por ID. A primeira fase fica disponível; as demais dependem do progresso persistido, então confira o estado ao testar uma campanha nova.

O editor grava fases individuais; ele não altera `Recursos/Niveis.json`, não cria progresso e não muda o ID da fase automaticamente quando você renomeia o arquivo. O carregador do jogo volta a validar o arquivo escolhido ao abrir a fase.

## 10. Problemas comuns

| Sintoma | Causa provável | Como resolver |
| --- | --- | --- |
| **ORBT Fases** não aparece na barra superior. | Projeto aberto sem terminar importação ou plugin desativado. | Aguarde a importação; em **Projeto > Configurações do Projeto > Plugins**, habilite **ORBT Fases**. |
| O editor abre o exemplo em vez da última fase. | Não havia rascunho recuperável ou a sessão foi limpa. | Use **Abrir…** para selecionar o JSON autoral; mantenha o arquivo salvo em `Recursos/Fases/`. |
| **Salvar** não cria o arquivo. | Há erros de validação ou o destino não está disponível. | Leia os itens `ERRO`, corrija-os e salve novamente; confirme a pasta e a extensão `.json`. |
| Alterações sumiram quando abri outro arquivo. | Foi escolhido **Descartar** no diálogo de alterações pendentes. | Reabra a última versão salva; o rascunho local não substitui uma gravação autoral. |
| Uma troca para Sol/asteroide cria erro. | Trocar o tipo não ajusta massa e zonas automaticamente. | Configure `mass`, `capture_radius`, `danger_radius` e raios de acordo com as regras da tabela. |
| A nave inicial não aparece onde esperado. | `start.body_id` está incorreto ou `start.angle_degrees` usa direção diferente. | Selecione **Fase**, escolha um apoio existente e confira o ângulo; zero aponta à direita e −90 para cima. |
| O teste fica bloqueado. | Existe ao menos um erro bloqueante ou outra execução ainda está ativa. | Corrija os erros indicados e encerre a execução aberta antes de testar outra vez. |
| A fase valida, mas a rota não funciona. | A validação verifica estrutura e geometria, não prova solução ou dificuldade. | Teste a rota manualmente, ajuste posições/parâmetros e peça a outra pessoa para reproduzir. |
| Arquivo JSON autoral foi salvo, mas não aparece na campanha. | O catálogo `Recursos/Niveis.json` não aponta para ele ou o estado está bloqueado. | Acrescente o ID/caminho ao catálogo e confira a progressão da campanha. |

## 11. Escopo e limitações atuais

O editor não oferece tela dedicada para gerenciar o catálogo, importar imagens, colocar decoração, animar corpos, alterar unidades ou editar regras de rotação, órbitas e portais. `tutorial` e `notes` são campos de texto, mas `notes` é apenas dado autoral. Os avisos geométricos são orientações; não substituem o playtest.

O plugin é uma ferramenta da Godot no projeto de desenvolvimento. Ele deve poder ser desativado sem afetar a execução do jogo; o plugin e a cena auxiliar de teste ficam fora da exportação Android.

## 12. Roteiro de reprodução para outra pessoa

Use uma cópia do projeto e registre a versão da Godot e a revisão testada:

1. Abra **ORBT Fases** e crie uma fase.
2. Mude nome, ID, combustível e tempo; insira um planeta e um asteroide, mova um objeto e confira os raios.
3. Apague temporariamente o apoio inicial e confirme que a validação acusa `start.body_id`; escolha **Descartar** ou desfaça a edição sem gravar a referência inválida.
4. Salve como um arquivo novo em `Recursos/Fases/`, feche e reabra o projeto, abra o mesmo arquivo e compare ID, nome e parâmetros.
5. Faça uma edição e tente abrir outro arquivo; exercite **Cancelar**, **Descartar** e **Salvar**.
6. Teste uma fase válida, conclua ou perca e volte ao editor; confira que a edição autoral e o progresso real continuam intactos.
7. Registre passos, resultado esperado e observado, versão/revisão e uma captura.

## Referências do projeto

- [Regras de jogabilidade do protótipo](../regras-de-negocio/jogabilidade.md)
- [Contrato JSON e modelo de simulação](../tecnica/fases-e-simulacao.md)
- [Guia técnico do plugin e testes](../tecnica/editor-de-fases.md)
- [Catálogo e progressão da campanha](../tecnica/campanha.md)
- [Regras de acesso e progressão](../regras-de-negocio/campanha.md)
- [Estado atual e continuidade](estado-da-branch.md)
