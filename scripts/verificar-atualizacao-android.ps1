param(
    [Parameter(Mandatory)] [string] $Apk,
    [Parameter(Mandatory)] [string] $Ferramentas,
    [string] $Saida,
    [switch] $Previa,
    [switch] $CompararPublicada
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'android-pacote.ps1')
$orbtNovo = Ler-PacoteAndroid -Apk $Apk -Ferramentas $Ferramentas
$orbtConfiguracao = Ler-ConfiguracaoAndroidProjeto
Conferir-PacoteAndroidProjeto -Pacote $orbtNovo -Configuracao $orbtConfiguracao
if (-not $orbtNovo.permissao_vibrar) { throw 'A permissão Android de vibração está ausente.' }
$orbtContrato = Get-Content (Join-Path $PSScriptRoot 'assinatura-android.json') -Raw | ConvertFrom-Json
$orbtMigracao = $false
if ($Previa) {
    if ($orbtNovo.pacote -notmatch '^com\.eclipseestudio\.orbt\.previa\.p[0-9]+$') { throw 'Prévia deve usar um pacote separado do ORBT distribuído.' }
} else {
    if ($orbtNovo.pacote -ne $orbtContrato.pacote -or $orbtNovo.certificado_sha256 -ne $orbtContrato.certificado_sha256) { throw 'O APK não usa a identidade permanente de distribuição.' }
    if ($orbtNovo.codigo -lt $orbtContrato.primeiro_codigo_permanente) { throw 'Código Android anterior à migração de assinatura.' }
    $orbtProjeto = Split-Path $PSScriptRoot -Parent
    if ($CompararPublicada) {
        $orbtHeaders = @{Accept='application/vnd.github+json'; 'User-Agent'='ORBT-verificacao'}
        if ($env:GITHUB_TOKEN) { $orbtHeaders.Authorization = 'Bearer ' + $env:GITHUB_TOKEN }
        $orbtTodas = Invoke-RestMethod -Uri 'https://api.github.com/repos/EclipseEstudio/ORBT/releases?per_page=100' -Headers $orbtHeaders
        $orbtAnterior = $orbtTodas | Where-Object { -not $_.draft -and $_.published_at -and @($_.assets | Where-Object { $_.state -eq 'uploaded' -and $_.name -match '\.apk$' }).Count -gt 0 } | Sort-Object { [datetime]$_.published_at } -Descending | Select-Object -First 1
        if ($orbtAnterior) {
            $orbtAsset = @($orbtAnterior.assets | Where-Object { $_.state -eq 'uploaded' -and $_.name -match '\.apk$' })
            $orbtEscolhido = $orbtAsset | Where-Object name -match '^(ORBT|ORBT-debug|ORBT-universal)\.apk$' | Select-Object -First 1
            if (-not $orbtEscolhido) { $orbtEscolhido = $orbtAsset[0] }
            if ($orbtEscolhido.browser_download_url -notlike 'https://github.com/EclipseEstudio/ORBT/releases/download/*') { throw 'Origem do APK anterior inválida.' }
            $orbtPasta = Join-Path $orbtProjeto ('.godot/comparacao-android-' + [guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $orbtPasta -Force | Out-Null
            $orbtApkAnterior = Join-Path $orbtPasta 'anterior.apk'
            Invoke-WebRequest -Uri $orbtEscolhido.browser_download_url -OutFile $orbtApkAnterior
            $orbtDadosAnteriores = Ler-PacoteAndroid -Apk $orbtApkAnterior -Ferramentas $Ferramentas
            if ($orbtEscolhido.digest -and $orbtEscolhido.digest -ne ('sha256:' + $orbtDadosAnteriores.apk_sha256)) { throw 'Hash do APK publicado diverge do GitHub.' }
            if ($orbtNovo.codigo -le $orbtDadosAnteriores.codigo) { throw 'Aumente version/code: o código precisa superar o último APK publicado.' }
            $orbtMigracao = $orbtNovo.codigo -eq $orbtContrato.primeiro_codigo_permanente -and $orbtDadosAnteriores.codigo -lt $orbtContrato.primeiro_codigo_permanente
            if (-not $orbtMigracao) { $null = Conferir-AtualizacaoAndroid -Novo $orbtNovo -Anterior $orbtDadosAnteriores -ExigirVersaoNova }
            elseif ($orbtNovo.pacote -ne $orbtDadosAnteriores.pacote) { throw 'A migração não pode trocar o identificador do aplicativo.' }
        }
    }
}
$orbtNovo | Add-Member -NotePropertyName canal -NotePropertyValue $(if ($Previa) { 'previa' } else { 'distribuicao' })
$orbtNovo | Add-Member -NotePropertyName migracao_assinatura -NotePropertyValue $orbtMigracao
$orbtTexto = $orbtNovo | ConvertTo-Json
if ($Saida) { [IO.File]::WriteAllText([IO.Path]::GetFullPath($Saida), $orbtTexto, [Text.UTF8Encoding]::new($false)) }
Write-Output $orbtTexto
