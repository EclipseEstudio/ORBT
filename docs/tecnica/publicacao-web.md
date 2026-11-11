# Página de download e publicação

Fontes locais: `docs/index.html`, `docs/.nojekyll` e `.github/workflows/android-pr.yml`. Esta branch contém a página de download Android e somente o preset Android. A `main` remota também contém `.github/workflows/web-pages.yml`, que prepara um preset Web durante o build e publica o jogo no navegador. Confira as branches antes de concluir que a ausência de preset Web local significa ausência de distribuição Web.

## GitHub Pages

A página é um HTML autocontido, com CSS/JavaScript, sem build ou dependências externas. Fica em `docs/index.html`; `.nojekyll` permite publicação estática. Endereço previsto: <https://eclipseestudio.github.io/ORBT/>.

A configuração histórica usava **Settings → Pages → Deploy from a branch → main → /docs**. A `main` atual inclui publicação por `actions/deploy-pages`; consulte a configuração remota antes de mudar o mecanismo. Não mover o HTML ou `.nojekyll` para pastas internas de documentação.

## Jogo Web na main

O workflow remoto `web-pages.yml` obtém a branch `alpha`, acrescenta um preset Web sem threads, usa renderizador Compatibility e publica os arquivos em `docs/jogar/`, incluindo `versao.json` com a revisão exportada. Também acrescenta o acesso **Jogar no navegador** à página de download. Não é necessário manter um preset Web no checkout Android para esse fluxo existir.

Na consulta de 10/11/2026, a [execução 42440652800](https://github.com/EclipseEstudio/ORBT/actions/runs/42440652800) estava concluída com sucesso; menu, campanha, tutorial, pausa, lançamento por mouse e vitória foram observados em `https://eclipseestudio.github.io/ORBT/jogar/`. Isso não comprova áudio, persistência em nova sessão, desempenho em outros navegadores ou atualização Android; consulte o [relatório](../historico/registros/validacao-2026-11-10.md).

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
