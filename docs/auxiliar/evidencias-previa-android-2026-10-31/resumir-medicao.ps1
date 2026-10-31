$ErrorActionPreference='Stop'
function Percentil($Valores, [double] $P) {
    $orbtOrdenados=@($Valores | Sort-Object)
    return $orbtOrdenados[[Math]::Max(0,[Math]::Ceiling($orbtOrdenados.Count*$P)-1)]
}
$orbtResumo=@()
foreach ($orbtArquivo in (Get-ChildItem -LiteralPath $PSScriptRoot -Filter 'previa-qa-*.json')) {
    $orbtDados=Get-Content -LiteralPath $orbtArquivo.FullName -Raw | ConvertFrom-Json
    if ($orbtDados.amostras.Count -ne 300 -or $orbtDados.aquecimento -ne 60) { throw 'Quantidade de amostras inesperada.' }
    $orbtCustos=@($orbtDados.amostras.custo_us)
    $orbtResumo += [pscustomobject]@{
        arquivo=$orbtArquivo.Name
        fase=$orbtDados.fase
        amostras=$orbtCustos.Count
        condicoes=@($orbtDados.amostras.condicao | Sort-Object -Unique)
        media_us=($orbtCustos | Measure-Object -Average).Average
        p50_us=Percentil $orbtCustos 0.5
        p95_us=Percentil $orbtCustos 0.95
        max_us=($orbtCustos | Measure-Object -Maximum).Maximum
        pontos_min=($orbtDados.amostras.pontos | Measure-Object -Minimum).Minimum
        pontos_max=($orbtDados.amostras.pontos | Measure-Object -Maximum).Maximum
        fps_engine_min=($orbtDados.amostras.fps_engine | Measure-Object -Minimum).Minimum
        fps_engine_max=($orbtDados.amostras.fps_engine | Measure-Object -Maximum).Maximum
        intervalo_p95_us=Percentil @($orbtDados.amostras.intervalo_us) 0.95
    }
}
if ($orbtResumo.Count -eq 0) { throw 'Ainda não há medições Android para resumir.' }
$orbtResumo | ConvertTo-Json -Depth 5 | Set-Content -Encoding utf8 (Join-Path $PSScriptRoot 'resumo-medicao.json')
$orbtResumo | ConvertTo-Json -Depth 5
