# Página de download e publicação

## Publicação atual

O download Android continua como ação principal. O link secundário **Jogar no navegador** abre `jogar/`, sem instalação. O progresso do navegador é separado do aplicativo Android.

O workflow `.github/workflows/web-pages.yml` obtém a `alpha`, prepara um preset Web sem threads e usa Compatibility somente no checkout de publicação. Exporta para `docs/jogar/`, confere HTML, JavaScript, WebAssembly e PCK e registra versão/revisão em `versao.json`. Publica a página e o jogo juntos pelo GitHub Pages.

Alterações integradas em `alpha` ou `main` na página, workflow, código, recursos e configurações do jogo disparam a publicação; há também execução manual. O ambiente `github-pages` deve permitir a branch que dispara a execução (`alpha` ou `main`). O download e a publicação Android mantêm seu fluxo próprio.

Endereço previsto: <https://eclipseestudio.github.io/ORBT/>. A opção Web fica em <https://eclipseestudio.github.io/ORBT/jogar/>. A exportação sem threads dispensa cabeçalhos de isolamento entre origens. Valide áudio, toque, persistência e desempenho no navegador após publicar.

A entrega 0.5.2 havia retirado o jogo Web. Esta alteração restaura essa opção secundária. As notas daquela entrega Android permanecem em `docs/versoes/v0.5.2-alpha.20261112.md`.

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

O jogo Web no Pages é atualizado pelas alterações integradas descritas acima; publicar uma tag Android não dispara a exportação Web.

Publicar prerelease mais recente também muda o download automático. Uma Release sem APK não substitui o download anterior. Este documento descreve o mecanismo; não afirma que uma publicação remota tenha ocorrido.
