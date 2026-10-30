# Validação do áudio — issue #55

Execução em 30/10/2026, Windows, Godot 4.7.2, base `ccfe719` com as alterações deste PR. `tests/run.ps1`: 1.206 verificações, zero falhas, incluindo 21 específicas de áudio. `tests/run_exportacao.ps1`: 23 verificações no PCK; `tests/test_audio.gd` executado contra o PCK isolado: 21 verificações, zero falhas. Testes automatizados usam driver sem saída sonora e não avaliam qualidade auditiva.

| Comportamento | Esperado e observado |
| --- | --- |
| Menu e fase | Faixas distintas com repetição; troca com transição de 0,35 s e um único reprodutor ativo ao final. Repetir a seleção atual não reinicia a música. |
| Impulso, pouso, entrada em proximidade, derrota e vitória | Cada evento aciona seu efeito; entrada em proximidade tem intervalo mínimo de três segundos. Vitória/derrota têm prioridade quando os canais de efeito estão ocupados. |
| Pausa | Música e sons de interface continuam; efeitos da simulação são pausados e eventos não iniciam efeitos de jogo enquanto pausado. |
| Preferências | `Musica` e `Efeitos` respeitam volumes independentes; zero silencia o canal. Os testes de preferências também verificam persistência. |
| Transição para menu | Música do menu é restaurada e efeitos de jogo anteriores são interrompidos. |

## Recursos e origem

As duas trilhas e seis efeitos em `Recursos/Audio/` foram sintetizados especificamente para ORBT pelo script `scripts/gerar_audio.gd`, sem bibliotecas ou amostras de terceiros. A faixa do menu usa sequência de notas mais rápida; a faixa da fase usa notas mais espaçadas. O script produz WAV mono de 22.050 Hz; os arquivos `.import` registram a importação da Godot. Não há licença pública adicional declarada para esses recursos; a licença geral do repositório não foi identificada. Créditos no jogo registram a origem sem atribuir licença inexistente.

Para reproduzir os recursos, executar `godot --headless --path . --script scripts/gerar_audio.gd` e importar o projeto. O controlador usa dois reprodutores de música e quatro canais para efeitos de jogo, além de um para botões. As trilhas repetem com extremos suavizados; a transição usa fade. Testes que não verificam áudio o desativam no controlador, sem afetar o padrão do jogo.

Ainda é necessário escutar no aparelho, com alto-falante, fones e som desligado, registrando revisão/APK, dispositivo, Android e resultado; conferir volumes, cortes, equilíbrio, repetição e inteligibilidade dos alertas. Esses testes e a avaliação subjetiva das composições não foram realizados nesta execução. A #55 permanece aberta para revisão e aceite.
