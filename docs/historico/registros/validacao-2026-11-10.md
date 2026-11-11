# Validação técnica de 10/11/2026

Execução local sobre `release/0.5.0`, revisão `9a58d2deac32f80ff6b053e4e500cb7fdad14f1b`, sem alteração de código do jogo, fases ou IDs. Godot 4.7.2 stable, Windows, OpenGL 3.3 Compatibility, Intel UHD Graphics.

**Resultado:** 40 suítes GDScript e teste PowerShell concluídos, sem falhas; pacote exportado e harness do editor aprovados. Testes Android não executados: o servidor ADB falha antes de enumerar dispositivos. Esta execução não concede aceite em aparelho, escuta/vibração ou playtest por outro integrante.

## Resultados reproduzíveis

| Execução | Resultado | Evidência |
| --- | --- | --- |
| Importação headless com APPDATA isolado | Concluída; sem erros funcionais | Runtime em build/validacao-20261110 |
| tests/run.ps1 | 3.042 verificações reportadas, zero falhas | [Log](../evidencias/validacao-2026-11-10/suites-desktop.log), [resumo por suíte](../evidencias/validacao-2026-11-10/suites-resumo.json) |
| tests/run_exportacao.ps1 | 67 verificações, zero falhas | [Log](../evidencias/validacao-2026-11-10/exportacao.log) |
| tests/run_editor_plugin.ps1 | 11 verificações headless; 12 com renderização, zero falhas em ambas | [Headless](../evidencias/validacao-2026-11-10/editor-plugin.log), [renderizado](../evidencias/validacao-2026-11-10/editor-render.log) |
| tests/capturar_campanha30.gd | Zero falhas nas verificações de pixels: interior visível e exterior oculto no voo/mapa | [Log](../evidencias/validacao-2026-11-10/capturas-campanha.log) |
| tests/capturar_ui.gd | Capturas realizadas sem erros da engine; não é ensaio completo de ergonomia | [Log](../evidencias/validacao-2026-11-10/capturas-ui.log) |

As 3.042 verificações incluem a saída do processo filho de reabertura (9). O runner principal lista 40 scripts GDScript e executa também o teste PowerShell Android (24). Não somar as 11 verificações headless às 12 renderizadas como cobertura independente: repetem o mesmo harness, com uma verificação adicional de captura.

PCK produzido nesta execução, SHA-256: `89F7337C7E29F39DBC1489107B4D7D3132F50FC9B7D20C9A35C4E3C393E0B6F2`. É pacote de recursos executado em desktop, não APK instalado nem o APK da Release.

## Campanha e composição

`test_fases.gd` passou com 1.209 verificações: vinte fases iniciais, rotas econômicas, margens autorais e rotas de três douradas/azuis. `test_campanha_30.gd` passou com 252 verificações: metadados das 30 fases, recursos, portões e rotas das dez finais, com todas as estrelas e tanques previstos.

A simulação usa partidas e integrador reais com passos determinísticos; não é uma pessoa executando gestos no telefone. Testemunhas de rota comprovam viabilidade nas condições testadas, sem comprovar dificuldade adequada, descoberta das rotas, margem em todas as condições ou entendimento.

Revisão documental da sequência: fases 1–3 apresentam impulso, força/coleta e obstáculos; 4–8 apresentam pouso, correção, tanques e giro; 9–10 gravidade/perigo solar; 11–20 combinam translação orbital, faixas e escalas; 21–22 apresentam portais; 23–30 combinam nebulosa, instrumentos e recursos já existentes. A [extração dos textos/IDs](../evidencias/validacao-2026-11-10/revisao-didatica.json) usa somente o catálogo vigente, excluindo exemplos.

A #52 pode ser encerrada no escopo de conteúdo existente: os 30 arquivos abrem, a composição foi revisada e não houve alteração de IDs/content_version. A #53 permanece aberta para outro integrante completar a campanha e avaliar dificuldade/precisão. A revisão dos textos em #54 deve considerar que há dicas que referem A/B enquanto a apresentação atual não mostra nomes/linhas nos portais, e a fase 20 fala em última viagem apesar de haver nível 3; esses pontos não foram corrigidos silenciosamente nesta validação.

Ao final, a #52 foi encerrada e seu campo Status no Projects foi conferido como **Concluído**. Foram registrados resultados parciais em 26 issues, incluindo as frentes principais e os novos registros de coletas/nebulosa/distribuição. As demais mantêm seus critérios humanos e são cobertas pela matriz deste relatório. Resultado remoto: **40 issues abertas e 18 encerradas**; nenhuma outra issue foi fechada por inferência a partir dos testes de desktop.

## Capturas inspecionadas

| Contexto | Evidência |
| --- | --- |
| Menu atual | [Imagem](../evidencias/validacao-2026-11-10/ui-menu.png) |
| Configurações/créditos | [Configurações](../evidencias/validacao-2026-11-10/ui-configuracoes.png), [créditos](../evidencias/validacao-2026-11-10/ui-creditos.png) |
| Seleção e metas de 30/60 | [Seleção](../evidencias/validacao-2026-11-10/campanha30-selecao.png), [nível 3](../evidencias/validacao-2026-11-10/campanha30-nivel3.png) |
| Nebulosa no voo e exploração | [Voo](../evidencias/validacao-2026-11-10/campanha30-nebulosa-voo.png), [mapa](../evidencias/validacao-2026-11-10/campanha30-nebulosa-mapa.png) |
| Plugin no EditorNode real | [Editor](../evidencias/validacao-2026-11-10/editor-orbt.png) |

Capturas são de desktop. Algumas cenas dos scripts de captura são montadas artificialmente; não demonstram sequência humana, áudio ou tempo de quadro. Foram selecionadas evidências de menu/seleção/máscara; resultados forçados pelo capturador não foram usados como comprovação de vitória.

## Versão Web e distribuição

- Página pública aberta: https://eclipseestudio.github.io/ORBT/ . Mostrou Jogar no navegador e fallback Ver downloads para Releases.
- Jogo abriu em https://eclipseestudio.github.io/ORBT/jogar/ . Observados menu, seleção, fase 1, tutorial, pausa, retomada e arraste por mouse. Combustível 5 → 4; voo coletou duas douradas e terminou em vitória.
- Console consultado sem entradas de erro. Não foi medido FPS/tempo de quadro e não foi validada escuta de áudio ou persistência Web em uma sessão nova.
- [Workflow Web 42440652800](https://github.com/EclipseEstudio/ORBT/actions/runs/42440652800): concluído com success, main `09a2db1c14f5ce8a16a456cc400abb91641285c7`. Registro remoto anterior, consultado nesta sessão; nenhum deploy foi disparado.
- Release mais recente consultada: `v0.5.0-alpha.20261107`, com APK de 59.984.967 bytes e digest informado pela API `6c6297c69c1911a59cefef23e8490b245d89efc68eeefd04cac9bb4bd3554f1b`. Esse digest não é medição local de um download: o APK remoto não foi baixado/instalado nesta sessão.
- Seleção automática de APK e instalação/atualização no aparelho continuam pendentes em #107.

## Bloqueios e tentativas de ambiente

A primeira importação usou AppData padrão sem permissão de escrita. Repetida com APPDATA/LOCALAPPDATA em `build/validacao-20261110/runtime`, concluiu. O primeiro PCK falhou por caminho temporário do ambiente restrito; repetido com TEMP/TMP no workspace, passou. Não se desativou safe save, antivírus ou proteção do ambiente.

ADB 1.0.41 / Platform Tools 37.0.1 falhou nos caminhos do SDK do usuário e do SDK do projeto, mesmo com ANDROID_USER_HOME separado:

```text
failed to create fdevent interrupt socketpair: Invalid argument
could not read ok from ADB Server
failed to start daemon
```

A falha acontece antes de enumerar dispositivos: não permite concluir que o celular esteja desconectado, sem autorização ou com driver defeituoso. Nenhum comando alcançou o aparelho; não houve instalação, limpeza, desinstalação ou alteração de saves. Não foram coletados modelo, versão Android, APK instalado, toques ou medições Android.

Durante a sessão, o usuário confirmou que `adb devices` lista o celular autorizado no PowerShell dele. A tentativa posterior do agente continuou retornando `cannot connect to daemon`; portanto a conexão funciona no terminal do usuário, mas não foi acessível no ambiente de execução do agente. Esse relato confirma disponibilidade no terminal informado, sem comprovar os cenários de jogabilidade.

Para destravar o diagnóstico, iniciar ADB no terminal normal do usuário e confirmar que `adb devices` lista um dispositivo autorizado; depois repetir a consulta por este ambiente. Se a restrição de comunicação persistir, a execução no aparelho precisará ocorrer no terminal do usuário com resultados registrados, sem presumir aprovação.

## Situação por issue

| Issue | Evidência desta execução | Restante | Encaminhamento |
| --- | --- | --- | --- |
| #1 | Física, partida, decolagem, órbitas, rotação e portais aprovados nas suítes desktop | APK atual, interação e desempenho no Android | Manter Em Revisão |
| #2 | Editor: 71; estrelas: 29; harness headless: 11 e renderizado: 12, sem falhas | Reprodução humana e inspeção por outro integrante | Manter Em Revisão |
| #3 | Suítes UI/visual aprovadas; capturas OpenGL e inspeção desktop | Legibilidade/oclusão/alcance no Android | Manter Em Revisão |
| #4 | Workflow Web aprovado; menu, campanha, tutorial, pausa, lançamento/vitória observados | Download/integridade APK, áudio/save Web e atualização no aparelho | Manter Em Revisão |
| #5 | 1.209 verificações em fases 1–20; 252 em campanha 30, incluindo rotas 21–30 | Integração, interface e atualização no APK atual | Manter Em Revisão |
| #6 | Controles/mira/decolagem aprovados; lançamento por mouse e vitória observados na Web | Uma mão, multitouch e suspensão física no Android | Manter Em Revisão |
| #8 | Física, partida, decolagem, órbitas, rotação e portais aprovados nas suítes desktop | APK atual, interação e desempenho no Android | Manter Em Revisão |
| #9 | Física, partida, decolagem, órbitas, rotação e portais aprovados nas suítes desktop | APK atual, interação e desempenho no Android | Manter Em Revisão |
| #10 | Física, partida, decolagem, órbitas, rotação e portais aprovados nas suítes desktop | APK atual, interação e desempenho no Android | Manter Em Revisão |
| #12 | Física, partida, decolagem, órbitas, rotação e portais aprovados nas suítes desktop | APK atual, interação e desempenho no Android | Manter Em Revisão |
| #14 | Física, partida, decolagem, órbitas, rotação e portais aprovados nas suítes desktop | APK atual, interação e desempenho no Android | Manter Em Revisão |
| #15 | Física, partida, decolagem, órbitas, rotação e portais aprovados nas suítes desktop | APK atual, interação e desempenho no Android | Manter Em Revisão |
| #16 | Controles/mira/decolagem aprovados; lançamento por mouse e vitória observados na Web | Uma mão, multitouch e suspensão física no Android | Manter Em Revisão |
| #17 | Controles/mira/decolagem aprovados; lançamento por mouse e vitória observados na Web | Uma mão, multitouch e suspensão física no Android | Manter Em Revisão |
| #18 | Controles/mira/decolagem aprovados; lançamento por mouse e vitória observados na Web | Uma mão, multitouch e suspensão física no Android | Manter Em Revisão |
| #20 | Controles/mira/decolagem aprovados; lançamento por mouse e vitória observados na Web | Uma mão, multitouch e suspensão física no Android | Manter Em Revisão |
| #22 | Editor: 71; estrelas: 29; harness headless: 11 e renderizado: 12, sem falhas | Recarga de scripts com documento aberto | Manter Em Revisão |
| #23 | Editor: 71; estrelas: 29; harness headless: 11 e renderizado: 12, sem falhas | Reprodução humana e inspeção por outro integrante | Manter Em Revisão |
| #25 | Editor: 71; estrelas: 29; harness headless: 11 e renderizado: 12, sem falhas | Reprodução humana e inspeção por outro integrante | Manter Em Revisão |
| #26 | Editor: 71; estrelas: 29; harness headless: 11 e renderizado: 12, sem falhas | Preview/retorno real após vitória e derrota | Manter Em Revisão |
| #27 | Suítes UI/visual aprovadas; capturas OpenGL e inspeção desktop | Procedência completa de todos os recursos e revisão Android | Manter Em Revisão |
| #28 | Suítes UI/visual aprovadas; capturas OpenGL e inspeção desktop | Legibilidade/oclusão/alcance no Android | Manter Em Revisão |
| #29 | Suítes UI/visual aprovadas; capturas OpenGL e inspeção desktop | Legibilidade/oclusão/alcance no Android | Manter Em Revisão |
| #30 | Suítes UI/visual aprovadas; capturas OpenGL e inspeção desktop | Legibilidade/oclusão/alcance no Android | Manter Em Revisão |
| #31 | Suítes UI/visual aprovadas; capturas OpenGL e inspeção desktop | Legibilidade/oclusão/alcance no Android | Manter Em Revisão |
| #33 | Carregamento dos 30 JSONs e pacote isolado aprovados | Abertura offline no APK atual | Manter Em Revisão |
| #37 | Física, partida, decolagem, órbitas, rotação e portais aprovados nas suítes desktop | APK atual, interação e desempenho no Android | Manter Em Revisão |
| #38 | Suítes UI/visual aprovadas; capturas OpenGL e inspeção desktop | Legibilidade/oclusão/alcance no Android | Manter Em Revisão |
| #51 | Suítes UI/visual aprovadas; capturas OpenGL e inspeção desktop | Legibilidade/oclusão/alcance no Android | Manter Em Revisão |
| #52 | 1.209 verificações em fases 1–20; 252 em campanha 30, incluindo rotas 21–30 | Sem pendência no escopo de conteúdo; balanceamento acompanha #53 | Concluir |
| #53 | 1.209 verificações em fases 1–20; 252 em campanha 30, incluindo rotas 21–30 | Outro jogador completar 30 fases e avaliar dificuldade/precisão | Manter Em Revisão |
| #54 | 14 verificações; tutorial inicial observado na Web; revisão dos 30 textos | Compreensão sem ajuda por jogador não autor | Manter Em Revisão |
| #55 | Áudio: 21; opções: 22, sem falhas | Escuta com alto-falante/fones e vibração física | Manter Em Revisão |
| #56 | Narrativa: 14, sem falhas; introdução oculta conhecida | Aprovação dos textos pela equipe e leitura no Android | Manter Em Revisão |
| #90 | Física, partida, decolagem, órbitas, rotação e portais aprovados nas suítes desktop | APK atual, interação e desempenho no Android | Manter Em Revisão |
| #92 | Física, partida, decolagem, órbitas, rotação e portais aprovados nas suítes desktop | APK atual, interação e desempenho no Android | Manter Em Revisão |
| #94 | Física, partida, decolagem, órbitas, rotação e portais aprovados nas suítes desktop | APK atual, interação e desempenho no Android | Manter Em Revisão |
| #104 | 1.209 verificações em fases 1–20; 252 em campanha 30, incluindo rotas 21–30 | Integração, interface e atualização no APK atual | Manter Em Revisão |
| #105 | 1.209 verificações em fases 1–20; 252 em campanha 30, incluindo rotas 21–30 | Integração, interface e atualização no APK atual | Manter Em Revisão |
| #106 | Renderização real: 0 falhas; máscara oculta exterior em voo/exploração | Legibilidade/desempenho e instrumentos no Android | Manter Em Revisão |
| #107 | Workflow Web aprovado; menu, campanha, tutorial, pausa, lançamento/vitória observados | Download/integridade APK, áudio/save Web e atualização no aparelho | Manter Em Revisão |

Aprovações da equipe, outro integrante/jogador, ergonomia, fones/alto-falante, vibração e instalação manual são critérios humanos. Não foram substituídos por leitura de código ou por testes automatizados.

## Reprodução

Use os comandos do [guia de testes](../../guias/testes.md), com Godot 4.7.2. Neste ambiente foram necessários APPDATA/LOCALAPPDATA e TEMP/TMP em pastas graváveis no workspace; modelos oficiais Android foram copiados para o runtime isolado. O harness restaura project.godot e o diff dessa configuração permaneceu vazio. Não houve alteração de regras/fases para fazer a suíte passar.

