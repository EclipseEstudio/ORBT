param([string] $Godot = 'godot', [switch] $Capturar)

$ErrorActionPreference = 'Stop'
$orbtProjeto = Split-Path $PSScriptRoot -Parent
$orbtConfiguracao = Join-Path $orbtProjeto 'project.godot'
$orbtOriginal = [IO.File]::ReadAllBytes($orbtConfiguracao)
$orbtTexto = [IO.File]::ReadAllText($orbtConfiguracao)
$orbtPlugins = 'enabled=PackedStringArray("res://addons/orbt_editor/plugin.cfg")'
if (-not $orbtTexto.Contains($orbtPlugins)) { throw 'Execute com a configuração padrão do plugin ORBT habilitado.' }
$orbtLog = Join-Path $orbtProjeto '.godot/test-plugin.log'
$orbtArgs = @('--path', $orbtProjeto, '--editor', '--max-fps', '60', '--quit-after', '1800', '--log-file', $orbtLog)
if ($Capturar) { $orbtArgs += @('--rendering-method', 'gl_compatibility') } else { $orbtArgs += '--headless' }
try {
    $orbtTexto = $orbtTexto.Replace($orbtPlugins, 'enabled=PackedStringArray("res://addons/orbt_editor/plugin.cfg", "res://tests/editor_harness/plugin.cfg")')
    [IO.File]::WriteAllText($orbtConfiguracao, $orbtTexto, [Text.UTF8Encoding]::new($false))
    $orbtSaida = & $Godot @orbtArgs 2>&1
    $orbtCodigo = $LASTEXITCODE
    $orbtSaida | Write-Output
    if ($orbtCodigo -ne 0 -or ($orbtSaida -match 'SCRIPT ERROR:|ERROR:') -or -not ($orbtSaida -match 'Plugin: \d+ verificações, 0 falhas\.')) {
        throw "Verificação do plugin falhou. Consulte $orbtLog."
    }
} finally {
    [IO.File]::WriteAllBytes($orbtConfiguracao, $orbtOriginal)
}
