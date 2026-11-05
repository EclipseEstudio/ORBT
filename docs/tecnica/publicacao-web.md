# Página de download do ORBT

A página fica em `docs/index.html`: HTML, CSS e JavaScript no mesmo arquivo, sem instalação, compilação, bibliotecas ou fontes externas. O visual e o fundo estrelado foram adaptados dos três arquivos de referência da landing page. `docs/.nojekyll` permite servir os arquivos diretamente, sem processamento pelo Jekyll.

## GitHub Pages (configuração única)

No repositório **EclipseEstudio/ORBT**, abra **Settings → Pages**:

1. Em **Source**, selecione **Deploy from a branch**.
2. Escolha **main** e a pasta **/docs**; clique em **Save**.
3. Aguarde a publicação do GitHub Pages.

Endereço esperado: <https://eclipseestudio.github.io/ORBT/>.

Alterações em `docs/index.html` na `main` atualizam a página. A exportação Android já exclui `docs/*`, portanto esta funcionalidade não entra no APK.

## Publicar ou atualizar o jogo

O processo atualizado exige assinatura permanente e validação contra o último APK publicado. Antes de publicar, siga [atualização e reinstalação Android](atualizacao-android.md) e anexe também `atualizacao.json` e `revisao.txt`. APKs de prévia externa usam outro pacote e não devem entrar no download do ORBT. As instruções abaixo de criação de release continuam válidas após essa checagem.

1. Gere o APK com o fluxo descrito em [Android na branch alpha](https://github.com/EclipseEstudio/ORBT/blob/alpha/docs/tecnica/android.md) e valide-o em um aparelho. A saída atual é `build/android/ORBT-debug.apk`.
2. Abra **Releases → Draft a new release** no repositório e escolha uma tag nova, por exemplo `v0.3.1-alpha.1`, associada à revisão validada.
3. Escreva as novidades e anexe o APK como arquivo da release. Não basta enviar o código-fonte nem deixar o APK nos artefatos temporários do Actions.
4. Para builds experimentais, marque **Set as a pre-release**. Publique a release e aguarde o upload terminar.
5. Abra a página: o botão apontará diretamente para o arquivo, com tamanho atualizado. A versão fica disponível na descrição do tamanho e no link **Versões**. Não é necessário editar nem republicar o HTML.

A página consulta a API pública do GitHub uma vez por visita, sem token, considerando as 100 releases mais recentes. Seleciona a release publicada mais recentemente que contenha um `.apk` com upload concluído, incluindo prereleases. Releases sem APK e rascunhos são ignorados. Isso permite publicar notas ou outros arquivos sem interromper o download existente.

Publique preferencialmente **um APK universal por release**. Se houver vários, a página prefere `ORBT.apk`, `ORBT-debug.apk` ou `ORBT-universal.apk`; fora desses nomes, usa o primeiro APK. O nome pode variar entre versões quando há apenas um APK. Para retirar uma versão de teste do download automático, remova sua publicação ou seu APK; publicar apenas uma release estável não oculta uma prerelease que tenha sido publicada depois.

Notas e histórico ficam no link **Versões**, para manter a página focada no download. As instruções ficam recolhidas em **Como instalar?**. Quando o GitHub informa o SHA-256 do arquivo, ele aparece em **Verificar integridade do arquivo**, dentro da ajuda. Versão mínima do Android e tamanho não são inventados nem fixados no HTML.

## Ausência de versão e indisponibilidade

Sem APK publicado, a página avisa que o primeiro teste ainda não está disponível. Se a API falhar, atingir o limite público ou demorar mais de oito segundos, o botão leva à lista de Releases. Esse mesmo link funciona sem JavaScript. O fundo respeita a preferência de movimento reduzido e pausa quando a aba está oculta.

Feedback é encaminhado para as Issues do próprio repositório; o jogador precisa de conta no GitHub. Não há formulário externo configurado.
