# Campanha e seleção de fases — M2

Implementação de #5/#38–#41 sobre o PR #43 do editor, integrado à `main` em `45466e2`. Godot 4.7.2, retrato, coordenadas lógicas do projeto. O aceite Android de #4 permanece pendente.

## Fluxo

No computador, **Campanha** abre a seleção. No Android, a primeira fase do catálogo continua abrindo diretamente, preservando o fluxo de M1. **Seleção de fases**, no HUD da partida, permite retornar a qualquer momento; a tentativa anterior é descartada. A seleção oferece **Atualizar lista** e **Voltar ao menu**. Não existe comando Continuar por checkpoint.

Cada cartão mostra ordem, nome e estado por texto: **Bloqueada**, **Disponível** ou **Concluída**. Fases concluídas têm ação **Repetir**. Os nomes quebram linha e a lista rola para acomodar dez ou mais itens. Os botões de escolha têm 48 unidades lógicas de altura; a ergonomia real ainda precisa ser testada no telefone. A interface aplica a transformação da área segura e se atualiza após redimensionamento/alterações das margens do Android.

O catálogo real contém uma fase. As dez fases usadas na captura são dados visuais de teste, não conteúdo de campanha entregue.

## Catálogo e carregamento

Mantém-se o contrato `Recursos/Niveis.json`: objeto que associa ID estável a caminho `res://Recursos/Fases/*.json`. Nome e ordem vêm dos metadados do arquivo de fase. Ordenação por `order`, com desempate pelo ID. Renomear/reordenar não muda a identidade do progresso. Um arquivo referenciado mais de uma vez, caminho inválido, ausência, erro JSON ou metadados inconsistentes invalida a lista inteira com diagnóstico; evita-se avançar em uma campanha parcial. Catálogo vazio mostra estado vazio com retorno acessível.

`src/Campanha/catalogo.gd` lê JSON para extrair somente ID, nome, ordem e arquivo. Não constrói recursos físicos ou simulações de todas as fases. Ao escolher, `GerenciadorDeNivel` relê o arquivo escolhido e usa `CarregadorFase`, inclusive para versões, geometria e referências. Arquivos podem ter metadados válidos e regras físicas inválidas: nesse caso, a abertura falha e a seleção mostra o diagnóstico sem instalar mundo parcial. **Atualizar lista** permite tentar após corrigir arquivos.

A autorização é conferida no controlador antes de chamar o carregador, além do bloqueio na interface. Pedidos repetidos são bloqueados enquanto a escolha está em processamento. O toque termina na GUI antes de instalar a nave. Trocas/retornos cancelam a entrada, param a nave e liberam o mundo anterior. Uma tentativa nova recebe posição, combustível, tempo, contatos e câmera iniciais; repetição não recupera estado de voo.

## Progresso e limite de entrega

`src/Campanha/progresso_sessao.gd` é o adaptador de M2, explicitamente sem leitura ou gravação de saves. A primeira fase é liberada; vitória da partida atual conclui o ID e libera a seguinte uma única vez. Repetir não duplica a liberação. A última fase não cria ID seguinte. Retornar ao menu preserva a sessão; fechar o aplicativo reinicia o progresso. A seleção informa isso ao jogador.

O serviço de M3 deverá fornecer `configurar(itens)`, `estado(id)`, `pode_abrir(id)` e `concluir(id, itens)` com progresso por ID e gravação recuperável. Este adaptador não dá aceite ao requisito de vitória persistida/reabertura da #40. Checkpoints, save real, produção de dez fases e menus completos continuam fora da entrega. O teste do editor instancia o nível diretamente, sem habilitar navegação da campanha ou alterar seu progresso.

## Evidências e aceite pendente

Em 22/10/2026, Godot 4.7.2 / Windows:

- `tests/run.ps1`: 69 verificações de controles, 142 de partida, 32 de editor e 31 de campanha, todas passando.
- `tests/run_exportacao.ps1`: 15 verificações no pacote isolado, incluindo seleção, conclusão e repetição da fase; todas passando. Não equivale a APK/aparelho.
- `tests/capturar_campanha.gd`: capturas em `.godot/campanha.png`, `.godot/campanha-dez-fases.png` e `.godot/menu-campanha.png`, inspecionadas com renderizador Compatibility no desktop.

A suíte da campanha usa dois JSONs temporários com combustíveis distintos e verifica ordenação, renomeação, atualização sem duplicação, bloqueio direto antes do carregamento, vitória/liberação idempotente, última fase, repetição, troca de mundos, retorno da pausa, erro de arquivo e navegação. Os temporários são removidos ao terminar; arquivos autorais são preservados.

Para validar no aparelho: registrar modelo/Android/Godot/revisão/APK; abrir a seleção pelo HUD, rolar nomes longos, tentar fase bloqueada, tocar rapidamente, completar/repetir e voltar durante pausa. Testar margens e alvos pelo polegar. Confirmar reinício de progresso ao fechar nesta versão. Após M3, repetir o roteiro comprovando persistência real. Não encerrar os critérios Android/persistentes por inferência a partir dos testes desktop.
