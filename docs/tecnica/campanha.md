# Campanha — catálogo, carregamento e persistência

Atualizado em 29/10/2026. Seleção #5/#38–#41 integrada pelo PR #44 em `fcd576b`; progresso persistente da #40 integrado pelo PR #46 em `a774a82`, incluindo a identidade visual do PR #45. Os quatro critérios da #40 foram demonstrados no Windows, com [evidências e reprodução](../auxiliar/validacao-issue-40.md). Godot 4.7.2, retrato, coordenadas lógicas do projeto. Revisão das imagens continua adiada; aceite integrado Android de #4/#38 permanece pendente. Estado e continuidade: [estado-da-branch.md](../auxiliar/estado-da-branch.md).

Os fluxos de navegação, bloqueio, conclusão e repetição estão nas [regras da campanha](../regras-de-negocio/campanha.md). Esta página registra seus contratos e detalhes de implementação.

## Apresentação da seleção

Os nomes quebram linha e a lista rola para acomodar dez ou mais itens. Os botões de escolha têm 48 unidades lógicas de altura; a ergonomia real ainda precisa ser testada no telefone. A interface aplica a transformação da área segura e se atualiza após redimensionamento/alterações das margens do Android. Rótulos e ações de cada estado seguem as [regras de acesso às fases](../regras-de-negocio/campanha.md#acesso-conclusão-e-repetição).

O catálogo real contém dez fases: `teste_001`, `salto_curto`, `na_diagonal`, `curva_suave`, `escala_segura`, `entre_asteroides`, `contorno`, `duas_rotas`, `portas_gemeas` e `retorno_a_terra`. Capturas com dados temporários continuam separadas do catálogo real.

## Catálogo e carregamento

Mantém-se o contrato `Recursos/Niveis.json`: objeto que associa ID estável a caminho `res://Recursos/Fases/*.json`. Nome e ordem vêm dos metadados do arquivo de fase. Ordenação por `order`, com desempate pelo ID. Renomear/reordenar não muda a identidade do progresso. Um arquivo referenciado mais de uma vez, caminho inválido, ausência, erro JSON ou metadados inconsistentes invalida a lista inteira com diagnóstico; o carregador não retorna uma campanha parcial.

`src/Campanha/catalogo.gd` lê JSON para extrair somente ID, nome, ordem e arquivo. Não constrói recursos físicos ou simulações de todas as fases. Ao escolher, `GerenciadorDeNivel` relê o arquivo escolhido e usa `CarregadorFase`, inclusive para versões, geometria e referências. Arquivos podem ter metadados válidos e regras físicas inválidas: nesse caso, a abertura falha com diagnóstico sem instalar mundo parcial. A atualização relê os arquivos, permitindo nova tentativa após a correção autoral.

A autorização é conferida no controlador antes de chamar o carregador, além do bloqueio na interface. Pedidos repetidos são bloqueados enquanto a escolha está em processamento. O toque termina na GUI antes de instalar a nave. Trocas/retornos cancelam a entrada, param a nave e liberam o mundo anterior. Uma tentativa nova recebe posição, combustível, tempo, contatos e câmera iniciais; repetição não recupera estado de voo.

## Progresso persistente

`src/Campanha/progresso_persistente.gd` usa o mesmo contrato da base em memória `progresso_sessao.gd`. Conclusões e liberações são conjuntos identificados pelo ID estável da fase. A transição de conclusão é idempotente; a configuração libera o primeiro item do catálogo e reconcilia a sucessora de cada fase já concluída. Isso permite expandir uma campanha sem bloquear quem concluiu a antiga última fase. A reconciliação de um save válido é gravada com o mesmo mecanismo de backup e retentativa; a primeira configuração sem save continua sem gravar. A conclusão libera o seguinte quando ele existe. O comportamento percebido pelo jogador está nas [regras de progressão](../regras-de-negocio/campanha.md#acesso-conclusão-e-repetição).

O serviço grava `user://progresso.json`, separado dos JSONs autorais. Formato v1: `schema_version`, `geracao`, arrays de IDs `concluidas`/`liberadas` e checksum SHA-256 do conteúdo canônico. Valida versão, tipos, IDs únicos, referências entre os conjuntos e integridade. IDs ausentes do catálogo atual são preservados no save; o controlador só abre IDs presentes no catálogo e autorizados. Alterar o conteúdo de uma fase não apaga conquistas do mesmo ID.

A gravação escreve e relê `.tmp`, preserva o último save válido em `.bak` por `.bak.tmp`, e então substitui o principal. Temporário interrompido não é adotado. Principal inválido recupera o backup válido; uma nova vitória pode voltar a gravar. Versão incompatível ou ambos os arquivos inválidos são preservados, sem sobrescrita automática; o serviço mantém uma sessão temporária e fornece o aviso ao controlador. Em falha de disco, os conjuntos atualizados permanecem em memória e o serviço informa o salvamento pendente e a possibilidade de retentativa. Recuperação por backup pode perder a última alteração que não chegou a ser gravada. Avisos e ações correspondentes estão nas [regras de salvamento](../regras-de-negocio/campanha.md#salvamento-e-recuperação).

O contrato continua com `configurar(itens)`, `estado(id)`, `pode_abrir(id)` e `concluir(id, itens)`. `ControladorJogo.persistir_progresso` vem habilitado; testes o desativam ou fornecem caminhos isolados de progresso, checkpoint e preferências antes de entrar na árvore. O teste do editor instancia o nível diretamente e não lê/grava progresso real. Checkpoint e Continuar são tratados separadamente pela #49; balanceamento e revisão cruzada permanecem na #53.

Na #51, o menu é a entrada também no Android. Antes de oferecer Continuar, valida-se checkpoint e acesso à fase; incompatibilidade gera diagnóstico e opção explícita de descarte. A próxima fase é resolvida pela ordem do catálogo, após a conclusão desbloquear a sucessora; na última não há botão Próxima. Transições removem a cena anterior e interrompem sua simulação. Créditos registram colaboradores identificados no histórico, Godot/MIT, origem dos sprites e a pendência de autoria/licença da propulsão legada. Ver [validação dos menus](../auxiliar/validacao-issue-51.md).

As preferências da #50 usam `user://preferencias.json`, separadas do progresso e do checkpoint, com `schema_version`, `musica` e `efeitos` entre 0 e 1. Valores ausentes, inválidos ou incompatíveis usam padrão 1; falha de gravação informa o jogador e mantém a escolha na sessão. A gravação usa arquivo temporário antes da substituição. Os canais Godot `Musica` e `Efeitos` são criados se necessário e enviados a `Master`, com volume linear convertido para dB e canal silenciado em zero. A #55 deve direcionar cada reprodutor ao canal correspondente; nenhum áudio foi produzido nesta tarefa.

## Fases autorais e rotas de referência

As cinco fases adicionais usam `NIVEL_1` até `NIVEL_5` de `dev-macb/orbt/src/levels/__init__.py` como modelo. Os IDs e arquivos já cadastrados foram preservados para manter o progresso. `scripts/importar_fases_modelo.py` converte os dados por AST restrita, sem importar nem executar o projeto externo; as linhas de rochas mantêm o mesmo jitter determinístico. Para reproduzir, passe o caminho do `__init__.py` ao script.

Os mapas mantêm coordenadas e raios 1:1, mundo de 900×600 com margem de 200 unidades, nave de raio 6 e impulso máximo 260. `gravity_constant=500` e massas multiplicadas por 1.000 preservam o produto GM do original. A suavização é 1 no contrato atual. Os 44/58/68/59/60 asteroides de cada mapa incluem a cerca perimetral original. Nos sóis, o campo original `danger_radius` representa o anel visual; o contato fatal usa o raio da estrela, assim como na colisão do Python.

Órbitas foram adaptadas para posições autorais estáticas, e o portal opcional da última fase foi omitido. A adaptação preserva a composição dos mapas e usa as regras de voo, pouso e correção da Godot. A câmera de voo usa zoom 0,5; explorar enquadra o mapa entre o HUD e o rodapé, com recálculo ao redimensionar.

`tests/test_fases.gd` percorre as dez fases pelo controlador de produção, confere desbloqueio, consumo e correspondência entre prévia e voo. Nos mapas adaptados também confere quantidade de rochas, início livre e câmera. As variações de mira são combinadas independentemente por etapa. Cada trecho até contato tem limite de vinte segundos no teste; os mapas adaptados usam 30 s por impulso.

| ID / mapa | Rota de referência | Tempo aproximado | Saldo final |
| --- | --- | --- | --- |
| `teste_001` / Primeiro impulso | Impulso `(0, -80)` | 2,12 s | 4 |
| `salto_curto` / Tutorial | 260 a −14,5° | 1,73 s | 2 |
| `na_diagonal` / O Estilingue | 260 a −0,7° | 2,95 s | 2 |
| `curva_suave` / O Labirinto | 260 a −40° até `apoio_1`; cerca de +10,49° até `apoio_2`; cerca de +45,19° até Terra | 3,55 s | 0 |
| `escala_segura` / O Sol | 260 a +11,7° | 2,68 s | 2 |
| `entre_asteroides` / Deriva Final | 260 a +18°; após 90 passos (1,5 s), corrigir com 130 a −50° | 2,45 s | 3 |
| `contorno` / O Contorno | 100 a −15°; após 120 passos, 80 a +100° | teste automatizado | 1 |
| `duas_rotas` / Duas Rotas | 100 a −25° e 80 a +90° após 120 passos; alternativa: +25° e −90° | teste automatizado | 1 |
| `portas_gemeas` / Portas Gêmeas | 100 a +65° e 80 a +180° após 120 passos; alternativa: +115° e 0° | teste automatizado | 1 |
| `retorno_a_terra` / Retorno à Terra | 100 a −40°; após 120 passos, 80 a +75° | teste automatizado | 2 |

Os ângulos estão em coordenadas de mundo: zero aponta à direita e valores positivos, para baixo. No Labirinto, a mira é reajustada conforme o ponto efetivo do pouso; o teste usa o ângulo radial do primeiro pouso ×0,137−1,43° no segundo lançamento e a direção da Terra +7° no terceiro. Isso é apenas uma rota de validação, sem piloto automático no produto. Margens verificadas: Tutorial ±0,5°, Estilingue ±0,4°, Labirinto ±0,5°/±0,25°/±1°, Sol ±0,5° e Deriva ±1° em ambos os impulsos. A prévia permite escolher trajetórias alternativas.

As dicas do campo `tutorial` são exibidas no HUD antes do lançamento e durante o pouso. Os cinco arquivos estão cadastrados em `Recursos/Niveis.json`. O preset Android já inclui `Recursos/Fases/*.json`. O teste de rotas pode ser executado externamente contra o PCK, assim como `tests/test_exportacao.gd`.

## Evidências e aceite pendente

Na adaptação dos cinco mapas Python, também em 29/10/2026, passaram **923 verificações**: 660 da suíte local completa, 240 de rotas no PCK isolado e 23 de recursos/campanha no PCK. As cinco vistas gerais e os enquadramentos de voo/exploração foram inspecionados no OpenGL real, incluindo espaço entre mapa, HUD e rodapé. O resultado valida a adaptação estática no desktop; não representa teste de APK em aparelho.

Em 29/10/2026, a validação para integração na `alpha` passou em **383 verificações**, incluindo 28 de persistência, nove de reabertura do controlador em outro processo, 23 do PCK isolado e 11 do ciclo do plugin. O [registro de aceite da #40](../auxiliar/validacao-issue-40.md) apresenta revisão, passos, resultados e saída da execução. A primeira vitória, a repetição, o bloqueio, a restauração e a última fase foram exercitados com o serviço real de disco e duas fases temporárias.

Em 22/10/2026, Godot 4.7.2 / Windows:

- `tests/run.ps1`: 69 controles, 142 partida, 32 editor, 31 campanha, 38 visuais e 24 persistência, todos passando.
- `tests/run_exportacao.ps1`: 23 verificações no pacote isolado, incluindo gravação e restauração reais e recursos da arte; todas passando. Total integrado: **359**. Não equivale a APK/aparelho.
- `tests/test_persistencia.gd`: reabertura em processo separado, backup, truncamento, temporário incompleto, checksum alterado, versão futura, falha de disco e retentativa. Usa caminhos temporários e preserva os saves reais. O pacote exportado também usa arquivo exclusivo de teste e o remove ao terminar.

A suíte da campanha usa dois JSONs temporários com combustíveis distintos e verifica ordenação, renomeação, atualização sem duplicação, bloqueio direto antes do carregamento, vitória/liberação idempotente, última fase, repetição, troca de mundos, retorno da pausa, erro de arquivo e navegação. Os temporários são removidos ao terminar; arquivos autorais são preservados.

Para validar no aparelho: registrar modelo/Android/Godot/revisão/APK; concluir uma fase, fechar completamente o aplicativo, reabrir e conferir conclusão/liberação; repetir e confirmar saldo inicial. Usar as dez fases para conferir bloqueio e próximas fases. Os testes de falhas também usam catálogos temporários. Verificar comportamento sem espaço para gravação e recuperação da cópia anterior. O aceite de reabertura no Android permanece pendente; desktop e PCK não o substituem.
