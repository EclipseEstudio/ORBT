# Aceite da issue 40 — desbloqueio e conclusão de fases

Execução em 29/10/2026, Windows, Godot `4.7.2.stable.official.ed1daf0bf`. Código de referência: `main` em `a774a82` (PR #46), reconciliado com `alpha` em `09cb305`; testes de aceite em `2dc4b5bb3001e63fe13127d18f7bd88c0e8dcd9e`, branch `codex/issue-40-alpha`.

Os quatro critérios de [#40](https://github.com/EclipseEstudio/ORBT/issues/40) foram demonstrados pelo controlador de produção com serviço persistente e um catálogo temporário de duas fases. Os arquivos autorais e os saves do jogador são preservados; os dados temporários são removidos ao terminar.

| Passos | Resultado esperado e observado |
| --- | --- |
| Iniciar sem save e pedir a segunda fase diretamente e pela seleção | Só a primeira disponível; a segunda é rejeitada com feedback. A sentinela do gerenciador permanece intacta, comprovando bloqueio antes do carregador; nenhum save é criado. |
| Abrir a primeira fase e emitir vitória; reiniciar e vencer novamente | Primeira concluída e segunda disponível. A segunda vitória preserva o conteúdo do save, com uma conclusão e apenas os dois IDs liberados. |
| Fechar o controlador e abrir outro processo da Godot com os mesmos arquivos | O novo controlador restaura a primeira concluída e a segunda disponível; a seleção oferece Repetir e acesso à próxima fase. O processo imprime `PROGRESSO_REABERTO` somente após todas as verificações passarem. |
| Vencer a segunda e última fase e retornar à seleção | Duas conclusões e dois IDs liberados; nenhum ID seguinte inventado. Seleção navegável com ambas as ações Repetir. |
| Repetir a primeira após a última vitória e reler o save | Combustível 3, tempo 30 e contatos vazios; abrir a repetição preserva o save, que restaura ambas as conclusões. |

`tests/test_persistencia.gd` executa a primeira parte e inicia `tests/verificar_progresso.gd` em processo separado. `tests/test_campanha.gd` também cobre bloqueio, vitória pela simulação de voo, seleção e repetição. `tests/test_exportacao.gd` confirma vitória, gravação/restauração e repetição usando somente recursos do PCK exportado em pasta isolada.

## Reprodução e resultados

Com a Godot no PATH, ou substituindo `godot` pelo caminho completo do executável:

```powershell
godot --headless --path . --editor --import --quit
./tests/run.ps1 -Godot godot
./tests/run_editor_plugin.ps1 -Godot godot
./tests/run_exportacao.ps1 -Godot godot
```

| Suíte | Verificações | Falhas |
| --- | ---: | ---: |
| Controles | 69 | 0 |
| Partida | 142 | 0 |
| Editor | 32 | 0 |
| Campanha | 31 | 0 |
| Visual | 38 | 0 |
| Persistência, processo principal | 28 | 0 |
| Reabertura, processo separado | 9 | 0 |
| Pacote exportado | 23 | 0 |
| Ciclo do plugin no editor | 11 | 0 |
| **Total** | **383** | **0** |

A contagem de persistência inclui uma asserção sobre o sucesso do subprocesso; as nove verificações internas de reabertura estão discriminadas. A [saída resumida da execução](evidencias/issue-40-2026-10-29.txt) foi extraída dos logs da Godot. Importação, suíte, plugin e pacote terminaram sem `ERROR:` ou `SCRIPT ERROR:`.

## Limites do aceite

Este registro conclui os quatro critérios funcionais da #40 no Windows. O PCK foi executado no desktop. O catálogo autoral continua com uma fase; os testes usam duas/três fases temporárias para demonstrar progressão.

O APK de 29/10/2026 e seu hash estão em [android.md](android.md). Não houve execução em aparelho nesta validação. Instalação, toque físico, ergonomia e persistência após reabertura no Android continuam no aceite integrado de [#4](https://github.com/EclipseEstudio/ORBT/issues/4) e na navegação de [#38](https://github.com/EclipseEstudio/ORBT/issues/38). Checkpoints, Continuar e preferências permanecem fora desta entrega.
