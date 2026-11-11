> Registro histórico. Descreve a revisão testada à época; consulte a [documentação atual](../../../README.md) para o comportamento vigente.

# Créditos, câmera e interface — 05/11/2026

Ajustes implementados nesta etapa:

- Créditos com Miguel Alves, Rubens Augusto, Gustavo Costa e Cesar Caus. Seção Equipe e rodapé com WMDG e Godot lado a lado, centralizadas. Logos de 32 pixels lógicos; legendas menores, somente WMDG e versão da Godot, sem título de seção no rodapé. A imagem WMDG enviada foi preservada; a logo oficial da Godot tem atribuição na descrição acessível e licença no pacote.
- Remoção completa da criação e da ação do botão `DescartarCheckpoint` na seleção. Avisos e retentativa de gravação permanecem; visualizar o aviso não apaga os dados.
- Câmera inicia perto e centralizada na nave, com controle imediato. O alvo de zoom varia proporcionalmente à intensidade do arraste entre 1,4× e 0,75× da base autoral. Soltar ou cancelar retorna suavemente ao enquadramento próximo; a exploração manual continua disponível. Distância aos corpos não altera mais o zoom.
- Ícone de repetir redesenhado com ponta na extremidade do arco.
- HUD identifica a fase somente pelo número.

| Captura | Conferência |
| --- | --- |
| [Créditos 180×240](creditos-240.png) | Quatro nomes, seções e logos em tela curta |
| [Créditos 180×320](creditos-320.png) | Logos centralizadas no rodapé |
| [Créditos 180×390](creditos-390.png) | Adaptação ao formato alto |
| [Câmera próxima](camera-proxima.png) | Nave centralizada e número da fase no topo |
| [Arraste médio](camera-arraste-meio.png) | Afastamento intermediário |
| [Arraste máximo](camera-arraste-maximo.png) | Visão mais ampla na força máxima |
| [Retorno](camera-retorno.png) | Mesmo enquadramento próximo após cancelar |
| [Repetir](repetir.png) | Ponta da seta na extremidade do ícone |

Capturas reais com Godot 4.7.2 / Windows / Compatibility/OpenGL / Intel UHD Graphics, em escala inteira 3×. Reprodução: `tests/capturar_ajustes_creditos_camera.gd -- 320`, trocando a altura para 240 ou 390 nas capturas de créditos. As oito imagens foram inspecionadas.

Validação concluída: 3.043 verificações Godot, incluindo subprocessos, 14 PowerShell e 34 do pacote exportado isolado: 3.091 ao todo, sem falhas. Inclui as rotas das dez fases, entrada imediata, zoom proporcional e retorno, exploração/pausa/checkpoint, ausência do botão de descarte, créditos na área segura e inclusão das duas logos e da licença na exportação.

Após simplificar o rodapé dos créditos, foram repetidas as 51 verificações de menus e áreas seguras, sem falhas. As três capturas de créditos foram regeneradas e inspecionadas com logos menores e somente WMDG/versão da Godot nas legendas.

O fundo mais detalhado e as estrelas coletáveis continuam somente no [plano de implementação](../../../tecnica/estrelas-coletaveis.md). Esta etapa não alterou o fundo nem acrescentou a mecânica de coleta. Alterações locais, sem nova publicação de versão. Teste físico no Android ainda pendente.
