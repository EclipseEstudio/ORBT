param(
    [Parameter(Mandatory)] [string] $Java,
    [string] $Destino = (Join-Path (Split-Path $PSScriptRoot -Parent) 'build/assinatura/orbt.keystore')
)
$ErrorActionPreference = 'Stop'
$orbtChave = [IO.Path]::GetFullPath($Destino)
$orbtSenhaArquivo = $orbtChave + '.senha-protegida'
if ((Test-Path -LiteralPath $orbtChave) -or (Test-Path -LiteralPath $orbtSenhaArquivo)) { throw 'A chave já existe. Preserve-a; não gere outra para uma atualização.' }
$orbtKeytool = Join-Path $Java 'bin/keytool.exe'
if (-not (Test-Path -LiteralPath $orbtKeytool)) { throw 'JDK com keytool não encontrado.' }
New-Item -ItemType Directory -Path (Split-Path $orbtChave -Parent) -Force | Out-Null
$orbtAleatorio = [Security.Cryptography.RandomNumberGenerator]::Create()
$orbtBytes = New-Object byte[] 32
try { $orbtAleatorio.GetBytes($orbtBytes) } finally { $orbtAleatorio.Dispose() }
$orbtSenha = [Convert]::ToBase64String($orbtBytes)
$orbtSegura = ConvertTo-SecureString $orbtSenha -AsPlainText -Force
$orbtSegura | ConvertFrom-SecureString | Set-Content -LiteralPath $orbtSenhaArquivo -Encoding utf8
$env:ORBT_SENHA_CRIACAO = $orbtSenha
try {
    & $orbtKeytool -genkeypair -keystore $orbtChave -storetype PKCS12 -storepass:env ORBT_SENHA_CRIACAO -keypass:env ORBT_SENHA_CRIACAO -alias orbt -keyalg RSA -keysize 3072 -validity 10000 -dname 'CN=Eclipse Estudio ORBT,O=Eclipse Estudio,C=BR'
    if ($LASTEXITCODE -ne 0) { throw 'Falha ao criar chave permanente. Preserve os arquivos para diagnóstico.' }
    $orbtCertificado = $orbtChave + '.certificado.der'
    & $orbtKeytool -exportcert -keystore $orbtChave -storepass:env ORBT_SENHA_CRIACAO -alias orbt -file $orbtCertificado
    if ($LASTEXITCODE -ne 0) { throw 'Falha ao conferir certificado.' }
    [pscustomobject]@{Chave=$orbtChave; SenhaProtegida=$orbtSenhaArquivo; Alias='orbt'; CertificadoSHA256=(Get-FileHash -LiteralPath $orbtCertificado -Algorithm SHA256).Hash.ToLowerInvariant()}
} finally {
    Remove-Item Env:ORBT_SENHA_CRIACAO -ErrorAction SilentlyContinue
    $orbtSenha = $null
    $orbtSegura.Dispose()
}
