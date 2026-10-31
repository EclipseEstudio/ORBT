# Validação de configurações — issue #50

Após o PR #79 (`0a70437`), foi corrigida a aplicação duplicada da área segura ao abrir configurações na pausa. O fundo passa a cobrir o viewport; a margem interna corresponde a um único recuo. [Teste antes/depois e capturas](validacao-configuracoes-pausa.md). A validação em aparelho Android permanece pendente.

Continuidade após PR #77: configurações passam a respeitar área segura e permitem rolagem vertical em telas curtas. Volumes e retorno são alcançáveis com recortes simulados; preferências e pausa mantêm seus testes. [Evidências e limites](validacao-areas-menus.md). Validação com recortes reais e toque Android permanece pendente.

Execução em 30/10/2026, Windows, Godot 4.7.2, base `03c80e3` com as alterações deste PR. `tests/run.ps1`: 890 verificações, zero falhas, incluindo 12 de preferências e reabertura em processo separado com três verificações. `tests/run_exportacao.ps1`: PCK exportado, 23 verificações, zero falhas. O PCK foi testado no desktop e não substitui teste em aparelho Android.

| Cenário | Esperado e observado |
| --- | --- |
| Arquivo ausente | Música e efeitos iniciam em 100%. |
| Alterar música para 25% e efeitos para 75% no menu; reabrir em outro processo | Valores persistem e são aplicados aos canais independentes. |
| Abrir configurações enquanto pausado, silenciar música e voltar | Efeitos não são silenciados; partida continua pausada e checkpoint/progresso não mudam. |
| Dados inválidos ou ausentes | Padrões utilizáveis; dados inválidos geram aviso. |
| Destino de gravação indisponível | O ajuste vale na sessão e aparece aviso de falha. |

O contrato dos canais `Musica` e `Efeitos` está em [campanha](../tecnica/campanha.md). A #55 deve usá-los ao integrar o áudio. Revisar acessibilidade, alvos de toque e legibilidade no Android; não há músicas ou efeitos nesta entrega.
