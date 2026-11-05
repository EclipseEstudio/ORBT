# ORBT

Puzzle espacial em Godot 4.7.2, com campanha, pouso, impulsos, combustível, gravidade, guia de direção e ciclo de partida.

## Jogar

Abra `project.godot` na Godot e execute o projeto (F5). No menu, escolha **Jogar** para abrir a seleção de fases. Nessa tela, escolha uma fase; os avisos e o descarte de checkpoint permanecem disponíveis, sem ação de retomada persistida.

- Pressione a área livre do jogo, arraste e solte para lançar na direção oposta ao arraste.
- Volte ao círculo para cancelar. Para tentar de novo, solte e inicie outro toque/clique.
- Cada impulso custa uma unidade. Correções em voo somam velocidade.
- **Explorar mapa** muda o arraste para a câmera; **Voltar à nave** restaura a mira.
- Nas cinco fases adaptadas do protótipo Python, **Explorar mapa** também abre a visão geral dos corredores, planetas e sóis.
- **Pausar** suspende a tentativa; voltar ao aplicativo mantém a pausa até **Retomar**.
- **Configurações**, no menu ou na pausa, ajusta separadamente os volumes de música e efeitos. Os valores são guardados no aparelho.
- A música continua durante a pausa; efeitos de voo aguardam a retomada. Os volumes podem ser reduzidos a zero.
- **Reiniciar** restaura nave, combustível, tempo, câmera e contatos.
- Após derrota, **Último pouso** restaura o checkpoint da tentativa, preservando combustível e oxigênio. Sem combustível para decolar, use Repetir. Em voo, gastar a última carga permite seguir à deriva e ainda chegar à Terra; acabar o oxigênio encerra a tentativa.
- Na vitória, **Próxima fase** abre a sucessora disponível; **Repetir** começa nova tentativa. Na última fase, use Repetir ou Seleção de fases. A pausa permite voltar ao menu principal.
- **Seleção de fases** retorna à campanha, inclusive durante pausa ou após o desfecho. Conclusões e desbloqueios são salvos neste aparelho; repetir começa uma tentativa nova.

Na fase inicial, um arraste vertical para baixo de 80 unidades lógicas (160 pixels na janela padrão, sem escala adicional do sistema) produz um impulso suficiente para chegar à Terra. Use a área central, fora dos botões. A mira mostra uma linha reta de 60 pixels lógicos, independente da força e do zoom, indicando a direção do impulso. Ela não prevê gravidade ou colisões. A nave aponta para a mira e, durante o voo, para a direção da velocidade.

## Testes

Com a Godot no PATH:

```powershell
godot --headless --path . --editor --import --quit
./tests/run.ps1 -Godot godot
```

Também é possível passar o caminho do executável da Godot ao parâmetro `-Godot`. O executor rejeita erros da engine mesmo quando ela retorna código de saída zero.

Em outros sistemas, execute as suítes individualmente e confira também erros no log:

```text
godot --headless --path . --script tests/test_controles.gd
godot --headless --path . --script tests/test_partida.gd
```

Para capturas com renderizador real, execute `godot --path . --script tests/capturar_fase.gd`; os PNGs ficam em `.godot/`, ignorada pelo Git.

## Android

O preset **Android** inclui catálogo e fases JSON, usa orientação retrato e gera um APK de depuração para ARM de 32/64 bits. A importação de texturas ETC2/ASTC necessária ao renderizador Mobile está habilitada. Consulte a [preparação e validação Android](docs/tecnica/android.md).

Depois de configurar JDK, SDK Android e modelos de exportação no mesmo editor utilizado pelo comando:

```powershell
./scripts/exportar-android.ps1 -Godot godot
```

Se `godot` não for reconhecido, passe em `-Godot` o caminho completo do executável entre aspas. Veja o [exemplo sem PATH](docs/tecnica/android.md#gerar-e-instalar).

Saída: `build/android/ORBT-debug.apk`. APKs, pacotes e logs em `build/` ficam fora do Git.

Para verificar o conteúdo exportado sem precisar do SDK Android:

```powershell
./tests/run_exportacao.ps1 -Godot godot
```

Esse teste exporta um PCK com o preset Android e carrega a fase em uma pasta isolada, conferindo inclusões/exclusões e vitória. Ele verifica recursos e scripts empacotados no desktop; não substitui gerar o APK nem testar toque e desempenho no telefone.

## Editor de fases

Abra **ORBT Fases** na barra superior da Godot para criar, abrir, mover corpos, editar propriedades, desfazer/refazer, duplicar corpos, validar, salvar e testar JSON. O teste usa cópia independente e o carregador do jogo. Consulte o [manual completo do editor](docs/auxiliar/guia-editor-de-fases.md) para o fluxo de autoria, propriedades, validação, salvamento e testes. Os [detalhes técnicos e roteiro de reprodução](docs/tecnica/editor-de-fases.md) ficam na documentação de desenvolvimento.

## Documentação

- [Índice completo da documentação](docs/README.md)
- [Documentação técnica](docs/tecnica/README.md)
- [Regras de negócio: jogabilidade e campanha](docs/regras-de-negocio/README.md)
- [Documentação auxiliar: guias, arte e acompanhamento](docs/auxiliar/README.md)
- [Estado atual, Projects, issues e próximos passos](docs/auxiliar/estado-da-branch.md)
- [Histórico das implementações e evidências](docs/auxiliar/historico-implementacao.md)
- [Contrato JSON e modelo de simulação](docs/tecnica/fases-e-simulacao.md)
- [Exportação e aceite Android](docs/tecnica/android.md)
- [Editor de fases JSON](docs/tecnica/editor-de-fases.md)
- [Campanha e seleção de fases](docs/regras-de-negocio/campanha.md)
- [Identidade visual, fontes e inventário](docs/auxiliar/arte/README.md)

O catálogo `Recursos/Niveis.json` aponta para arquivos independentes em `Recursos/Fases/`. Jogo e plugin compartilham o carregador e a validação. Progresso, checkpoint e preferências são persistidos separadamente; progresso e checkpoint têm cópias recuperáveis.

Estado atualizado em 30/10/2026: os PRs #58–#65 integraram gravidade, checkpoints, preferências, menus e tutorial. O catálogo contém dez fases, com rotas verificadas em `tests/test_fases.gd`. A integração sonora, o aceite Android e o balanceamento com revisão cruzada permanecem em revisão. Acompanhe o [Projects ORBT](https://github.com/orgs/EclipseEstudio/projects/1) e a matriz de continuidade na documentação.
