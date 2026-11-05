function Ler-PacoteAndroid {
    param([Parameter(Mandatory)] [string] $Apk, [Parameter(Mandatory)] [string] $Ferramentas)
    $orbtManifesto = & (Join-Path $Ferramentas 'aapt2.exe') dump badging $Apk 2>&1
    if ($LASTEXITCODE -ne 0) { throw 'Não foi possível ler o APK.' }
    $orbtIdentidade = [regex]::Match(($orbtManifesto -join "`n"), "package: name='([^']+)' versionCode='([0-9]+)' versionName='([^']+)'")
    if (-not $orbtIdentidade.Success) { throw 'Manifesto Android inválido.' }
    $orbtAssinatura = & (Join-Path $Ferramentas 'apksigner.bat') verify --print-certs $Apk 2>&1
    if ($LASTEXITCODE -ne 0) { throw 'Assinatura do APK inválida.' }
    $orbtCertificados = [regex]::Matches(($orbtAssinatura -join "`n"), 'Signer #[0-9]+ certificate SHA-256 digest: ([a-fA-F0-9]{64})')
    if ($orbtCertificados.Count -ne 1) { throw 'O APK deve ter um único certificado de assinatura.' }
    return [pscustomobject]@{
        schema_version = 1
        pacote = $orbtIdentidade.Groups[1].Value
        codigo = [int]$orbtIdentidade.Groups[2].Value
        versao = $orbtIdentidade.Groups[3].Value
        permissao_vibrar = [bool]($orbtManifesto -match "uses-permission: name='android.permission.VIBRATE'")
        certificado_sha256 = $orbtCertificados[0].Groups[1].Value.ToLowerInvariant()
        apk_sha256 = (Get-FileHash -LiteralPath $Apk -Algorithm SHA256).Hash.ToLowerInvariant()
    }
}

function Conferir-AtualizacaoAndroid {
    param([Parameter(Mandatory)] $Novo, [Parameter(Mandatory)] $Anterior, [switch] $ExigirVersaoNova)
    if ($Novo.pacote -ne $Anterior.pacote) { throw 'O APK pertence a outro aplicativo.' }
    if ($Novo.certificado_sha256 -ne $Anterior.certificado_sha256) { throw 'Assinatura incompatível com a instalação anterior. Nenhum dado foi removido. Reinstalar após desinstalar pode apagar o progresso.' }
    if ($Novo.codigo -lt $Anterior.codigo) { throw 'Este APK é mais antigo que o instalado. A atualização foi interrompida.' }
    if ($ExigirVersaoNova -and $Novo.codigo -eq $Anterior.codigo) { throw 'Aumente version/code antes de publicar uma nova versão.' }
    return $(if ($Novo.codigo -eq $Anterior.codigo) { 'reinstalacao' } else { 'atualizacao' })
}
