param([string] $Godot = 'godot')

$ErrorActionPreference = 'Stop'
$orbtProjeto = Split-Path $PSScriptRoot -Parent
$orbtExecutavel = (Get-Command $Godot -ErrorAction Stop).Source
& (Join-Path $orbtProjeto 'scripts/exportar-android.ps1') -Godot $orbtExecutavel -SomentePacote
$orbtIsolado = Join-Path $orbtProjeto 'build/android/verificacao'
New-Item -ItemType Directory -Path $orbtIsolado -Force | Out-Null
$orbtPacote = Join-Path $orbtProjeto 'build/android/ORBT-debug.pck'
$orbtTeste = Join-Path $PSScriptRoot 'test_exportacao.gd'
$orbtLog = Join-Path $orbtProjeto 'build/android/test-exportacao.log'
Push-Location $orbtIsolado
try {
    $orbtSaida = & $orbtExecutavel --headless --path $orbtIsolado --main-pack $orbtPacote --script $orbtTeste --quit-after 1200 --log-file $orbtLog 2>&1
    $orbtCodigo = $LASTEXITCODE
    $orbtSaida | Write-Output
    if ($orbtCodigo -ne 0 -or ($orbtSaida -match 'SCRIPT ERROR:|ERROR:') -or -not ($orbtSaida -match 'verificações, 0 falhas\.')) {
        throw "Falha na verificação do pacote exportado. Consulte $orbtLog."
    }
} finally {
    Pop-Location
}
