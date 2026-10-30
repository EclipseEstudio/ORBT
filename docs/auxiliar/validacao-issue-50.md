# Validação de configurações — issue #50

Execução em 30/10/2026, Windows, Godot 4.7.2, base `03c80e3` com as alterações deste PR. `tests/run.ps1`: 890 verificações, zero falhas, incluindo 12 de preferências e reabertura em processo separado com três verificações. `tests/run_exportacao.ps1`: PCK exportado, 23 verificações, zero falhas. O PCK foi testado no desktop e não substitui teste em aparelho Android.

| Cenário | Esperado e observado |
| --- | --- |
| Arquivo ausente | Música e efeitos iniciam em 100%. |
| Alterar música para 25% e efeitos para 75% no menu; reabrir em outro processo | Valores persistem e são aplicados aos canais independentes. |
| Abrir configurações enquanto pausado, silenciar música e voltar | Efeitos não são silenciados; partida continua pausada e checkpoint/progresso não mudam. |
| Dados inválidos ou ausentes | Padrões utilizáveis; dados inválidos geram aviso. |
| Destino de gravação indisponível | O ajuste vale na sessão e aparece aviso de falha. |

O contrato dos canais `Musica` e `Efeitos` está em [campanha](../tecnica/campanha.md). A #55 deve usá-los ao integrar o áudio. Revisar acessibilidade, alvos de toque e legibilidade no Android; não há músicas ou efeitos nesta entrega.
