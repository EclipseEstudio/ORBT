# Atualização e reinstalação Android

## Identidade de distribuição

O ORBT distribuído mantém `com.eclipseestudio.orbt`, o certificado permanente registrado em `scripts/assinatura-android.json` e um `version/code` crescente. A versão preparada nesta alteração é 0.3.2 / código 5. Atualizações Android precisam preservar a identidade e a assinatura; versões inferiores são bloqueadas pelo sistema. Referências: [assinatura de aplicativos](https://developer.android.com/studio/publish/app-signing) e [versionamento Android](https://developer.android.com/studio/publish/versioning).

Os APKs de 0.3.1 e anteriores foram assinados por chaves temporárias de cada execução. Essas chaves não podem ser recuperadas a partir de um APK. A primeira versão com a assinatura permanente pode exigir desinstalar a instalação antiga, apagando seus dados. Esse limite é da migração histórica; não existe atualização compatível sem a chave antiga. O processo não tenta contornar a assinatura nem desinstala automaticamente.

## Instalar, atualizar ou reinstalar sem apagar dados

No telefone, abra o novo APK e escolha Instalar/Atualizar. Mantenha o aplicativo instalado. Reinstalar a mesma versão compatível sobre a existente mantém seus dados; desinstalar é uma operação diferente e pode apagar progresso, checkpoints e configurações. Se houver conflito de assinatura, interrompa o processo e verifique se é uma versão anterior à migração. A reinstalação não é indicada como primeira solução para erros genéricos.

Para instalação acompanhada por ADB:

```powershell
./scripts/instalar-android.ps1 -Adb 'C:/Android/Sdk/platform-tools/adb.exe' -Ferramentas 'C:/Android/Sdk/build-tools/36.1.0' -Apk 'build/android/ORBT-debug.apk'
```

Com mais de um aparelho, informe `-Serial`. O script valida o APK e sua assinatura, confere o APK instalado e rejeita outro pacote, outro certificado e downgrade. Usa somente `adb install -r`; não executa desinstalação, limpeza de dados nem autorização automática de permissões. Em caso de falha, mantém a instalação atual. A vibração exige `android.permission.VIBRATE`, incluída no preset e conferida no manifesto do APK.

## Gerar e conferir novas versões

`scripts/configurar-android-ci.ps1` recebe a chave permanente pelos segredos `ORBT_ANDROID_KEYSTORE_BASE64`, `ORBT_ANDROID_KEYSTORE_PASSWORD` e `ORBT_ANDROID_KEYSTORE_ALIAS`. A senha não é passada na linha de comando do keytool. O script valida o certificado contra o contrato público e falha se faltar uma credencial; nunca cria uma chave substituta silenciosamente.

O workflow de PRs executa a suíte, exporta o APK, verifica assinatura/alinhamento e roda `scripts/verificar-atualizacao-android.ps1`. A comparação com a release publicada exige código maior. Na primeira migração, somente o código 5 pode substituir a assinatura temporária; após isso, o certificado também precisa coincidir com o da versão publicada. O resultado `atualizacao.json` acompanha o APK e `revisao.txt`. Anexe os três arquivos à release. O fluxo deve interromper a distribuição quando não conseguir consultar ou validar a versão anterior.

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
