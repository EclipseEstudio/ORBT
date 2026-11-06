# Atualização e reinstalação Android

## Identidade de distribuição

O ORBT distribuído mantém `com.eclipseestudio.orbt`, o certificado permanente registrado em `scripts/assinatura-android.json` e um `version/code` crescente. A primeira versão permanente publicada é 0.3.2 / código 5; a publicação anterior à campanha de 20 fases é 0.3.3 / código 6. A campanha com estrelas foi publicada como 0.4.0 / código 7; esta atualização prepara 0.4.1 / código 8. Atualizações Android precisam preservar a identidade e a assinatura; versões inferiores são bloqueadas pelo sistema. Referências: [assinatura de aplicativos](https://developer.android.com/studio/publish/app-signing) e [versionamento Android](https://developer.android.com/studio/publish/versioning).

Os APKs de 0.3.1 e anteriores foram assinados por chaves temporárias de cada execução. Essas chaves não podem ser recuperadas a partir de um APK. A primeira versão com a assinatura permanente pode exigir desinstalar a instalação antiga, apagando seus dados. Esse limite é da migração histórica; não existe atualização compatível sem a chave antiga. O processo não tenta contornar a assinatura nem desinstala automaticamente.

## Instalar, atualizar ou reinstalar sem apagar dados

No telefone, abra o novo APK e escolha Instalar/Atualizar. Mantenha o aplicativo instalado. Reinstalar a mesma versão compatível sobre a existente mantém seus dados; desinstalar é uma operação diferente e pode apagar progresso, checkpoints e configurações. Se houver conflito de assinatura, interrompa o processo e verifique se é uma versão anterior à migração. A reinstalação não é indicada como primeira solução para erros genéricos.

Para instalação acompanhada por ADB:

```powershell
./scripts/instalar-android.ps1 -Adb 'C:/Android/Sdk/platform-tools/adb.exe' -Ferramentas 'C:/Android/Sdk/build-tools/36.1.0' -Apk 'build/android/ORBT-debug.apk'
```

Com mais de um aparelho, informe `-Serial`. O script valida o APK e sua assinatura, confere o APK instalado e rejeita outro pacote, outro certificado e downgrade. Identifica o perfil Android atual e usa esse perfil nas consultas e em `adb install -r --user`. Isso evita consultar perfis privados/protegidos de aparelhos com múltiplos usuários. Não executa desinstalação, limpeza de dados nem autorização automática de permissões. Em caso de falha, mantém a instalação atual. A vibração exige `android.permission.VIBRATE`, incluída no preset e conferida no manifesto do APK.

### Diagnóstico sem instalar

Acrescente `-SomenteDiagnostico -Relatorio '.godot/diagnostico-android.json'`. O script lê o APK instalado e compara pacote, certificado e código com o candidato. Retorna a operação possível ou o motivo de incompatibilidade, sem instalar, encerrar o jogo nem remover dados. Informe a mensagem exata do instalador quando a identidade for compatível e a instalação manual continuar falhando; não tratar todo erro como conflito de assinatura.

### Comprovar preservação no aparelho

Com a versão publicada já instalada e contendo progresso/configurações, rode:

```powershell
./scripts/instalar-android.ps1 -Adb 'C:/Android/Sdk/platform-tools/adb.exe' -Ferramentas 'C:/Android/Sdk/build-tools/36.1.0' -Apk 'build/android/ORBT-0.3.3-qa.apk' -ConferirDados -Relatorio '.godot/teste-atualizacao-android.json'
```

Esse teste fecha o jogo, calcula os hashes de progresso, checkpoint, preferências e cópias existentes, atualiza sobre a instalação atual e confere os mesmos arquivos novamente. Também aceita reinstalar um APK compatível da mesma versão para validar o arquivo final de distribuição. Falta de dados ou impossibilidade de leitura não gera aprovação falsa; alteração/remoção reprova a conferência. A leitura usa `run-as`, disponível nos APKs de depuração deste canal. O relatório fica fora do Git e não contém o conteúdo dos saves.

Antes de uma nova publicação, conferir também a abertura do APK pelo instalador do próprio celular, pois uma instalação via USB não valida as permissões da origem de download. Registrar o aparelho, as versões, o hash do APK e o resultado da preservação, sem publicar identificadores do usuário ou o conteúdo dos arquivos pessoais.

Em 05/11/2026, a atualização 0.3.2 → candidato 0.3.3 foi validada em Samsung SM-A556E / Android 16 por USB e pelo instalador do celular, mantendo os quatro arquivos salvos idênticos nos dois testes. A nova versão permanece local, sem publicação. Consulte a [evidência do teste real](../auxiliar/evidencias-atualizacao-2026-11-05/README.md).

## Gerar e conferir novas versões

`scripts/configurar-android-ci.ps1` recebe a chave permanente pelos segredos `ORBT_ANDROID_KEYSTORE_BASE64`, `ORBT_ANDROID_KEYSTORE_PASSWORD` e `ORBT_ANDROID_KEYSTORE_ALIAS`. A senha não é passada na linha de comando do keytool. O script valida o certificado contra o contrato público e falha se faltar uma credencial; nunca cria uma chave substituta silenciosamente.

O workflow de PRs executa a suíte, exporta o APK, verifica assinatura/alinhamento e roda `scripts/verificar-atualizacao-android.ps1`. A comparação com a release publicada exige código maior. Na primeira migração, somente o código 5 pode substituir a assinatura temporária; após isso, o certificado também precisa coincidir com o da versão publicada. O resultado `atualizacao.json` acompanha o APK e `revisao.txt`. Anexe os três arquivos à release. O fluxo deve interromper a distribuição quando não conseguir consultar ou validar a versão anterior.

O exportador local também verifica o certificado permanente e confronta pacote, código e versão do APK com `project.godot` e `export_presets.cfg`. Divergência entre as versões configuradas interrompe antes da exportação; um APK produzido com a chave padrão do editor não é aceito como distribuição. Informe `-Ferramentas` com a pasta `build-tools/36.1.0` ou use `ANDROID_HOME`/`ANDROID_SDK_ROOT`. PRs externos devem passar `-Previa`; a configuração de prévia mantém pacote separado.

Para reproduzir a comparação antes de publicar:

```powershell
./scripts/verificar-atualizacao-android.ps1 -Apk build/android/ORBT-debug.apk -Ferramentas 'C:/Android/Sdk/build-tools/36.1.0' -CompararPublicada -Saida build/android/atualizacao.json
```

PRs de repositórios externos não recebem a chave de distribuição. Suas prévias usam nome ORBT Prévia e pacote `com.eclipseestudio.orbt.previa.pN`, com chave temporária. Elas podem coexistir com o ORBT e não devem ser publicadas como atualização do aplicativo principal.

## Preservar a chave

A chave original e a senha protegida ficam em `build/assinatura/`, fora do Git. A senha local é protegida pelo Windows para a conta/máquina atual. Preserve também uma cópia de recuperação em armazenamento seguro: copiar somente a senha protegida para outro computador não garante que ela possa ser aberta. Os três segredos do Actions permitem repetir a assinatura em outros runners sem gerar outra identidade.

`scripts/criar-chave-android.ps1 -Java '<JDK>'` existe para a configuração inicial e recusa sobrescrever uma chave existente. Não execute esse gerador para atualizar o ORBT já distribuído. `scripts/registrar-assinatura-github.ps1` permite cadastrar os segredos usando GitHub CLI autenticado, recebendo os valores por entrada padrão; também recusa substituir uma assinatura já configurada. O certificado público deve sempre corresponder ao contrato versionado.

## Preferências entre versões

O arquivo de preferências passa ao esquema 2, com `vibracao` e `dicas` booleanos. Esquema 1 continua aceito, preservando os volumes e usando as duas novas opções ativadas. Carregar um arquivo antigo não o sobrescreve; a migração é gravada ao alterar uma configuração. Arquivos inválidos e falhas de gravação mantêm os avisos e a retentativa. Progresso e checkpoint permanecem em seus arquivos separados.
