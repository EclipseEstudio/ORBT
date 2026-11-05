# Campanha de 20 fases e estrelas — 05/11/2026

Candidato 0.4.0 alpha / código Android 7. A campanha apresenta mira, obstáculos, pousos, segundo impulso, gravidade e órbitas em dificuldade progressiva.

## Verificação local

- 35 suítes Godot: 2.482 verificações, zero falhas.
- Regras de atualização Android em PowerShell: 24 verificações, zero falhas.
- Pacote exportado executado isoladamente: 57 verificações, zero falhas.
- Total: 2.563 verificações aprovadas.
- Rotas das 20 fases: 1.167 verificações, incluídas no total Godot. Cada fase tem uma rota econômica com duas estrelas e uma rota de três estrelas com dois impulsos adicionais. O teste confirma conclusão, custos, oxigênio, limites do impulso e desbloqueio pelo controlador de produção.
- Medição adicional: 20 rotas, nenhuma falha nominal, incluindo coleta completa, espera e herança do movimento orbital.
- Revisão independente: coleta, progresso, editor e rotas reexecutados sem falhas.

Os testes cobrem migração do progresso anterior, recordes, derrota sem confirmação de estrelas, portais, último pouso e reinício. A interface foi conferida em 180×240, 180×320 e 180×390.

## Capturas

`campanha.png`, `fase.png` e `resultado.png` foram obtidos com o renderizador real. A seleção usa progresso demonstrativo controlado para apresentar estados concluído, disponível e bloqueado; não contém dados pessoais. Reprodução: `tests/capturar_estrelas.gd`.

## Distribuição

O APK de publicação será produzido pelo GitHub Actions do PR e conferido contra a assinatura, pacote e versão da 0.3.3 publicada. A release acompanha `revisao.txt`, `atualizacao.json` e `SHA256SUMS.txt` do arquivo distribuído. O PR permanece aberto para revisão.

Nenhum aparelho estava conectado nesta preparação. Conforto da mira, desempenho e atualização pelo instalador do telefone nesta revisão permanecem sujeitos ao teste dos jogadores; a versão é uma prerelease.
