param(
    [string] $Adb = 'adb',
    [string] $Serial
)

$ErrorActionPreference = 'Stop'
$orbtRaiz = Split-Path $PSScriptRoot -Parent
$orbtApk = Join-Path $orbtRaiz 'build/android/ORBT-debug.apk'
if (-not (Test-Path -LiteralPath $orbtApk)) { throw 'Gere o APK antes de coletar evidências.' }
$orbtComando = (Get-Command $Adb -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
function Invoke-OrbtAdb([string[]] $Argumentos) {
    $orbtResposta = & $orbtComando @Argumentos
    if ($LASTEXITCODE -ne 0) { throw "ADB falhou: $Argumentos" }
    return ($orbtResposta -join "`n").Trim()
}
$orbtDispositivos = Invoke-OrbtAdb @('devices')
$orbtConectados = @($orbtDispositivos -split "`n" | Where-Object { $_ -match '^\S+\s+device\s*$' } | ForEach-Object { ($_ -split '\s+')[0] })
if ($Serial) {
    if ($Serial -notin $orbtConectados) { throw 'Aparelho solicitado ausente ou sem autorização USB.' }
} elseif ($orbtConectados.Count -eq 1) {
    $Serial = $orbtConectados[0]
} else {
    throw 'Conecte e autorize um aparelho; com vários aparelhos, informe -Serial.'
}
$orbtEvidencia = [ordered]@{
    coletado_em = (Get-Date).ToString('o')
    apk_sha256 = (Get-FileHash -LiteralPath $orbtApk -Algorithm SHA256).Hash
    fase_sha256 = (Get-FileHash -LiteralPath (Join-Path $orbtRaiz 'Recursos/Fases/teste_001.json') -Algorithm SHA256).Hash
    modelo = Invoke-OrbtAdb @('-s', $Serial, 'shell', 'getprop', 'ro.product.model')
    android = Invoke-OrbtAdb @('-s', $Serial, 'shell', 'getprop', 'ro.build.version.release')
    api = Invoke-OrbtAdb @('-s', $Serial, 'shell', 'getprop', 'ro.build.version.sdk')
    pacote_instalado = Invoke-OrbtAdb @('-s', $Serial, 'shell', 'dumpsys', 'package', 'com.eclipseestudio.orbt')
    aceite = 'PENDENTE: preencher resultados do roteiro manual; metadados não comprovam execução nem correspondência do APK instalado.'
}
$orbtDestino = Join-Path $orbtRaiz ('build/android/evidencias-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.json')
$orbtEvidencia | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $orbtDestino -Encoding UTF8
Write-Output "Evidências: $orbtDestino"
