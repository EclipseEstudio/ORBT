param([string] $Godot = 'godot')

$ErrorActionPreference = 'Stop'
Push-Location (Split-Path $PSScriptRoot -Parent)
try {
    foreach ($orbtTest in @('tests/test_controles.gd', 'tests/test_partida.gd', 'tests/test_gravidade_issue_13.gd', 'tests/test_checkpoints.gd', 'tests/test_checkpoint_persistente.gd', 'tests/test_preferencias.gd', 'tests/test_retentar_preferencias.gd', 'tests/test_menus.gd', 'tests/test_voltar.gd', 'tests/test_areas_menus.gd', 'tests/test_layout_resultados.gd', 'tests/test_tutorial.gd', 'tests/test_audio.gd', 'tests/test_narrativa.gd', 'tests/test_inicio_livre.gd', 'tests/test_editor.gd', 'tests/test_campanha.gd', 'tests/test_campanha_layout.gd', 'tests/test_fases.gd', 'tests/test_visual.gd', 'tests/test_persistencia.gd')) {
        New-Item -ItemType Directory -Path .godot -Force | Out-Null
        $orbtLog = Join-Path (Get-Location) ('.godot/' + [IO.Path]::GetFileNameWithoutExtension($orbtTest) + '.log')
        $orbtOutput = & $Godot --headless --path . --script $orbtTest --quit-after 1200 --log-file $orbtLog 2>&1
        $orbtExit = $LASTEXITCODE
        $orbtOutput | Write-Output
        if ($orbtExit -ne 0 -or ($orbtOutput -match 'SCRIPT ERROR:|ERROR:') -or -not ($orbtOutput -match 'verificações, 0 falhas\.')) {
            throw "Falha em $orbtTest (código $orbtExit)."
        }
    }
} finally {
    Pop-Location
}
