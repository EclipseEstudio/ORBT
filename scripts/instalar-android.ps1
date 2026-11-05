param(
    [Parameter(Mandatory)] [string] $Adb,
    [Parameter(Mandatory)] [string] $Ferramentas,
    [string] $Apk = (Join-Path (Split-Path $PSScriptRoot -Parent) 'build/android/ORBT-debug.apk'),
    [string] $Serial
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'android-pacote.ps1')
$orbtNovo = Ler-PacoteAndroid -Apk $Apk -Ferramentas $Ferramentas
$orbtContrato = Get-Content (Join-Path $PSScriptRoot 'assinatura-android.json') -Raw | ConvertFrom-Json
if ($orbtNovo.pacote -ne $orbtContrato.pacote -or $orbtNovo.certificado_sha256 -ne $orbtContrato.certificado_sha256) { throw 'Use um APK com a assinatura permanente do ORBT.' }
$orbtDispositivos = & $Adb devices
if ($LASTEXITCODE -ne 0) { throw 'Não foi possível consultar o aparelho.' }
$orbtDisponiveis = @($orbtDispositivos | Where-Object { $_ -match '^\S+\s+device$' } | ForEach-Object { ($_ -split '\s+')[0] })
if (-not $Serial) {
    if ($orbtDisponiveis.Count -ne 1) { throw 'Conecte e autorize um aparelho ou informe -Serial.' }
    $Serial = $orbtDisponiveis[0]
}
if ($Serial -notin $orbtDisponiveis) { throw 'O aparelho informado não está conectado e autorizado.' }
$orbtPacotes = & $Adb -s $Serial shell pm list packages $orbtNovo.pacote
if ($LASTEXITCODE -ne 0) { throw 'Não foi possível verificar a instalação atual.' }
$orbtOperacao = 'instalacao'
if (@($orbtPacotes | ForEach-Object { $_.Trim() }) -contains ('package:' + $orbtNovo.pacote)) {
    $orbtCaminhos = & $Adb -s $Serial shell pm path $orbtNovo.pacote
    if ($LASTEXITCODE -ne 0) { throw 'Não foi possível localizar o APK instalado.' }
    $orbtInstalado = $orbtCaminhos | Where-Object { $_ -match '^package:.*?/base\.apk\s*$' } | Select-Object -First 1
    if (-not $orbtInstalado) { throw 'APK instalado não identificado. Nenhum dado foi removido.' }
    $orbtPasta = Join-Path (Split-Path $PSScriptRoot -Parent) ('.godot/instalacao-android-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $orbtPasta -Force | Out-Null
    $orbtAtual = Join-Path $orbtPasta 'instalado.apk'
    & $Adb -s $Serial pull ($orbtInstalado.Trim() -replace '^package:', '') $orbtAtual | Out-Host
    if ($LASTEXITCODE -ne 0) { throw 'Não foi possível conferir o APK instalado. Nenhum dado foi removido.' }
    $orbtAnterior = Ler-PacoteAndroid -Apk $orbtAtual -Ferramentas $Ferramentas
    $orbtOperacao = Conferir-AtualizacaoAndroid -Novo $orbtNovo -Anterior $orbtAnterior
}
$orbtSaida = & $Adb -s $Serial install -r $Apk 2>&1
if ($LASTEXITCODE -ne 0 -or -not ($orbtSaida -match '^Success\s*$')) { throw ('Instalação interrompida, sem desinstalação automática: ' + ($orbtSaida -join ' ')) }
Write-Output "ORBT $($orbtNovo.versao): $orbtOperacao concluída. Dados existentes preservados."
