function Ler-ConfiguracaoAndroidProjeto {
    param([string] $Projeto = (Split-Path $PSScriptRoot -Parent))
    $orbtProjetoTexto = [IO.File]::ReadAllText((Join-Path $Projeto 'project.godot'))
    $orbtPreset = [IO.File]::ReadAllText((Join-Path $Projeto 'export_presets.cfg'))
    $orbtVersao = [regex]::Match($orbtProjetoTexto, '(?m)^config/version="([^"]+)"\s*$').Groups[1].Value
    $orbtVersaoAndroid = [regex]::Match($orbtPreset, '(?m)^version/name="([^"]+)"\s*$').Groups[1].Value
    $orbtCodigo = [regex]::Match($orbtPreset, '(?m)^version/code=([0-9]+)\s*$').Groups[1].Value
    $orbtPacote = [regex]::Match($orbtPreset, '(?m)^package/unique_name="([^"]+)"\s*$').Groups[1].Value
    if (-not $orbtVersao -or $orbtVersao -ne $orbtVersaoAndroid) { throw 'A versão do projeto e a versão Android precisam ser iguais.' }
    if (-not $orbtCodigo -or [long]$orbtCodigo -lt 1 -or [long]$orbtCodigo -gt 2100000000) { throw 'Código Android inválido.' }
    if (-not $orbtPacote) { throw 'Identificador Android ausente.' }
    [pscustomobject]@{ versao=$orbtVersao; codigo=[int]$orbtCodigo; pacote=$orbtPacote }
}

function Conferir-TagAndroidPublicacao {
    param([Parameter(Mandatory)] [string] $Tag, [Parameter(Mandatory)] $Configuracao)
    $orbtPrefixo = 'v' + $Configuracao.versao
    $orbtPadrao = '^' + [regex]::Escape($orbtPrefixo) + '(?:-[0-9A-Za-z]+(?:[.-][0-9A-Za-z]+)*)?$'
    if ($Tag -cnotmatch $orbtPadrao) { throw 'A tag deve corresponder à versão do projeto: vVERSAO ou vVERSAO-sufixo.' }
    [pscustomobject]@{ tag=$Tag; notas=('docs/versoes/' + $Tag + '.md'); previa=($Tag -cne $orbtPrefixo) }
}

function Conferir-PacoteAndroidProjeto {
    param([Parameter(Mandatory)] $Pacote, [Parameter(Mandatory)] $Configuracao)
    if ($Pacote.versao -ne $Configuracao.versao -or $Pacote.codigo -ne $Configuracao.codigo -or $Pacote.pacote -ne $Configuracao.pacote) {
        throw 'O APK não corresponde à versão, ao código ou ao pacote configurados no projeto. Não distribuir esse arquivo.'
    }
}

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

function Ler-DadosSalvosAndroid {
    param([string] $Adb, [string] $Serial, [string] $Pacote, [int] $Usuario)
    $orbtArquivos = & $Adb -s $Serial shell run-as $Pacote --user $Usuario find files -type f 2>&1
    if ($LASTEXITCODE -ne 0) { throw 'Não foi possível conferir os saves pelo aparelho. O teste de preservação está incompleto.' }
    $orbtHashes = @{}
    foreach ($orbtLinha in $orbtArquivos) {
        $orbtArquivo = $orbtLinha.ToString().Trim()
        if ($orbtArquivo -notmatch '^files/[A-Za-z0-9_./-]+$' -or $orbtArquivo -notmatch '/(progresso|checkpoint|preferencias)\.json(\.bak)?$') { continue }
        $orbtHash = & $Adb -s $Serial shell run-as $Pacote --user $Usuario sha256sum $orbtArquivo 2>&1
        if ($LASTEXITCODE -ne 0) { throw 'Não foi possível conferir um arquivo de salvamento. Nenhum arquivo foi removido.' }
        $orbtValor = [regex]::Match(($orbtHash -join ' '), '^([a-fA-F0-9]{64})\s').Groups[1].Value
        if (-not $orbtValor) { throw 'Resposta de integridade dos dados inválida.' }
        $orbtHashes[$orbtArquivo] = $orbtValor.ToLowerInvariant()
    }
    return $orbtHashes
}

function Conferir-DadosSalvosAndroid {
    param([hashtable] $Antes, [hashtable] $Depois)
    if ($Antes.Count -eq 0) { throw 'Não há saves para comprovar preservação. Abra uma fase e ajuste uma preferência antes do teste.' }
    if ($Antes.Count -ne $Depois.Count) { throw 'Os arquivos salvos mudaram durante a atualização. Não publicar antes de investigar.' }
    foreach ($orbtArquivo in $Antes.Keys) {
        if (-not $Depois.ContainsKey($orbtArquivo) -or $Antes[$orbtArquivo] -ne $Depois[$orbtArquivo]) {
            throw 'Um salvamento foi alterado ou removido durante a atualização. Não publicar antes de investigar.'
        }
    }
}
