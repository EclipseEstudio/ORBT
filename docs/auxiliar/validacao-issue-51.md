# Validação dos menus e resultados — issue #51

Após o PR #82 (`8f7f63f`), o rodapé de pausa/resultados permite rolagem vertical e fica limitado ao espaço abaixo do status, dentro da área segura. Durante o jogo, as dicas continuam permitindo toque/arraste. [Cenários e capturas](validacao-rolagem-resultados.md); teste físico Android permanece pendente.

Após o PR #80 (`cc449e9`), Voltar nativo e Escape passam a navegar pelas telas auxiliares/campanha e pausar a fase. Retomar continua explícito; saída nativa ocorre somente no menu principal. [Fluxo, testes e capturas](validacao-voltar.md). Notificação nativa foi injetada em desktop; validação física Android permanece pendente.

Após integração do PR #77 (`1604781`): menu principal, configurações e créditos passam a respeitar a área segura. Menu e configurações permitem rolagem quando o conteúdo não cabe, incluindo diagnósticos longos. [Evidências e limites](validacao-areas-menus.md); toque e recortes reais Android permanecem pendentes.

Continuidade após PR #76, base `9f3187a`: a propulsão legada foi substituída por seis quadros desenhados em código para ORBT. Créditos descrevem a nova origem e o preset exclui os bitmaps antigos. [Registro e capturas](arte/propulsao/README.md). A origem histórica dos arquivos antigos não foi determinada; a distribuição atual deixa de depender deles. Validação de menus e apresentação em Android continua pendente.

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
