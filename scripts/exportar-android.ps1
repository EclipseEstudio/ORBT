param(
    [string] $Godot = 'godot',
    [switch] $SomentePacote
)

$ErrorActionPreference = 'Stop'
$orbtComando = Get-Command -Name $Godot -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $orbtComando) {
    throw "Godot não encontrada: '$Godot'. Informe o caminho completo do executável com -Godot, por exemplo: .\scripts\exportar-android.ps1 -Godot 'C:\Ferramentas\Godot\Godot_console.exe'. O nome 'godot' só funciona quando o executável está no PATH."
}
# Resolver antes de mudar de pasta também permite caminhos relativos ao terminal.
$orbtExecutavel = $orbtComando.Source
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
    # Windows PowerShell 5.1 encapsula stderr em ErrorRecord; manter o diagnóstico como texto.
    $orbtSaida = & $orbtExecutavel --headless --path $orbtProjeto --log-file $orbtLog $orbtModo Android $orbtDestino 2>&1 | ForEach-Object { $_.ToString() }
    $orbtCodigo = $LASTEXITCODE
    $ErrorActionPreference = 'Stop'
    $orbtSaida | Write-Output
    if ($orbtCodigo -ne 0 -or ($orbtSaida -match 'SCRIPT ERROR:|ERROR:') -or -not (Test-Path -LiteralPath $orbtDestino)) {
        throw "Exportação falhou. Consulte $orbtLog e docs/tecnica/android.md para configurar JDK, SDK e modelos da Godot."
    }
    if ((Get-Item -LiteralPath $orbtDestino).Length -eq 0) { throw 'Arquivo exportado vazio.' }
    Write-Output "Gerado: $orbtDestino"
    if ($SomentePacote) { Write-Output 'PCK contém os recursos do jogo; não é um APK instalável.' }
} finally {
    Pop-Location
}
