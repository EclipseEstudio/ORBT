param(
    [Parameter(Mandatory)] [string] $Java,
    [Parameter(Mandatory)] [string] $Sdk,
    [Parameter(Mandatory)] [string] $DadosGodot,
    [Parameter(Mandatory)] [string] $DiretorioTemporario
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
& $keytool -genkeypair -keystore $chave -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname 'CN=Android Debug,O=Android,C=US' | Out-Host
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $chave)) { throw 'Falha ao gerar a chave de depuração.' }
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
export/android/debug_keystore_user = "androiddebugkey"
export/android/debug_keystore_pass = "android"
"@
[IO.File]::WriteAllText((Join-Path $DadosGodot 'editor_settings-4.7.tres'), $config, [Text.UTF8Encoding]::new($false))
