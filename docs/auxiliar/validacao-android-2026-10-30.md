# Validação parcial em Android — issues #4 e #49

Em 30/10/2026, o ORBT foi instalado por atualização no Samsung SM-A556E, Android 16/API 36, tela 1080 × 2340. A aplicação já instalada tinha dados de progresso; `adb install -r` foi usado sem desinstalação. A seleção mostrou fases anteriormente concluídas após a atualização. Essa observação não prova a integridade de todos os dados anteriores.

O APK veio da [execução do PR #68](https://github.com/EclipseEstudio/ORBT/actions/runs/41071949641), Godot 4.7.2, merge de teste `6e50b183183c0e3cccfa8e76a8e89e8ee437e173`. A árvore desse merge é idêntica à da `alpha` integrada `e5e3b0b`. Para compatibilidade com o aplicativo existente, foi assinada uma cópia com a chave de depuração local correspondente à assinatura instalada. A cópia instalada tem SHA-256 `edf22d3587532980783861e735860d4b257f5c694bcdb8d750c71039282849eb`; o APK original do pipeline tem SHA-256 `dce9d266042980612877d847e6c79f51a3c64627dd24e499e38c183be64da7a9`. O APK instalado foi extraído do aparelho e seu hash coincidiu com o da cópia assinada. A assinatura v2/v3 e o alinhamento de 16 KB da cópia foram verificados.

Os comandos abaixo simularam toques via ADB; eles não demonstram operação física, ergonomia, multitouch nem desempenho percebido. Fase `teste_001.json`, SHA-256 `ffb8a48ac3daf06de560737c393ee72603eb4af6ae9e3c750fcfad089c0f05ad`.

Após esses comandos, o usuário foi convidado a testar toque parado, cancelamento e a rota até a Terra com o dedo e informou: “O jogo está funcionando corretamente”. O relato não detalhou o resultado individual de cada gesto nem a ergonomia.

| Cenário | Resultado observado |
| --- | --- |
| Abrir o aplicativo e selecionar Campanha > Primeiro impulso | Menu e fase carregaram; após a apresentação, combustível 5, tempo 30,0 s, distância à Terra 162 m. [Captura](evidencias-android-2026-10-30/fase.png). |
| Toque parado na área de jogo | Sem lançamento ou consumo; tela e combustível permaneceram iguais. |
| Arrastar verticalmente de `(540, 800)` a `(540, 1280)` em 450 ms | Nave iniciou voo e combustível passou de 5 para 4. [Captura](evidencias-android-2026-10-30/impulso.png). |
| Aguardar o voo | Resultado “Terra alcançada”, combustível 4 e tempo 27,9 s. [Captura](evidencias-android-2026-10-30/vitoria.png). |
| Repetir fase, pausar, encerrar o processo e reabrir | Menu ofereceu Continuar; ao selecionar, a fase abriu pausada com combustível 5 e tempo 30,0 s. [Captura](evidencias-android-2026-10-30/continuar.png). É uma verificação do checkpoint inicial, não de pouso intermediário nem interrupção de gravação. |

Na captura da fase após a apresentação, o sprite e o rótulo da Terra ficam parcialmente atrás do HUD de combustível; durante o voo, o HUD também encobre parte do sprite. Isso merece revisão de legibilidade e composição no aparelho em #31/#4. A captura de recuperação foi feita durante a apresentação da câmera com a partida pausada; o enquadramento deve ser avaliado ao retomar.

Continuam pendentes o registro detalhado dos gestos físicos e da ergonomia, multitouch, exploração/recentralização, suspensão com gesto ativo, reinício, derrota, último combustível, pouso e correção; também a reprodução por outro integrante, checkpoint intermediário, falha de gravação e checkpoint incompatível no Android. Estes resultados não encerram as issues #4, #49, #31 ou #54.
