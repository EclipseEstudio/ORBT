# Documentação do ORBT

Atualizada em **10/11/2026**, usando o código e os JSONs como fonte de verdade. Funcionalidades adicionadas para demonstração fazem parte do estado documentado. Implementação não comprova balanceamento ou aceite em aparelho.

| Pasta | Finalidade | Entrada |
| --- | --- | --- |
| `projeto/` | Produto, conteúdo e limites | [Visão geral](projeto/visao-geral.md), [catálogo](projeto/catalogo-fases.md), [validação pendente](projeto/validacao-pendente.md) |
| `regras-de-negocio/` | Comportamento para o jogador | [Jogabilidade](regras-de-negocio/jogabilidade.md), [campanha](regras-de-negocio/campanha.md) |
| `guias/` | Procedimentos da equipe | [Editor](guias/editor-de-fases.md), [testes](guias/testes.md) |
| `tecnica/` | Arquitetura, contratos e distribuição | [Índice técnico](tecnica/README.md) |
| `arte/` | Inventário, procedência e fontes | [Recursos visuais](arte/README.md) |
| `versoes/` | Notas de versões identificadas | [Índice de versões](versoes/README.md) |
| `historico/` | Relatórios datados e evidências | [Arquivo histórico](historico/README.md) |

`index.html` é a página pública de download do GitHub Pages; `.nojekyll` mantém sua publicação estática. Ambos ficam na raiz de `docs`. `.gdignore` evita importar documentação/capturas na Godot; `export_presets.cfg` mantém sua exclusão do APK.

## Manutenção

1. Atualize a regra ou o contrato junto com o código correspondente. Cada página identifica suas fontes.
2. Ao alterar fases, atualize o [catálogo](projeto/catalogo-fases.md). Preserve IDs para conservar progresso; revise `content_version` se checkpoints anteriores deixarem de ser compatíveis.
3. Guarde relatórios datados em `historico/registros/` e anexos em `historico/evidencias/`, com revisão, ambiente, passos e resultado. Contagens antigas não descrevem a versão atual.
4. Separe planejamento futuro de implementação. Consulte o GitHub antes de afirmar o status remoto de issues/Projects.
5. Builds, logs e capturas descartáveis ficam em `build/` ou `.godot/`. Versione evidências somente quando tiverem contexto e utilidade.

Veja os [critérios da reorganização](projeto/organizacao-documentacao.md).
