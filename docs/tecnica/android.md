# Exportação e aceite Android

## Continuidade do roteiro em 31/10/2026

Sobre a `alpha` com o PR #87 integrado, uma instalação independente **ORBT QA R87** foi testada no Samsung SM-A556E/Android 16. Cancelamento, suspensão durante mira/voo, exploração/recentralização, contato contra origem, último combustível com vitória e derrotas por limite/asteroide/tempo têm passos e capturas no [registro do roteiro](../auxiliar/validacao-roteiro-android-2026-10-31.md). Os saves principais foram preservados. O trecho com gestos físicos e o aceite global continuam pendentes; o registro distingue toque injetado, resposta manual e diagnóstico do ambiente. As seções abaixo são históricas.

## Validação parcial em 30/10/2026

O APK do PR #68 foi atualizado em um Samsung SM-A556E com Android 16, usando assinatura de depuração compatível com a instalação existente. A primeira fase foi concluída com toque simulado e o checkpoint inicial foi recuperado após reabertura. Dados, hashes, capturas, limitação dos testes e uma sobreposição visual observada estão em [validação Android](../auxiliar/validacao-android-2026-10-30.md). O aceite completo em aparelho continua pendente.

## Estado em 29/10/2026

Integração de código concluída pelos PRs #42–#46. O APK de 29/10 abaixo contém as integrações de corpos, campanha, arte e persistência; o de 15/10 é histórico. Instalação, toque físico, retomada, ergonomia, persistência após reabertura e desempenho no Android continuam pendentes em #4/#33/#37/#38. Os quatro critérios funcionais da #40 têm [aceite demonstrado no Windows](../auxiliar/validacao-issue-40.md). Consulte o [estado consolidado](../auxiliar/estado-da-branch.md).

## APK de teste gerado em 29/10/2026

APK exportado localmente da revisão `846785b` (PR #46 integrado), Godot 4.7.2 e JDK Temurin 17.0.20.1. Arquivo: `build/android/ORBT-debug.apk`, 57.787.925 bytes (55,1 MiB), SHA-256 `abdcb3e9ae77403bc92579c95b9bace7a0698bd977fb90ed4d1763491c4f7458`. Assinatura de depuração verificada nos esquemas APK v2/v3; alinhamento de 16 KB aprovado. Manifesto lido com AAPT2: pacote `com.eclipseestudio.orbt`, versão 0.1.0/código 1, mínimo API 24, alvo API 36, ARM 32/64 bits.

O JDK portátil foi baixado do Adoptium; SHA-256 conferido com a release oficial. Foi usado de `build/android/` apenas durante a exportação e não altera a configuração persistente do editor. A tentativa de enumerar aparelhos pelo ADB não iniciou o daemon neste ambiente. Instalação e teste no telefone ainda pendentes.

## Preparação de exportação

O preset `Android` em `export_presets.cfg` está pronto para um APK de depuração:

- Identificador `com.eclipseestudio.orbt`, nome ORBT; versão e código definidos em `export_presets.cfg`.
- ARM de 32 e 64 bits; modelos prontos da Godot, sem build Gradle personalizado.
- Catálogo `Recursos/Niveis.json` e arquivos `Recursos/Fases/*.json` incluídos explicitamente.
- Testes, documentação, scripts auxiliares, referências visuais e temporários excluídos.
- Tela em retrato; HUD ajustado à área segura informada pelo Android, em coordenadas lógicas.
- Importação ETC2/ASTC habilitada em `project.godot`, exigida pela exportação Mobile para Android.
- O aplicativo abre no menu principal. Durante uma fase, suspender/perder foco pausa a partida e cancela a entrada; é preciso tocar em Retomar.

O renderizador continua Mobile. A compatibilidade gráfica, os recortes de tela e o desempenho precisam ser verificados no aparelho escolhido. Nenhuma regra proposta do protótipo ganha aceite por causa da exportação.

## Preparar o computador uma vez

Use Godot 4.7.2, versão que validou esta implementação, e modelos correspondentes ao editor. Em **Editor > Manage Export Templates**, instale os modelos Android. [Modelos de exportação](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html#export-templates).

Instale OpenJDK 17 e Android SDK, incluindo os componentes exigidos pela versão do Godot. O Android Studio fornece o SDK Manager. Em **Editor > Editor Settings > Export > Android**, informe **Java SDK Path** e **Android SDK Path**. O segundo deve apontar para a pasta que contém `platform-tools` e `build-tools`. Siga as versões de componentes do [guia oficial Android](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html).

Para **Godot 4.7.2**, o [arquivo de versões da própria engine](https://github.com/godotengine/godot/blob/4.7.2-stable/platform/android/java/app/config.gradle) define Java 17, SDK 36 e Build-Tools 36.1.0. Use essas versões se o guia genérico da documentação indicar versões anteriores. O preset desta branch usa modelos APK prontos, com Gradle desativado; não compila a engine nem precisa de NDK/CMake para esse fluxo.

As configurações de SDK pertencem ao editor utilizado, não ao projeto. Um editor portátil em modo autocontido pode ter configurações e modelos diferentes do editor instalado. Execute os scripts com o caminho do mesmo editor configurado.

Não coloque senhas no preset. Credenciais ficam nas configurações locais da Godot; arquivos de assinatura `.keystore` e `.jks` estão ignorados pelo Git. A entrega usa assinatura de depuração para teste.

## APK automático para revisão de PR

PRs destinados à `alpha` executam o fluxo **APK Android para revisão** no GitHub Actions. Ele importa o projeto, executa as suítes e a verificação do pacote, gera um APK de depuração e confere a assinatura e o alinhamento. Após uma execução bem-sucedida, baixe o artefato `ORBT-android-debug-pr-N` na página da execução. O arquivo `revisao.txt` identifica as revisões da cabeça, da base e do merge testado, além do SHA-256 do APK. A execução é substituída quando o PR recebe uma nova revisão; o artefato expira após 14 dias.

O fluxo usa Godot e modelos oficiais 4.7.2 conferidos por SHA-256, Java 17 e o SDK Android da máquina do GitHub (plataforma 36 e Build-Tools 36.1.0). Se uma dependência estiver ausente, a execução falha com o caminho necessário. PRs de forks podem precisar de autorização de um mantenedor para executar Actions.

Uma chave de depuração temporária é criada em cada execução. Como a assinatura muda entre execuções, o Android pode exigir a desinstalação do APK anterior antes de instalar outro; a desinstalação pode apagar os dados do aplicativo. Esse APK serve para testes, não para publicação. A geração automática não substitui a instalação e os testes em aparelho.

## Gerar e instalar

Na raiz do repositório, com a Godot configurada no PATH:

```powershell
./scripts/exportar-android.ps1 -Godot godot
```

Se aparecer **'godot' não é reconhecido**, o executável não está no PATH. Use o caminho do arquivo `.exe` que abre seu editor, entre aspas. Exemplo (substitua pela pasta onde você extraiu a Godot):

```powershell
.\scripts\exportar-android.ps1 -Godot "C:\Ferramentas\Godot\Godot_v4.7.2-stable_win64_console.exe"
```

Não é necessário alterar o PATH quando se usa o caminho completo. Prefira o executável terminado em `_console.exe` para acompanhar o diagnóstico no terminal.

Saída: `build/android/ORBT-debug.apk`; diagnóstico: `build/android/export-apk.log`. O script verifica o executável antes de alterar a saída e falha se a engine reportar erro, retornar código diferente de zero ou não produzir arquivo válido. Com o executável localizado, um APK antigo é removido antes da tentativa para evitar entrega desatualizada.

Pelo editor, abra **Project > Export**, selecione **Android**, clique em **Export Project** e mantenha **Export With Debug** marcado. Salve em `build/android/ORBT-debug.apk`.

Transfira o APK para o telefone e abra pelo gerenciador de arquivos; autorize a instalação por esse aplicativo quando solicitada. Abra ORBT, inicie uma fase pelo menu e aguarde a câmera apresentar a Terra e voltar à nave. A rota de referência da primeira fase é um arraste vertical para baixo de 80 unidades lógicas na área central livre: um impulso completo para cima chega à Terra.

## Retomada da issue #4 em 22/10/2026

Base integrada `8c4c5c0`, branch `feat/issue-4-primeira-fase-android`. Controles: 68 verificações; partida: 142; pacote exportado: 10. Todas passaram com Godot 4.7.2. A referência remota `main` consultada ainda aponta para `1de3c4d`; a integração permanece na branch de trabalho.

A nova exportação APK falhou porque `export/android/java_sdk_path` está vazio no editor utilizado. ADB iniciou, mas não encontrou aparelho conectado. Não há APK novo nem aceite Android nesta retomada.

Após configurar Java, gerar o APK e conectar/autorizar o telefone, execute `./scripts/evidencias-android.ps1 -Adb '<caminho do adb.exe>'`. Com vários aparelhos, informe `-Serial`. O script grava modelo, Android/API, hashes do APK e JSON e informações do pacote instalado em `build/android/evidencias-*.json`. Não instala nem abre o aplicativo. Complete o registro com o roteiro manual abaixo, versão da Godot, revisão testada, resultados e capturas; os metadados sozinhos não demonstram aceite ou que o APK instalado corresponde ao arquivo local.

## Histórico de 14/10/2026

- Godot 4.7.2.stable.official.ed1daf0bf / Windows.
- Controles e interface: 68 verificações; dados, física e partida: 139; nenhuma falha.
- `tests/run_exportacao.ps1`: 10 verificações sem falhas sobre o PCK gerado pelo preset Android, executado de pasta isolada. Catálogo/fase presentes, arquivos de desenvolvimento excluídos, cena principal resolvida e rota concluída com combustível 4.
- A exportação de APK foi tentada. O editor usado informou modelos Android ausentes, Java SDK não configurado e ausência de SDK válido com `adb`/`apksigner`. Nenhum APK foi produzido.
- O primeiro teste de empacotamento encontrou bloqueio do armazenamento interno `user://` pelo ambiente restrito. Reexecutado com acesso normal aos dados da Godot, passou sem erros de script/exportação. A mensagem sobre `build-tools` ausente não impede exportar apenas PCK.
- PCK não é um aplicativo Android. Não há evidência de instalação, desempenho ou ergonomia em aparelho nesta entrega.

## APK gerado em 15/10/2026

As dependências foram instaladas e os caminhos foram configurados no editor Godot do computador de desenvolvimento. Uma cópia das configurações anteriores foi preservada antes de alterar os dois caminhos de SDK.

- Eclipse Temurin JDK 17.0.20.1+1; Android Platform-Tools 37.0.1; SDK Platform 36 e Build-Tools 36.1.0; modelos Android oficiais 4.7.2.stable. Downloads conferidos contra os checksums publicados.
- Exportação executada com Windows PowerShell 5.1 e Godot 4.7.2, concluída com código zero. O script normaliza stderr para texto nesse PowerShell, mantendo os erros detectáveis.
- Artefato: `build/android/ORBT-debug.apk`, 57.748.423 bytes (55,1 MiB), assinatura de depuração. SHA-256: `3a7dfaad05c14a6554f2d7f1032b9d275447a359308ce4b5cf1e2a59f30c8b89`.
- `apksigner verify`: assinatura válida nos esquemas v2 e v3. `zipalign -c -P 16 4`: passou.
- AAPT2 leu o manifesto: `com.eclipseestudio.orbt`, versão 0.1.0 / código 1, Android mínimo API 24, alvo API 36, arquiteturas `arm64-v8a` e `armeabi-v7a`.
- O AAPT legado não interpreta os atributos Vulkan adicionados pelo exportador; a leitura com AAPT2 foi concluída. Este reportou um aviso de referência a `themed_icon.xml` ausente na tabela de recursos do modelo; o ícone principal está empacotado. Conferir apresentação do ícone no aparelho durante o aceite.
- Catálogo e fase dentro do APK conferidos byte a byte com os JSON do projeto; testes, scripts auxiliares, documentação, temporários e referências visuais não foram incluídos.
- Instalação e execução em telefone ainda não realizadas. As verificações do pacote não substituem o roteiro abaixo.

## Roteiro histórico para aceite em aparelho — issues #4 e #15–#20

Registre modelo do aparelho, versão do Android, versão/hash da branch, versão da Godot, JSON usado e gravação ou captura. Preencha resultado observado, sem marcar itens apenas pela implementação existir.

| Cenário | Resultado esperado | Observado no aparelho |
| --- | --- | --- |
| Abrir ORBT | Fase direta; Terra apresentada; retorno à nave; combustível 5 | Pendente |
| Lançar pela rota descrita | Uma cobrança; tempo começa; chegada à Terra | Pendente |
| Toque parado / voltar ao círculo | Nenhum impulso/cobrança; próximo gesto exige novo toque | Pendente |
| Dois dedos / botões | Segundo dedo não assume mira; botões não lançam | Pendente |
| Explorar / recentralizar | Arraste só move câmera; não há lançamento ao voltar | Pendente |
| Soltar exploração sobre interface | Próximo arraste funciona, sem contato preso | Pendente |
| Suspender com dedo na tela | Gesto cancelado; tempo e física pausados; Retomar não lança | Pendente |
| Correção em voo | Soma velocidade, cobra uma unidade e reinicia tempo | Pendente |
| Último combustível | Continua à deriva; chegada ainda pode vencer | Pendente |
| Pouso / lançar contra origem | Não atravessa apoio; pouso não recarrega; saldo zero encerra | Pendente |
| Perigo / limites / tempo | Uma derrota, causa visível, nave interrompida | Pendente |
| Reiniciar após resultado | Restaura posição, apoio, combustível, tempo e câmera | Pendente |
| Recortes e navegação do sistema | HUD legível e botões acessíveis na área segura | Pendente |
| Mira repetida durante voo | Prévia limpa ao cancelar; medir FPS/custo e comparar com voo | Pendente |

As escolhas de direção livre, gravidade, tempo, pouso sem saldo e contato contra origem estão registradas nas [regras de jogabilidade](../regras-de-negocio/jogabilidade.md#aceite-e-limites-do-protótipo) como propostas. O aceite dessas regras e a execução deste roteiro são condições para encerrar as issues que exigem demonstração no Android.
