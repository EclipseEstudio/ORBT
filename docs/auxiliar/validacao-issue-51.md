# Validação dos menus e resultados — issue #51

Execução em 30/10/2026, Windows, Godot 4.7.2, base `8ea8757` com alterações deste PR. `tests/run.ps1`: 910 verificações, zero falhas, incluindo 20 de menus. `tests/run_exportacao.ps1`: PCK exportado e 23 verificações no desktop, zero falhas. O PCK não é um APK instalável.

| Passo | Esperado e observado |
| --- | --- |
| Abrir menu sem checkpoint | Campanha, configurações e créditos disponíveis; Continuar ausente. |
| Abrir créditos e voltar | Colaboradores e origens disponíveis; volta ao menu. A licença da propulsão legada permanece em revisão. |
| Apresentar checkpoint de versão incompatível | Diagnóstico e opção de descarte; Continuar não é oferecido. |
| Pausar e voltar ao menu | Pausa removida, mundo anterior removido e simulação interrompida. |
| Causar derrota | Restaurar checkpoint e Reiniciar disponíveis; a restauração volta à partida. |
| Concluir primeira fase e selecionar Próxima | Sucessora abre, conclusão é preservada e cena anterior é removida. |
| Concluir última fase e repetir | Próxima não aparece; Repetir restaura a tentativa e mantém a conclusão. |

A reabertura com checkpoint válido e configurações em pausa também são cobertas pelas suítes das #49/#50. Ainda é necessária validação no Android com toque, áreas seguras, legibilidade e evidências de aparelho. A revisão da autoria/licença dos bitmaps legados de propulsão permanece na #29; os créditos identificam essa pendência sem inventar licença.
