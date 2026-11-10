# Atualização e assinatura Android

Fonte: `scripts/android-pacote.ps1`, `assinatura-android.json`, `instalar-android.ps1`, `verificar-atualizacao-android.ps1`, `configurar-android-ci.ps1` e preset Android.

O canal de distribuição mantém pacote `com.eclipseestudio.orbt`, certificado permanente registrado em `scripts/assinatura-android.json` e código crescente. Estado local: 0.5.0/código 9. A verificação rejeita identidade diferente, certificado diferente e downgrade.

Versões 0.3.1 e anteriores usaram chaves temporárias conforme os registros históricos. Uma instalação com certificado antigo pode exigir migração por reinstalação; não é possível obter a chave privada a partir do APK. Desinstalar pode apagar dados. Atualizações compatíveis devem ser instaladas sobre o aplicativo existente.

## Diagnosticar e instalar

```powershell
./scripts/instalar-android.ps1 -Adb 'C:/Android/Sdk/platform-tools/adb.exe' -Ferramentas 'C:/Android/Sdk/build-tools/36.1.0' -Apk 'build/android/ORBT-debug.apk' -SomenteDiagnostico -Relatorio '.godot/diagnostico-android.json'
```

Sem `-SomenteDiagnostico`, instala após as verificações. `-Serial` seleciona aparelho. O script identifica o perfil Android atual, usa atualização `install -r --user` e não limpa dados/desinstala. Se falhar com identidade compatível, registre a mensagem real do instalador.

## Comprovar preservação

Com uma versão compatível instalada e contendo progresso/configurações:

```powershell
./scripts/instalar-android.ps1 -Adb 'C:/Android/Sdk/platform-tools/adb.exe' -Ferramentas 'C:/Android/Sdk/build-tools/36.1.0' -Apk 'build/android/ORBT-debug.apk' -ConferirDados -Relatorio '.godot/teste-atualizacao-android.json'
```

O ensaio fecha o jogo, calcula hashes dos saves e cópias, instala e compara. Usa `run-as` disponível no canal debug; falta de dados/permissão não comprova preservação. Confira também instalação manual pelo telefone. Não publique conteúdo de saves ou identificadores pessoais.

## Pipeline e chave

APKs de distribuição usam os segredos `ORBT_ANDROID_KEYSTORE_BASE64`, `ORBT_ANDROID_KEYSTORE_PASSWORD` e `ORBT_ANDROID_KEYSTORE_ALIAS`. O script de registro confere certificado e recusa substituir configuração existente. A chave privada e senha são locais/segredos; o JSON versionado contém somente identidade pública.

`criar-chave-android.ps1` é para configuração inicial, não para cada versão. Trocar chave quebra atualização. `registrar-assinatura-github.ps1` registra uma chave existente validada. PRs externos usam pacote de prévia separado e chave temporária; esse APK não deve ser distribuído como atualização do canal principal.

`verificar-atualizacao-android.ps1 -CompararPublicada` compara a identidade com APK publicado e gera relatório. `exportar-android.ps1` integra checagens de identidade do candidato. CI exige as verificações antes de disponibilizar o artefato. Notas históricas de execução não confirmam o estado atual das Releases.
