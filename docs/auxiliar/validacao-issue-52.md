# Validação das dez fases — issue #52

Execução em 30/10/2026, Windows, Godot 4.7.2, base `5e3b3fc` com as alterações deste PR. `tests/run.ps1` passou com 1.164 verificações, zero falhas. `tests/run_exportacao.ps1` passou com 23 verificações no PCK e `tests/test_fases.gd` foi executado contra esse pacote isolado com 482 verificações, zero falhas. O PCK no desktop não equivale a um APK em aparelho.

Os seis IDs anteriores e suas ordens foram preservados. Os quatro novos mapas têm IDs estáveis e dados v1; o editor abre e valida todos os dez sem alterar os arquivos. As rotas são executadas em sequência pelo controlador da campanha com comparação da prévia, consumo e variações de mira. Fases 8 e 9 têm duas rotas opostas, testadas com variação de ±1° em ambos os impulsos. Os passos e ângulos estão em [campanha técnica](../tecnica/campanha.md).

Um save com as seis fases antigas concluídas foi carregado contra o novo catálogo: as conclusões permaneceram e apenas a fase 7 foi liberada. As quatro vistas gerais foram conferidas no Windows/OpenGL com os corpos e a Terra visíveis. O aceite de ergonomia em aparelho e o balanceamento por outra pessoa permanecem na #4/#53.

O arquivo de GDD citado na issue não estava disponível nesta cópia. A sequência usa apenas recursos básicos já integrados; a revisão específica contra o texto do GDD e a aprovação da composição permanecem pendentes na #52. A #53 cobre soluções reproduzidas por outra pessoa e o balanceamento das dez fases.
