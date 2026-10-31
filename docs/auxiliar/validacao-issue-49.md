# Validação da persistência de checkpoint — issue #49

Após o PR #83 (`9f79864`), um pouso não gravado fica pendente em memória e pode ser salvo novamente pelo menu. Continuar só volta a ser oferecido depois da gravação, evitando a restauração silenciosa de uma cópia antiga. [Testes de falha/recuperação e capturas](validacao-retentar-checkpoint.md). A pendência é do processo atual; a nova retentativa ainda precisa de validação Android.

Execução em 30/10/2026, Windows, Godot 4.7.2, base `f02ea60` com alterações deste PR. `tests/run.ps1` aprovou 878 verificações, incluindo 13 verificações de persistência de checkpoint e uma segunda execução de processo com mais cinco verificações. `tests/run_exportacao.ps1` exportou o PCK e aprovou 23 verificações em desktop. Não é teste em Android nem APK instalável.

| Cenário | Esperado e observado |
| --- | --- |
| Iniciar `teste_001`, pousar no apoio com combustível 3 e tempo 12,5 | Arquivo de checkpoint e cópia do anterior foram gravados em caminhos de teste isolados. |
| Destruir controlador e abrir outro processo Godot; acionar Continuar no menu | Apoio, saldo e tempo corretos, partida pausada, nave parada e gesto cancelado. |
| Alterar versão do conteúdo | Recuperação recusada com diagnóstico e escrita bloqueada. |
| Falhar gravação e corromper arquivo principal | Falha preserva último arquivo; cópia anterior é recuperada com aviso. Sem cópia válida, há diagnóstico e bloqueio até descarte explícito. |
| Exportar PCK e executar o teste no pacote | 23 verificações, zero falhas; o teste usa caminhos isolados de progresso e checkpoint. |

O save tem versão de formato e conteúdo, checksum e gravação em temporário com cópia anterior. O checkpoint é separado do arquivo de progresso e dos JSONs autorais. No início de uma nova fase ou pouso o checkpoint é substituído; vitória descarta o checkpoint. Após reabrir, o jogador continua pausado. O teste automatizado não reproduz corte de energia físico: simula falha de escrita e arquivo principal corrompido. O aceite no Android exige encerrar e reabrir o aplicativo, testar interrupção e incompatibilidade, e registrar aparelho, versão e resultados, conforme #49/#4.
