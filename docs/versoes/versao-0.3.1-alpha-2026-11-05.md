# ORBT 0.3.1 alpha — 05/11/2026

Validação local final: 2.991 verificações da suíte e do pacote, mais 11 do plugin no editor real, todas aprovadas (3.002 no total). A cena inicial usa caminho explícito para abrir sem depender da resolução antecipada de UID durante a inicialização do editor.

Esta versão reúne a interface baseada no wireframe, os ajustes de voo e as alterações pendentes do editor de fases. A página de download publicada em `main` consulta as Releases do GitHub e oferece automaticamente o APK publicado mais recentemente.

- Press Start 2P na interface, com licença OFL incluída; ORBT conserva a fonte do logotipo.
- Splash somente Eclipse Estudio, menu com nave e planeta, Configurações e Créditos com cabeçalho igual ao de Fases.
- Seleção de cinco colunas, sem botão de retomada persistida; avisos, salvamento pendente e descarte preservados.
- HUD com fase, olho, pausa, combustível e barra de oxigênio. Bússola para a Terra e linha do toque com indicação de força saturada.
- Um gesto consome uma carga; gastar a última carga permite deriva e vitória. O oxigênio esgotado encerra o voo; pouso em apoio sem combustível encerra a tentativa.
- Editor com desfazer/refazer, agrupamento de arraste e duplicação de corpos e pares de portais; corrigida a inferência de tipo que impedia compilar essas alterações.
- Referências visuais, fase de trabalho, página de download, documentação e capturas incluídas no repositório; referências e ferramentas de autoria permanecem excluídas do aplicativo.

Versão interna 0.3.1, código Android 4. A suíte completa de testes e a verificação do pacote exportado passaram. As [capturas da interface](../historico/evidencias/evidencias-ui-2026-11-05/README.md) foram revisadas nas alturas lógicas 240, 320 e 390 px. O aceite físico desta revisão no Android permanece pendente. A distribuição é experimental, por prerelease; a criação do PR não integra automaticamente as mudanças na `alpha`.
