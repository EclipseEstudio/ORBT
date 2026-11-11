# Organização da documentação

Revisão de 10/11/2026. A estrutura anterior misturava especificação, planejamento, validações datadas e material de autoria em `auxiliar/`.

| Antes | Agora |
| --- | --- |
| `docs/auxiliar/guia-editor-de-fases.md` | `docs/guias/editor-de-fases.md`, reescrito conforme o plugin |
| `docs/arte/` | `docs/arte/`, com fontes, prompts e manifesto preservados |
| `docs/auxiliar/versao-*.md` | `docs/versoes/` |
| Relatórios e snapshots em `auxiliar/` | `docs/historico/registros/`, identificados como históricos |
| Capturas/medições em `auxiliar/` | `docs/historico/evidencias/` |
| Estado atual disperso | `docs/projeto/`, regras e contratos atualizados |

## Critérios de limpeza

O índice redundante de `auxiliar/`, o plano temporário da primeira fase e o plano de fundo/estrelas já superado foram removidos. Seus assuntos atuais estão nos guias, regras e validação pendente. Metadados `.png.import` das capturas históricas foram removidos por serem produtos de importação sem função documental. Um único `.gdignore` na raiz substitui 18 marcadores internos redundantes e evita importar a documentação na Godot.

Foram preservados relatórios com contexto, capturas ligadas a validações, dados brutos e fontes originais de arte. Eles ajudam a reproduzir e interpretar decisões, mesmo quando o comportamento descrito mudou. Recursos de jogo, mapas de demonstração, testes e scripts de geração não foram eliminados por parecerem antigos: podem ser dependências ou fixtures.

Links relativos foram recalculados. Os scripts que leem fontes de arte, a verificação de exclusão no pacote e o workflow que lê notas de release foram ajustados aos novos caminhos. `docs/index.html` e `.nojekyll` continuam no lugar para preservar o site.

Essa limpeza não altera regras de execução, não marca validações humanas como concluídas e não modifica GitHub Projects/issues. O código rege a documentação atual; o histórico mantém o contexto das revisões anteriores.

## Verificação desta organização

Em 10/11/2026, Godot 4.7.2/Windows, com dados de validação isolados em `.godot/`:

- Catálogo conferido diretamente: 30 fases, 90 douradas e 29 azuis.
- 398 links locais Markdown conferidos, sem arquivos ausentes; âncoras locais revisadas. Duas referências históricas de seções substituídas apontam para a revisão anterior identificada no Git.
- 12 hashes do manifesto inicial de arte conferidos: seis fontes e seis sprites preservados.
- Importação do projeto concluída sem `ERROR:` ou `SCRIPT ERROR:`.
- `tests/run_exportacao.ps1`: **67 verificações, zero falhas**, incluindo exclusão das fontes/documentação do pacote.
- Referência de notas no workflow conferida. Página do site, catálogo, recursos, scripts de execução do jogo e configurações de projeto/exportação sem alterações.

O editor avisou sobre um projeto de auditoria preexistente dentro de `build/`, ignorado durante a varredura. Não houve novo teste em aparelho nem execução da suíte completa de gameplay nesta alteração documental. Logs e pacote usados na verificação são saídas locais em `.godot/` e `build/`.
