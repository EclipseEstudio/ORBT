# Executar testes

Fonte dos comandos e cobertura: `tests/run.ps1`, `run_exportacao.ps1`, `run_editor_plugin.ps1` e respectivas suítes. Execute na raiz do repositório. Use Godot 4.7.2, a versão fixada no CI; `-Godot` aceita nome no PATH ou caminho completo.

## Verificações automatizadas

```powershell
godot --headless --path . --editor --import --quit
./tests/run.ps1 -Godot godot
./tests/run_exportacao.ps1 -Godot godot
./tests/run_editor_plugin.ps1 -Godot godot
```

O primeiro importa recursos e UIDs. `run.ps1` executa a verificação PowerShell de atualização Android e as suítes GDScript listadas no próprio arquivo; exige marcador de zero falhas e rejeita `ERROR:`/`SCRIPT ERROR:` mesmo com saída zero. Logs ficam em `.godot/`.

`run_exportacao.ps1` exporta um PCK pelo preset Android e executa verificações em pasta isolada. Requer modelos de exportação. Comprova recursos/scripts e exclusões no pacote executado em desktop; não gera aceite de APK ou aparelho.

`run_editor_plugin.ps1` habilita temporariamente o harness, executa no editor e restaura `project.godot` no `finally`. `-Capturar` usa renderização real. Evite editar a configuração durante sua execução.

Para uma suíte isolada:

```powershell
godot --headless --path . --script tests/test_decolagem.gd
```

Em outros sistemas, execute os GDScripts individualmente e confira saída e logs. Os runners de exportação/assinatura são PowerShell e incluem caminhos de ferramentas Windows.

## Cobertura

| Área | Suítes representativas |
| --- | --- |
| Entrada/mira | `test_controles`, `test_decolagem`, `test_mira_leve`, `test_ajustes_interface_voo` |
| Física/partida | `test_partida`, `test_gravidade_issue_13`, `test_inicio_livre`, `test_revisao_jogabilidade` |
| Campanha | `test_campanha`, `test_fases`, `test_campanha_30`, `test_progresso_estrelas` |
| Mecânicas | `test_orbitas`, `test_rotacao`, `test_portais`, `test_estrelas` |
| Persistência | `test_persistencia`, `test_checkpoints`, `test_checkpoint_persistente`, `test_retentar_checkpoint`, `test_reset_progresso` |
| UI/áudio | `test_ui_redesign`, `test_estrelas_ui`, `test_hud_voo`, `test_fim_de_jogo`, `test_audio`, `test_opcoes_jogador` |
| Editor | `test_editor`, `test_editor_estrelas`, harness de `tests/editor_harness/` |

Os nomes acima omitem `.gd` por concisão. A lista executável completa permanece no runner, evitando duplicar contagens que mudam a cada revisão.

## Capturas e aparelho

```powershell
godot --path . --script tests/capturar_ui.gd
godot --path . --rendering-method gl_compatibility --script tests/capturar_campanha30.gd
```

Scripts `capturar_*` precisam de renderização real e gravam saídas locais, normalmente em `.godot/`. Não adicionar automaticamente cada captura ao Git. Para evidência durável, registre revisão, ambiente, procedimento e observações em `docs/historico/`.

Alguns ensaios alteram dados temporários/fixtures; use os runners e não interrompa durante gravações. Testes de rotas são determinísticos e não substituem avaliação com jogadores, som, ergonomia ou tempo de quadro no Android. Use o [roteiro no aparelho](../tecnica/android.md#roteiro-no-aparelho).
