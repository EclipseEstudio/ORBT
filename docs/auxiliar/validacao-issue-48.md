# Validação dos checkpoints — issue #48

Execução em 30/10/2026 no Windows, Godot 4.7.2, base `6c46579` com as alterações deste PR. Executar `./tests/run.ps1 -Godot <caminho-da-Godot-console>`.

`tests/test_checkpoints.gd`: 16 verificações, zero falhas. A suíte completa: 865 verificações, zero falhas.

| Passo | Esperado e observado |
| --- | --- |
| Iniciar fase com apoio | Checkpoint inicial identifica fase e corpo de origem. |
| Pousar em outro apoio com saldo 3 e tempo 12,5; causar derrota e restaurar | Mesma posição relativa, orientação, corpo, saldo e tempo; nave pousada e parada. |
| Pausar com gesto e pedido pendentes, restaurar e avançar | Gesto cancelado; nenhum impulso ou cobrança repetida. |
| Reiniciar após pouso | Posição, tempo e combustível iniciais, checkpoint volta ao início. |
| Pousar com saldo zero e restaurar | Checkpoint registra zero; derrota por falta de combustível permanece. Reiniciar devolve o saldo inicial. |
| Início livre, derrota e restauração | Posição inicial livre e estado pronta restaurados sem apoio residual. |
| Comparar dados da fase antes e depois | JSON autoral preservado. |

Decisão de escopo: checkpoints ficam em memória e são substituídos em todo pouso seguro, inclusive sem combustível. Essa regra mantém o último pouso fiel ao ocorrido e oferece Reiniciar quando não houver saldo. Persistência após encerramento, validação de dados incompatíveis e Continuar são da #49/#51. A revisão da regra de pouso sem saldo e a validação em aparelho continuam pendentes nas #37/#4.
