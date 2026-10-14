param(
    [string] $Godot = 'godot',
    [switch] $SomentePacote
)

$ErrorActionPreference = 'Stop'
$orbtProjeto = Split-Path $PSScriptRoot -Parent
Push-Location $orbtProjeto
try {
    New-Item -ItemType Directory -Path 'build/android' -Force | Out-Null
    $orbtExtensao = if ($SomentePacote) { 'pck' } else { 'apk' }
    $orbtModo = if ($SomentePacote) { '--export-pack' } else { '--export-debug' }
    $orbtDestino = Join-Path $orbtProjeto "build/android/ORBT-debug.$orbtExtensao"
    $orbtLog = Join-Path $orbtProjeto "build/android/export-$orbtExtensao.log"
    # Não confundir um artefato antigo com uma exportação que acabou de falhar.
    if (Test-Path -LiteralPath $orbtDestino) { Remove-Item -LiteralPath $orbtDestino }
    $ErrorActionPreference = 'Continue'
    $orbtSaida = & $Godot --headless --path $orbtProjeto --log-file $orbtLog $orbtModo Android $orbtDestino 2>&1
    $orbtCodigo = $LASTEXITCODE
    $ErrorActionPreference = 'Stop'
    $orbtSaida | Write-Output
    if ($orbtCodigo -ne 0 -or ($orbtSaida -match 'SCRIPT ERROR:|ERROR:') -or -not (Test-Path -LiteralPath $orbtDestino)) {
        throw "Exportação falhou. Consulte $orbtLog e docs/android.md para configurar JDK, SDK e modelos da Godot."
    }
    if ((Get-Item -LiteralPath $orbtDestino).Length -eq 0) { throw 'Arquivo exportado vazio.' }
    Write-Output "Gerado: $orbtDestino"
    if ($SomentePacote) { Write-Output 'PCK contém os recursos do jogo; não é um APK instalável.' }
} finally {
    Pop-Location
}
