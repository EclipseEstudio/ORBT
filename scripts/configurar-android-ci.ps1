param(
    [Parameter(Mandatory)] [string] $Java,
    [Parameter(Mandatory)] [string] $Sdk,
    [Parameter(Mandatory)] [string] $DadosGodot,
    [Parameter(Mandatory)] [string] $DiretorioTemporario,
    [switch] $ChaveTemporaria,
    [string] $PacotePrevia
)

$ErrorActionPreference = 'Stop'
foreach ($caminho in @($Java, $Sdk)) {
    if (-not (Test-Path -LiteralPath $caminho -PathType Container)) { throw "Diretório inexistente: $caminho" }
}
$keytool = Join-Path $Java 'bin/keytool.exe'
foreach ($arquivo in @($keytool, (Join-Path $Sdk 'platform-tools/adb.exe'), (Join-Path $Sdk 'build-tools/36.1.0/apksigner.bat'), (Join-Path $Sdk 'platforms/android-36/android.jar'))) {
    if (-not (Test-Path -LiteralPath $arquivo -PathType Leaf)) { throw "Dependência Android ausente: $arquivo" }
}
New-Item -ItemType Directory -Force -Path $DadosGodot, $DiretorioTemporario | Out-Null
$chave = Join-Path $DiretorioTemporario 'orbt-debug.keystore'
if (Test-Path -LiteralPath $chave) { throw "A chave temporária já existe: $chave" }
if ($ChaveTemporaria) {
    if ($PacotePrevia -notmatch '^com\.eclipseestudio\.orbt\.previa\.p[0-9]+$') { throw 'Chaves temporárias exigem pacote separado para a prévia do PR.' }
    & $keytool -genkeypair -keystore $chave -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname 'CN=Android Debug,O=Android,C=US' | Out-Host
    if ($LASTEXITCODE -ne 0) { throw 'Falha ao gerar chave de prévia.' }
    $orbtAlias = 'androiddebugkey'
    $orbtSenha = 'android'
    $orbtPreset = Join-Path (Split-Path $PSScriptRoot -Parent) 'export_presets.cfg'
    $orbtTexto = [IO.File]::ReadAllText($orbtPreset).Replace('package/unique_name="com.eclipseestudio.orbt"', "package/unique_name=`"$PacotePrevia`"").Replace('package/name="ORBT"', 'package/name="ORBT Prévia"')
    [IO.File]::WriteAllText($orbtPreset, $orbtTexto)
} else {
    foreach ($orbtNome in @('ORBT_ANDROID_KEYSTORE_BASE64','ORBT_ANDROID_KEYSTORE_PASSWORD','ORBT_ANDROID_KEYSTORE_ALIAS')) {
        if (-not [Environment]::GetEnvironmentVariable($orbtNome)) { throw "Segredo de assinatura ausente: $orbtNome. Não gerar outra chave para substituir a permanente." }
    }
    [IO.File]::WriteAllBytes($chave, [Convert]::FromBase64String($env:ORBT_ANDROID_KEYSTORE_BASE64))
    $orbtAlias = $env:ORBT_ANDROID_KEYSTORE_ALIAS
    $orbtSenha = $env:ORBT_ANDROID_KEYSTORE_PASSWORD
    $orbtContrato = Get-Content (Join-Path $PSScriptRoot 'assinatura-android.json') -Raw | ConvertFrom-Json
    if ($orbtAlias -ne $orbtContrato.alias -or $orbtSenha -notmatch '^[A-Za-z0-9+/=]{16,}$') { throw 'Identidade de assinatura inválida.' }
    $orbtCertificado = Join-Path $DiretorioTemporario 'orbt-certificado.der'
    & $keytool -exportcert -keystore $chave -storepass:env ORBT_ANDROID_KEYSTORE_PASSWORD -alias $orbtAlias -file $orbtCertificado | Out-Host
    if ($LASTEXITCODE -ne 0 -or (Get-FileHash -LiteralPath $orbtCertificado -Algorithm SHA256).Hash.ToLowerInvariant() -ne $orbtContrato.certificado_sha256) { throw 'A chave não corresponde ao certificado permanente do ORBT.' }
}
# Caminhos com barras normais também são aceitos no Windows e evitam escapes no recurso Godot.
$javaGodot = $Java.Replace('\', '/')
$sdkGodot = $Sdk.Replace('\', '/')
$chaveGodot = $chave.Replace('\', '/')
$config = @"
[gd_resource type="EditorSettings" format=3]

[resource]
export/android/java_sdk_path = "$javaGodot"
export/android/android_sdk_path = "$sdkGodot"
export/android/debug_keystore = "$chaveGodot"
export/android/debug_keystore_user = "$orbtAlias"
export/android/debug_keystore_pass = "$orbtSenha"
"@
[IO.File]::WriteAllText((Join-Path $DadosGodot 'editor_settings-4.7.tres'), $config, [Text.UTF8Encoding]::new($false))
