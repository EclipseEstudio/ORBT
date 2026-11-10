# Catálogo e persistência

Fonte: `src/Campanha/`, `src/ControladorJogo/controlador_jogo.gd` e `src/Configuracoes/preferencias.gd`. Regras do jogador: [campanha](../regras-de-negocio/campanha.md).

## Catálogo e abertura

`Recursos/Niveis.json` mapeia ID para caminho `res://Recursos/Fases/*.json`. `catalogo.gd` rejeita caminhos fora dessa pasta, `..`, arquivos duplicados, ID divergente, nome vazio e ordem inválida. Ordena por ordem/ID e conta estrelas por cor. Qualquer erro esvazia a lista: um catálogo parcial não muda silenciosamente a progressão.

Ao abrir a seleção, o controlador relê o catálogo e chama `progresso.configurar()`. Ao abrir uma fase, verifica `pode_abrir()` e valida o arquivo pelo carregador. As duas verificações são distintas: metadados válidos no catálogo não substituem validação física.

`progresso_sessao.gd` implementa regras em memória; `progresso_persistente.gd` estende com disco. `pode_abrir()` exige todos os predecessores concluídos e cada bloco anterior com suas douradas completas. Um save com liberações extras não contorna os portões.

## Arquivos de usuário

| Arquivo | Esquema escrito | Conteúdo |
| --- | --- | --- |
| `user://progresso.json` | 3 | `geracao`, `concluidas`, `liberadas`, `melhores_estrelas`, `melhores_azuis`, `checksum` |
| `user://checkpoint.json` | 1 | Envelope `checkpoint` e checksum; conteúdo inclui `content_version` |
| `user://preferencias.json` | 2 | `musica`, `efeitos`, `vibracao`, `dicas` |

O progresso lê versões 1–3 e migra antigas após validar checksum. Recordes são por ID estável e cor; vitória chama `concluir_com_coletas()`. A interface soma somente itens do catálogo, limitando ao total autoral. O método genérico `total_estrelas()` do serviço soma o dicionário e não deve substituir essa filtragem visual.

Progresso/checkpoint usam `.tmp`, `.bak.tmp`, `.bak` e conferência antes da substituição. A geração e os dados válidos orientam recuperação de progresso. Esquemas desconhecidos bloqueiam sobrescrita. Falha mantém estado pendente e aviso; retentativa exige sucesso de gravação para retirar o aviso. Preferências usam temporário/renomeação, sem o mesmo envelope de checksum/backup.

## Checkpoint

Registrado no início e a cada pouso. Campos: fase, corpo, posição, posição relativa, orientação, combustível, tempo, temporizador ativo, tempo da simulação, estrelas/tanques coletados e versão de conteúdo. Vetores são serializados como arrays.

A restauração atualiza corpos para o relógio salvo e recompõe a posição no apoio. Não reaplica gesto ou impulso. Checkpoints antigos sem coletas/relógio recebem os valores de compatibilidade previstos pelo validador. ID ou `content_version` incompatíveis impedem recuperação.

`continuar_checkpoint()` existe no controlador e restaura pausado. A interface atual não expõe essa retomada no menu/seleção. `restaurar_checkpoint()` da tentativa é usado por Último pouso na derrota. Não confundir as duas entradas.

## Reset e testes

O controlador limpa checkpoint antes de resetar progresso. O reset limpa recordes e atualiza backup para evitar recuperação indevida; preferências são independentes. Testes relevantes: `test_persistencia.gd`, `test_progresso_estrelas.gd`, `test_checkpoint_persistente.gd`, `test_retentar_checkpoint.gd`, `test_preferencias.gd`, `test_retentar_preferencias.gd` e `test_reset_progresso.gd`.
