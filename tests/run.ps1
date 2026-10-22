param([string] $Godot = 'godot')

$ErrorActionPreference = 'Stop'
Push-Location (Split-Path $PSScriptRoot -Parent)
try {
    foreach ($orbtTest in @('tests/test_controles.gd', 'tests/test_partida.gd', 'tests/test_editor.gd')) {
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
