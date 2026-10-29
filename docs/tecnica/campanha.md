# Campanha — catálogo, carregamento e persistência

Atualizado em 29/10/2026. Seleção #5/#38–#41 integrada pelo PR #44 em `fcd576b`; progresso persistente da #40 integrado pelo PR #46 em `a774a82`, incluindo a identidade visual do PR #45. Os quatro critérios da #40 foram demonstrados no Windows, com [evidências e reprodução](../auxiliar/validacao-issue-40.md). Godot 4.7.2, retrato, coordenadas lógicas do projeto. Revisão das imagens continua adiada; aceite integrado Android de #4/#38 permanece pendente. Estado e continuidade: [estado-da-branch.md](../auxiliar/estado-da-branch.md).

Os fluxos de navegação, bloqueio, conclusão e repetição estão nas [regras da campanha](../regras-de-negocio/campanha.md). Esta página registra seus contratos e detalhes de implementação.

## Apresentação da seleção

Os nomes quebram linha e a lista rola para acomodar dez ou mais itens. Os botões de escolha têm 48 unidades lógicas de altura; a ergonomia real ainda precisa ser testada no telefone. A interface aplica a transformação da área segura e se atualiza após redimensionamento/alterações das margens do Android. Rótulos e ações de cada estado seguem as [regras de acesso às fases](../regras-de-negocio/campanha.md#acesso-conclusão-e-repetição).

O catálogo real contém uma fase. As dez fases usadas na captura são dados visuais de teste, não conteúdo de campanha entregue.

## Catálogo e carregamento

Mantém-se o contrato `Recursos/Niveis.json`: objeto que associa ID estável a caminho `res://Recursos/Fases/*.json`. Nome e ordem vêm dos metadados do arquivo de fase. Ordenação por `order`, com desempate pelo ID. Renomear/reordenar não muda a identidade do progresso. Um arquivo referenciado mais de uma vez, caminho inválido, ausência, erro JSON ou metadados inconsistentes invalida a lista inteira com diagnóstico; o carregador não retorna uma campanha parcial.

`src/Campanha/catalogo.gd` lê JSON para extrair somente ID, nome, ordem e arquivo. Não constrói recursos físicos ou simulações de todas as fases. Ao escolher, `GerenciadorDeNivel` relê o arquivo escolhido e usa `CarregadorFase`, inclusive para versões, geometria e referências. Arquivos podem ter metadados válidos e regras físicas inválidas: nesse caso, a abertura falha com diagnóstico sem instalar mundo parcial. A atualização relê os arquivos, permitindo nova tentativa após a correção autoral.

A autorização é conferida no controlador antes de chamar o carregador, além do bloqueio na interface. Pedidos repetidos são bloqueados enquanto a escolha está em processamento. O toque termina na GUI antes de instalar a nave. Trocas/retornos cancelam a entrada, param a nave e liberam o mundo anterior. Uma tentativa nova recebe posição, combustível, tempo, contatos e câmera iniciais; repetição não recupera estado de voo.

## Progresso persistente

`src/Campanha/progresso_persistente.gd` usa o mesmo contrato da base em memória `progresso_sessao.gd`. Conclusões e liberações são conjuntos identificados pelo ID estável da fase. A transição de conclusão é idempotente; a configuração libera o primeiro item do catálogo e a conclusão libera o seguinte quando ele existe. O comportamento percebido pelo jogador está nas [regras de progressão](../regras-de-negocio/campanha.md#acesso-conclusão-e-repetição).

O serviço grava `user://progresso.json`, separado dos JSONs autorais. Formato v1: `schema_version`, `geracao`, arrays de IDs `concluidas`/`liberadas` e checksum SHA-256 do conteúdo canônico. Valida versão, tipos, IDs únicos, referências entre os conjuntos e integridade. IDs ausentes do catálogo atual são preservados no save; o controlador só abre IDs presentes no catálogo e autorizados. Alterar o conteúdo de uma fase não apaga conquistas do mesmo ID.

A gravação escreve e relê `.tmp`, preserva o último save válido em `.bak` por `.bak.tmp`, e então substitui o principal. Temporário interrompido não é adotado. Principal inválido recupera o backup válido; uma nova vitória pode voltar a gravar. Versão incompatível ou ambos os arquivos inválidos são preservados, sem sobrescrita automática; o serviço mantém uma sessão temporária e fornece o aviso ao controlador. Em falha de disco, os conjuntos atualizados permanecem em memória e o serviço informa o salvamento pendente e a possibilidade de retentativa. Recuperação por backup pode perder a última alteração que não chegou a ser gravada. Avisos e ações correspondentes estão nas [regras de salvamento](../regras-de-negocio/campanha.md#salvamento-e-recuperação).

O contrato continua com `configurar(itens)`, `estado(id)`, `pode_abrir(id)` e `concluir(id, itens)`. `ControladorJogo.persistir_progresso` vem habilitado; testes o desativam ou fornecem `caminho_progresso` isolado antes de entrar na árvore. O teste do editor instancia o nível diretamente e não lê/grava progresso real. Checkpoints de pouso, retomar uma tentativa em pausa, preferências, dez fases autorais e menus completos continuam pendentes; esta entrega cobre progresso da campanha, não todo o RF18.

## Evidências e aceite pendente

Em 29/10/2026, a validação para integração na `alpha` passou em **383 verificações**, incluindo 28 de persistência, nove de reabertura do controlador em outro processo, 23 do PCK isolado e 11 do ciclo do plugin. O [registro de aceite da #40](../auxiliar/validacao-issue-40.md) apresenta revisão, passos, resultados e saída da execução. A primeira vitória, a repetição, o bloqueio, a restauração e a última fase foram exercitados com o serviço real de disco e duas fases temporárias.

Em 22/10/2026, Godot 4.7.2 / Windows:

- `tests/run.ps1`: 69 controles, 142 partida, 32 editor, 31 campanha, 38 visuais e 24 persistência, todos passando.
- `tests/run_exportacao.ps1`: 23 verificações no pacote isolado, incluindo gravação e restauração reais e recursos da arte; todas passando. Total integrado: **359**. Não equivale a APK/aparelho.
- `tests/test_persistencia.gd`: reabertura em processo separado, backup, truncamento, temporário incompleto, checksum alterado, versão futura, falha de disco e retentativa. Usa caminhos temporários e preserva os saves reais. O pacote exportado também usa arquivo exclusivo de teste e o remove ao terminar.

A suíte da campanha usa dois JSONs temporários com combustíveis distintos e verifica ordenação, renomeação, atualização sem duplicação, bloqueio direto antes do carregamento, vitória/liberação idempotente, última fase, repetição, troca de mundos, retorno da pausa, erro de arquivo e navegação. Os temporários são removidos ao terminar; arquivos autorais são preservados.

Para validar no aparelho: registrar modelo/Android/Godot/revisão/APK; concluir uma fase, fechar completamente o aplicativo, reabrir e conferir conclusão/liberação; repetir e confirmar saldo inicial. Usar duas fases autorais para conferir bloqueio e próxima fase. O catálogo real ainda tem uma fase; testes automatizados usam duas/três fases de dados. Verificar comportamento sem espaço para gravação e recuperação da cópia anterior. O aceite de reabertura no Android permanece pendente; desktop e PCK não o substituem.
