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

## Ajuste parcial do contraste — issue #31

Sobre a base `e91954b`, uma versão de teste com o ajuste no HUD foi instalada por atualização no mesmo aparelho, com a chave de depuração local. APK SHA-256 `d27ce1e51a74a3e6655191d0079e568d929f653768c9d106fd688d38e98001b0`; assinatura v2/v3 e alinhamento de 16 KB verificados. Os testes automatizados passaram com 1.225 verificações, incluindo 43 visuais; o pacote passou em 23 verificações.

O fundo opaco acompanha apenas os textos de combustível e tempo, sem capturar toques; uma seta indica a Terra quando seu centro está atrás desse texto. Na [captura após a abertura](evidencias-android-2026-10-30/hud-status-ajustado.png), os valores estão legíveis e a maior parte do sprite da Terra aparece. Um arraste simulado iniciado sobre o status lançou a nave, consumiu uma unidade e levou à Terra; [captura durante o voo](evidencias-android-2026-10-30/hud-impulso-ajustado.png). Não houve teste de toque físico ou revisão de outros aparelhos nesta versão.

O sprite e o rótulo da Terra ainda podem ficar parcialmente encobertos pelo status e pelas barras durante o movimento. O ajuste protege a leitura dos valores, mas não resolve toda a oclusão do cenário; manter essa limitação e a avaliação completa da #31 em aberto.

## Espaço do HUD na primeira fase — issue #31

Sobre a base `e94d53a`, o texto do status passou para tamanho 9 e as duas barras passaram a ocupar 65 unidades lógicas no lado esquerdo. No mesmo aparelho, após instalar uma versão com a chave de depuração local, a Terra e seu rótulo ficaram visíveis na [posição inicial](evidencias-android-2026-10-30/hud-espaco-inicio.png) e na [captura durante o primeiro impulso](evidencias-android-2026-10-30/hud-espaco-voo.png). O arraste simulado de 480 pixels para baixo chegou à Terra com combustível 4. Os valores textuais continuam exibidos, mesmo com barras menores.

O APK testado tem SHA-256 `fec29ec8b6fd6f0bde2e628ac61cec4cc0dfcc7ead4061dcb6081342fc9938e6`, assinatura v2/v3 e alinhamento 16 KB verificados. O usuário confirmou que as barras menores de combustível e tempo estão legíveis no celular. A suíte contém verificações de interseção da Terra e seu rótulo com status e barras na proporção 180 × 390; elas falham no layout anterior e passam no novo. A mudança não altera câmera, física ou rota.

As capturas cobrem somente os instantes registrados na primeira fase e um aparelho. Não garantem ausência de oclusão em toda a trajetória, em outras fases ou proporções; permanece necessária a revisão visual completa da #31.

## Checkpoint de pouso intermediário e câmera — issue #49

No Samsung SM-A556E com Android 16/API 36, usando a versão local do ajuste do HUD integrada pelo PR #71 (APK SHA-256 `fec29ec8b6fd6f0bde2e628ac61cec4cc0dfcc7ead4061dcb6081342fc9938e6`), foi aberta a fase 04, `curva_suave` / O Labirinto. O JSON da fase tem SHA-256 `b668f61eeed9da062d0429aed75a18a64f530615e8f0e440ffce3b3f55606190`. Um arraste simulado de `(760, 800)` a `(392, 1109)` em 450 ms levou ao primeiro satélite; a [captura do pouso](evidencias-android-2026-10-30/checkpoint-pouso.png) mostra combustível 2 e tempo 29,1 s.

O checkpoint gravado identificou `apoio_1`, posição aproximada `(300,86; 138,98)`, combustível 2 e tempo 29,0667 s. Após encerramento do processo e reabertura, Continuar restaurou os valores e a partida pausada; ao retomar, a nave reapareceu sobre o mesmo apoio. O arquivo de checkpoint e o progresso conservaram seus hashes antes e depois da reabertura. O teste usou ADB, não um gesto físico, e não simula interrupção durante a gravação.

Na [recuperação anterior à correção](evidencias-android-2026-10-30/checkpoint-antes-camera.png), a câmera ficava centrada na Terra durante a pausa e a nave só aparecia depois de retomar. Com a alteração proposta na câmera, uma nova versão foi instalada por atualização, preservando o mesmo checkpoint e progresso: a [recuperação corrigida](evidencias-android-2026-10-30/checkpoint-camera-corrigida.png) mostra a nave no apoio antes de Retomar, ainda com combustível 2 e tempo 29,1 s. Após Retomar, permaneceu no apoio sem consumir combustível. O APK corrigido tem SHA-256 `fa1b10a91f97da3157eac305dca75f70f61e2d84f312d8f9001e64e92d9e9f24`, confirmado também no APK extraído do aparelho; assinatura v2/v3 e alinhamento de 16 KB verificados.

Godot 4.7.2: 1.228 verificações nas suítes e 23 do pacote. O teste em processo separado detecta o enquadramento antigo e passa com a câmera corrigida. Interrupção de escrita real e checkpoint incompatível ou corrompido no Android continuam pendentes; não alterar os dados do usuário para simulá-los. No Labirinto, a [captura do pouso](evidencias-android-2026-10-30/checkpoint-pouso.png) também mostra um asteroide parcialmente atrás do texto de distância: avaliação de contraste e oclusão geral continua na #31.
