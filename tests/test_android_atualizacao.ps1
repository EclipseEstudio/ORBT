$ErrorActionPreference = 'Stop'
. (Join-Path (Split-Path $PSScriptRoot -Parent) 'scripts/android-pacote.ps1')
$orbtVerificacoes = 0
function Conferir([bool] $Condicao, [string] $Mensagem) {
    $script:orbtVerificacoes += 1
    if (-not $Condicao) { throw $Mensagem }
}
function Recusa($Novo, $Anterior, [switch] $NovaVersao) {
    try { $null = Conferir-AtualizacaoAndroid -Novo $Novo -Anterior $Anterior -ExigirVersaoNova:$NovaVersao; return $false } catch { return $true }
}
$orbtAnterior = [pscustomobject]@{pacote='com.eclipseestudio.orbt'; codigo=5; certificado_sha256=('a' * 64)}
$orbtNovo = [pscustomobject]@{pacote='com.eclipseestudio.orbt'; codigo=6; certificado_sha256=('a' * 64)}
Conferir ((Conferir-AtualizacaoAndroid -Novo $orbtNovo -Anterior $orbtAnterior) -eq 'atualizacao') 'Versão superior com mesma assinatura permite atualização.'
$orbtNovo.codigo = 5
Conferir ((Conferir-AtualizacaoAndroid -Novo $orbtNovo -Anterior $orbtAnterior) -eq 'reinstalacao') 'Mesma versão permite reinstalar preservando dados.'
Conferir (Recusa $orbtNovo $orbtAnterior -NovaVersao) 'Publicação exige aumento de código.'
$orbtNovo.codigo = 4
Conferir (Recusa $orbtNovo $orbtAnterior) 'Versão inferior é bloqueada.'
$orbtNovo.codigo = 6
$orbtNovo.certificado_sha256 = 'b' * 64
Conferir (Recusa $orbtNovo $orbtAnterior) 'Certificado diferente é bloqueado.'
$orbtNovo.certificado_sha256 = 'a' * 64
$orbtNovo.pacote = 'com.eclipseestudio.orbt.previa.p99'
Conferir (Recusa $orbtNovo $orbtAnterior) 'Prévia não substitui aplicativo principal.'
$orbtConfiguracao = Ler-ConfiguracaoAndroidProjeto
Conferir ($orbtConfiguracao.codigo -gt 5 -and -not [string]::IsNullOrEmpty($orbtConfiguracao.versao)) 'Próximos candidatos usam código posterior ao primeiro certificado permanente.'
$orbtCandidato = [pscustomobject]@{pacote=$orbtConfiguracao.pacote; codigo=$orbtConfiguracao.codigo; versao=$orbtConfiguracao.versao}
Conferir-PacoteAndroidProjeto -Pacote $orbtCandidato -Configuracao $orbtConfiguracao
Conferir $true 'APK correspondente à configuração é aceito.'
$orbtCandidato.codigo -= 1
$orbtRecusou = $false
try { Conferir-PacoteAndroidProjeto -Pacote $orbtCandidato -Configuracao $orbtConfiguracao } catch { $orbtRecusou = $true }
Conferir $orbtRecusou 'APK antigo com mesmo nome de arquivo é recusado.'
$orbtCandidato.codigo = $orbtConfiguracao.codigo
$orbtCandidato.versao = '0.0.0'
$orbtRecusou = $false
try { Conferir-PacoteAndroidProjeto -Pacote $orbtCandidato -Configuracao $orbtConfiguracao } catch { $orbtRecusou = $true }
Conferir $orbtRecusou 'Versão textual divergente é recusada.'
$orbtFixture = Join-Path (Split-Path $PSScriptRoot -Parent) ('.godot/config-android-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $orbtFixture -Force | Out-Null
try {
    [IO.File]::WriteAllText((Join-Path $orbtFixture 'project.godot'), 'config/version="0.3.3"')
    [IO.File]::WriteAllText((Join-Path $orbtFixture 'export_presets.cfg'), "version/name=`"0.3.2`"`nversion/code=6`npackage/unique_name=`"com.eclipseestudio.orbt`"")
    $orbtRecusou = $false
    try { $null = Ler-ConfiguracaoAndroidProjeto -Projeto $orbtFixture } catch { $orbtRecusou = $true }
    Conferir $orbtRecusou 'Divergência entre projeto e preset é recusada antes da exportação.'
} finally {
    foreach ($orbtNome in @('project.godot','export_presets.cfg')) { Remove-Item -LiteralPath (Join-Path $orbtFixture $orbtNome) -ErrorAction SilentlyContinue }
    Remove-Item -LiteralPath $orbtFixture
}
$orbtSaves = @{'files/progresso.json'=('a' * 64); 'files/preferencias.json'=('b' * 64)}
Conferir-DadosSalvosAndroid -Antes $orbtSaves -Depois @{'files/preferencias.json'=('b' * 64); 'files/progresso.json'=('a' * 64)}
Conferir $true 'Hashes iguais confirmam dados preservados independentemente da ordem.'
foreach ($orbtDados in @(@{}, @{'files/progresso.json'=('a' * 64)}, @{'files/progresso.json'=('c' * 64); 'files/preferencias.json'=('b' * 64)})) {
    $orbtRecusou = $false
    try { Conferir-DadosSalvosAndroid -Antes $orbtSaves -Depois $orbtDados } catch { $orbtRecusou = $true }
    Conferir $orbtRecusou 'Remoção ou alteração de dados reprova o teste de atualização.'
}
$orbtRecusou = $false
try { Conferir-DadosSalvosAndroid -Antes @{} -Depois @{} } catch { $orbtRecusou = $true }
Conferir $orbtRecusou 'Teste sem saves não produz comprovação falsa de preservação.'
Get-ChildItem (Join-Path (Split-Path $PSScriptRoot -Parent) 'scripts') -Filter '*.ps1' | ForEach-Object {
    $orbtTokens = $null
    $orbtErros = $null
    $null = [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$orbtTokens, [ref]$orbtErros)
    Conferir ($orbtErros.Count -eq 0) ('Sintaxe PowerShell válida: ' + $_.Name)
}
Write-Output "Atualização Android: $orbtVerificacoes verificações, 0 falhas."
