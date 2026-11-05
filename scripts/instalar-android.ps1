param(
    [Parameter(Mandatory)] [string] $Adb,
    [Parameter(Mandatory)] [string] $Ferramentas,
    [string] $Apk = (Join-Path (Split-Path $PSScriptRoot -Parent) 'build/android/ORBT-debug.apk'),
    [string] $Serial,
    [switch] $SomenteDiagnostico,
    [switch] $ConferirDados,
    [string] $Relatorio
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
$orbtUsuarioTexto = (& $Adb -s $Serial shell am get-current-user) -join ''
if ($LASTEXITCODE -ne 0 -or $orbtUsuarioTexto.Trim() -notmatch '^[0-9]+$') { throw 'Não foi possível identificar o perfil Android em uso.' }
$orbtUsuario = [int]$orbtUsuarioTexto.Trim()
$orbtPacotes = & $Adb -s $Serial shell pm list packages --user $orbtUsuario $orbtNovo.pacote
if ($LASTEXITCODE -ne 0) { throw 'Não foi possível verificar a instalação atual.' }
$orbtOperacao = 'instalacao'
$orbtAnterior = $null
$orbtMotivo = ''
if (@($orbtPacotes | ForEach-Object { $_.Trim() }) -contains ('package:' + $orbtNovo.pacote)) {
    $orbtCaminhos = & $Adb -s $Serial shell pm path --user $orbtUsuario $orbtNovo.pacote
    if ($LASTEXITCODE -ne 0) { throw 'Não foi possível localizar o APK instalado.' }
    $orbtInstalado = $orbtCaminhos | Where-Object { $_ -match '^package:.*?/base\.apk\s*$' } | Select-Object -First 1
    if (-not $orbtInstalado) { throw 'APK instalado não identificado. Nenhum dado foi removido.' }
    $orbtPasta = Join-Path (Split-Path $PSScriptRoot -Parent) ('.godot/instalacao-android-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $orbtPasta -Force | Out-Null
    $orbtAtual = Join-Path $orbtPasta 'instalado.apk'
    & $Adb -s $Serial pull ($orbtInstalado.Trim() -replace '^package:', '') $orbtAtual | Out-Host
    if ($LASTEXITCODE -ne 0) { throw 'Não foi possível conferir o APK instalado. Nenhum dado foi removido.' }
    $orbtAnterior = Ler-PacoteAndroid -Apk $orbtAtual -Ferramentas $Ferramentas
    try { $orbtOperacao = Conferir-AtualizacaoAndroid -Novo $orbtNovo -Anterior $orbtAnterior }
    catch {
        if (-not $SomenteDiagnostico) { throw }
        $orbtMotivo = $_.Exception.Message
        $orbtOperacao = 'bloqueada'
    }
}
$orbtResultado = [ordered]@{
    schema_version = 1
    somente_diagnostico = [bool]$SomenteDiagnostico
    usuario_android = $orbtUsuario
    compativel = [string]::IsNullOrEmpty($orbtMotivo)
    motivo = $orbtMotivo
    operacao = $orbtOperacao
    novo = $orbtNovo
    instalado = $orbtAnterior
    dados_conferidos = $false
}
if ($SomenteDiagnostico) {
    $orbtTexto = $orbtResultado | ConvertTo-Json -Depth 8
    if ($Relatorio) { [IO.File]::WriteAllText([IO.Path]::GetFullPath($Relatorio), $orbtTexto, [Text.UTF8Encoding]::new($false)) }
    Write-Output $orbtTexto
    return
}
$orbtDadosAntes = @{}
if ($ConferirDados) {
    if ($null -eq $orbtAnterior -or $orbtOperacao -notin @('atualizacao', 'reinstalacao')) { throw 'O teste exige o ORBT instalado e um APK compatível da mesma versão ou mais novo. Não desinstale o jogo.' }
    & $Adb -s $Serial shell am force-stop --user $orbtUsuario $orbtNovo.pacote | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Não foi possível fechar o jogo para conferir seus dados.' }
    $orbtDadosAntes = Ler-DadosSalvosAndroid -Adb $Adb -Serial $Serial -Pacote $orbtNovo.pacote -Usuario $orbtUsuario
    if ($orbtDadosAntes.Count -eq 0) { throw 'Não há saves para comprovar preservação. Abra uma fase e ajuste uma preferência antes do teste.' }
}
$orbtSaida = & $Adb -s $Serial install -r --user $orbtUsuario $Apk 2>&1
if ($LASTEXITCODE -ne 0 -or -not ($orbtSaida -match '^Success\s*$')) { throw ('Instalação interrompida, sem desinstalação automática: ' + ($orbtSaida -join ' ')) }
if ($ConferirDados) {
    $orbtDadosDepois = Ler-DadosSalvosAndroid -Adb $Adb -Serial $Serial -Pacote $orbtNovo.pacote -Usuario $orbtUsuario
    Conferir-DadosSalvosAndroid -Antes $orbtDadosAntes -Depois $orbtDadosDepois
    $orbtResultado.dados_conferidos = $true
    $orbtResultado['hashes_antes'] = $orbtDadosAntes
    $orbtResultado['hashes_depois'] = $orbtDadosDepois
}
$orbtTexto = $orbtResultado | ConvertTo-Json -Depth 8
if ($Relatorio) { [IO.File]::WriteAllText([IO.Path]::GetFullPath($Relatorio), $orbtTexto, [Text.UTF8Encoding]::new($false)) }
Write-Output $orbtTexto
Write-Output "ORBT $($orbtNovo.versao): $orbtOperacao concluída sem desinstalação."
