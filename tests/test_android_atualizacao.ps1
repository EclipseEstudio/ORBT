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
Get-ChildItem (Join-Path (Split-Path $PSScriptRoot -Parent) 'scripts') -Filter '*.ps1' | ForEach-Object {
    $orbtTokens = $null
    $orbtErros = $null
    $null = [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$orbtTokens, [ref]$orbtErros)
    Conferir ($orbtErros.Count -eq 0) ('Sintaxe PowerShell válida: ' + $_.Name)
}
Write-Output "Atualização Android: $orbtVerificacoes verificações, 0 falhas."
