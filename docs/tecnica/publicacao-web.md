# Página de download e publicação

Fonte: `docs/index.html`, `docs/.nojekyll` e `.github/workflows/android-pr.yml`. A página oferece **download Android**, não uma versão jogável no navegador. Não há preset Web no repositório.

## GitHub Pages

A página é um HTML autocontido, com CSS/JavaScript, sem build ou dependências externas. Fica em `docs/index.html`; `.nojekyll` permite publicação estática. Endereço previsto: <https://eclipseestudio.github.io/ORBT/>.

A configuração documentada é **Settings → Pages → Deploy from a branch → main → /docs**. A configuração remota não é demonstrável pelo código e deve ser conferida no GitHub antes de mudar publicação. Não mover o HTML ou `.nojekyll` para pastas internas de documentação.

## Seleção do APK

Uma requisição pública consulta até 100 releases. O script ignora rascunhos, ordena por `published_at` decrescente e seleciona a primeira publicação com APK de upload concluído, tamanho positivo e URL do próprio repositório. Prereleases são incluídas.

Se houver vários APKs, prefere `ORBT.apk`, `ORBT-debug.apk` ou `ORBT-universal.apk`; fora disso usa o primeiro. A página exibe versão/tamanho e hash quando informado pela API. Sem APK informa indisponibilidade; erro/timeout de 8 s mantém link para Releases. Sem JavaScript, o link também leva às Releases. Feedback aponta às Issues.

## Publicar uma versão

1. Gere e valide o APK conforme [Android](android.md), inclusive atualização sobre a versão anterior e preservação de dados.
2. Associe uma tag nova à revisão validada e prepare notas que identifiquem escopo/limites.
3. Anexe o APK e relatórios `atualizacao.json`/`revisao.txt` na Release. Artefato temporário de Actions sozinho não alimenta o site.
4. Publique como prerelease quando experimental e confira o botão/versão no site. Se a seleção automática encontrar o novo APK, não precisa editar o HTML.

O workflow atual contém um job específico para `release/0.5.0`, tag `v0.5.0-alpha.20261107` e notas em `docs/versoes/versao-0.5.0-alpha-2026-11-07.md`. Ele depende do job Android, confere árvore, cabeça atual do PR, versão 0.5.0/código 9 e hash do APK. Não substitui release existente nem integra PR. Para outra versão, revise essa lógica explicitamente.

Publicar prerelease mais recente também muda o download automático. Uma Release sem APK não substitui o download anterior. Este documento descreve o mecanismo; não afirma que uma publicação remota tenha ocorrido.
