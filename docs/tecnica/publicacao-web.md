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

1. Integre as entregas por PRs para `alpha`. Cada PR executa os testes e gera um APK temporário; não publica uma Release nem exige aumentar a versão.
2. Quando o conjunto estiver pronto, prepare uma entrega de versão: ajuste `config/version`, `version/name` e um `version/code` superior ao do último APK publicado. Valide a atualização e preservação de dados conforme [Android](android.md).
3. Escreva as notas em `docs/versoes/<tag>.md`, reunindo escopo e limites. Por exemplo, `docs/versoes/v0.5.1-alpha.20261111.md` para uma futura versão interna 0.5.1. Integre essa preparação à `alpha`.
4. Crie e envie explicitamente a tag sobre a revisão integrada. Tags seguem `vVERSAO` ou `vVERSAO-sufixo`, com a mesma versão de projeto/preset. O workflow só aceita commits pertencentes ao histórico de `alpha`.
5. O envio da tag dispara importação, testes, validação do PCK, geração do APK, assinatura/alinhamento e comparação com o APK publicado. A comparação exige código superior e é repetida antes da publicação. O job publica exatamente o artefato validado, acompanhado de `atualizacao.json`, `revisao.txt` e `SHA256SUMS.txt`.
6. Tags com sufixo, como `-alpha.20261111`, geram prerelease; sem sufixo, release estável. Confira o botão/versão no site. Se a seleção automática encontrar o novo APK, não precisa editar o HTML.

O workflow `.github/workflows/android-pr.yml` atende revisão e publicação com condições distintas. Seu job `publicar` só roda no envio de tag, confere revisão/hash/identidade e usa as notas daquela tag. A automação específica de `release/0.5.0` foi substituída; abrir ou atualizar um PR dessa branch também não publica versão. Tags/releases existentes não são substituídas.

O envio da tag deve ser feito pelo usuário ou por credencial que dispare workflows. Criar referências com o `GITHUB_TOKEN` de outro workflow não dispara automaticamente esse fluxo. Não é necessário cadastrar `workflow_dispatch` na branch padrão para a publicação por tag.

O jogo Web no Pages mantém o fluxo separado da `main` descrito acima; publicar o APK não dispara automaticamente a exportação Web.

Publicar prerelease mais recente também muda o download automático. Uma Release sem APK não substitui o download anterior. Este documento descreve o mecanismo; não afirma que uma publicação remota tenha ocorrido.
