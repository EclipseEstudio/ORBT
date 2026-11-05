param(
    [string] $Gh = 'gh',
    [string] $Chave = (Join-Path (Split-Path $PSScriptRoot -Parent) 'build/assinatura/orbt.keystore')
)
$ErrorActionPreference = 'Stop'
$orbtContrato = Get-Content (Join-Path $PSScriptRoot 'assinatura-android.json') -Raw | ConvertFrom-Json
if (-not (Test-Path -LiteralPath ($Chave + '.certificado.der')) -or (Get-FileHash -LiteralPath ($Chave + '.certificado.der') -Algorithm SHA256).Hash.ToLowerInvariant() -ne $orbtContrato.certificado_sha256) { throw 'Certificado local não corresponde à assinatura permanente do ORBT.' }
$orbtExistentes = & $Gh secret list --repo EclipseEstudio/ORBT --json name
if ($LASTEXITCODE -ne 0) { throw 'Autentique o GitHub CLI com permissão para gerenciar os segredos do repositório.' }
if (($orbtExistentes | ConvertFrom-Json).name -match '^ORBT_ANDROID_KEYSTORE_') { throw 'Assinatura já configurada. Não substituir os segredos de uma versão distribuída.' }
$orbtSegura = ConvertTo-SecureString ([IO.File]::ReadAllText(($Chave + '.senha-protegida')).Trim())
try {
    $orbtSenha = [Net.NetworkCredential]::new('', $orbtSegura).Password
    $orbtValores = @{
        ORBT_ANDROID_KEYSTORE_BASE64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($Chave))
        ORBT_ANDROID_KEYSTORE_PASSWORD = $orbtSenha
        ORBT_ANDROID_KEYSTORE_ALIAS = 'orbt'
    }
    foreach ($orbtNome in $orbtValores.Keys) {
        $orbtInicio = [Diagnostics.ProcessStartInfo]::new()
        $orbtInicio.FileName = $Gh
        $orbtInicio.UseShellExecute = $false
        $orbtInicio.CreateNoWindow = $true
        $orbtInicio.RedirectStandardInput = $true
        $orbtInicio.RedirectStandardError = $true
        $orbtInicio.Arguments = "secret set $orbtNome --repo EclipseEstudio/ORBT"
        $orbtProcesso = [Diagnostics.Process]::Start($orbtInicio)
        $orbtProcesso.StandardInput.Write($orbtValores[$orbtNome])
        $orbtProcesso.StandardInput.Close()
        $null = $orbtProcesso.StandardError.ReadToEnd()
        $orbtProcesso.WaitForExit()
        if ($orbtProcesso.ExitCode -ne 0) { throw "Falha ao registrar $orbtNome. Preserve a chave para completar o cadastro." }
    }
    Write-Output 'Assinatura permanente registrada. Nenhum segredo foi incluído no Git.'
} finally {
    $orbtSenha = $null
    $orbtValores = $null
    $orbtSegura.Dispose()
}
