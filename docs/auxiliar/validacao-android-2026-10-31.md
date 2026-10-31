# Teste breve no Android e importação limpa — 31/10/2026

## Aparelho e versão

Samsung SM-A556E, Android 16, tela 1080 × 2340. Código da `alpha` em `61a2b091f7829b6b8a8266deaa9a0984a8d09e72` (PR #84 integrado), Godot 4.7.2. Uma cópia dos arquivos versionados foi exportada com apenas nome e identificador alterados no preset: **ORBT QA 31**, `com.eclipseestudio.orbt.qa20261031`. Instalação independente, sem atualizar o ORBT principal.

APK de depuração SHA-256 `1b30d2e8f5715610f3b23c8df5d23e7722b0a8ffe42c30e807f25602ffb2f7f6`; assinatura v2/v3 e alinhamento de 16 KB verificados. A cópia QA ficou instalada para experimentação manual.

## Observações no aparelho

Toques e Voltar foram enviados pelo ADB. As capturas demonstram os estados observados; ergonomia, gestos físicos, multitouch e desempenho percebido continuam fora deste teste breve.

| Cenário | Resultado observado |
| --- | --- |
| Menu → Configurações; alterar música; Voltar nativo → Campanha | Campanha abriu e a primeira fase ficou disponível. Música ajustada para 45%. |
| Primeira fase; Voltar nativo | [Pausa](evidencias-android-2026-10-31/voltar-configuracoes.png), combustível 5, tempo 30,0 s. |
| Configurações durante a pausa; Voltar nativo | [Configurações](evidencias-android-2026-10-31/configuracoes-pausa.png) mostraram música 45%; Voltar retornou à [partida pausada](evidencias-android-2026-10-31/voltar-configuracoes.png). |
| Encerrar o processo QA; reabrir; Continuar | [Menu ofereceu Continuar](evidencias-android-2026-10-31/menu-continuar.png); abriu a [fase pausada](evidencias-android-2026-10-31/continuar.png), combustível 5 e tempo 30,0 s. O arquivo de preferências manteve música `0.45`. Trata-se do checkpoint inicial. |
| Retomar; arrastar de `(540, 800)` a `(540, 1280)` em 450 ms | [Terra alcançada](evidencias-android-2026-10-31/resultado.png), combustível 4 e tempo 27,9 s. |

Os hashes do checkpoint e progresso da instalação principal foram iguais antes do teste e após reabrir a cópia QA:

```text
checkpoint.json 4ce439ba9b6c95212650ff2dc2d1819d3c4c39ffef50e0c2674a3ba7ba219c7e
progresso.json  040f39efdd632002ae523a008e13d86c6896cabb0e9e9c881a45c9b4ecdc343f
```

## Correção encontrada na preparação

A primeira importação de uma cópia sem `.godot` registrou `Cannot infer the type of "instancia"` em `controlador_jogo.gd:112`, impedindo a compilação de `global.gd`. A segunda importação da mesma cópia concluiu. A variável agora declara explicitamente `Node2D`, tipo retornado pelo gerenciador, evitando depender da inferência pela referência global durante a importação inicial.

Comparação em duas novas cópias do mesmo arquivo `git archive`, no mesmo ambiente Godot, com diretórios de configuração graváveis:

| Fonte na primeira importação | Resultado |
| --- | --- |
| `61a2b09` sem alteração | Reproduziu o erro de inferência e a falha de compilação de `global.gd`, mesmo retornando código 0. |
| `61a2b09` com a declaração explícita | Código 0, sem `ERROR:` nem `SCRIPT ERROR:`. |

Comando de importação: `Godot --headless --editor --path <copia-sem-cache> --import`. Como o processo pode retornar 0 apesar do erro, a etapa de importação do fluxo Android passa também a rejeitar essas mensagens, seguindo o critério já usado nas suítes.

O APK testado no aparelho precede essa alteração de tipagem. A correção foi validada no computador por importação limpa, 2.741 verificações das suítes e 30 do pacote exportado, todas sem falhas. A condição usada no fluxo Android rejeitou o log da cópia de controle e aceitou o da cópia corrigida.
