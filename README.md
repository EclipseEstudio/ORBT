# ORBT

Puzzle espacial em Godot 4.7.2, com fase de protótipo, pouso, impulsos, combustível, gravidade, prévia de trajetória e ciclo de partida.

## Jogar

Abra `project.godot` na Godot e execute o projeto (F5). No computador, clique em **Campanha** e escolha a fase. O fluxo Android abre diretamente a primeira fase do catálogo. O APK histórico foi gerado e verificado; instalação e teste em aparelho permanecem pendentes.

- Pressione a área livre do jogo, arraste e solte para lançar na direção oposta ao arraste.
- Volte ao círculo para cancelar. Para tentar de novo, solte e inicie outro toque/clique.
- Cada impulso custa uma unidade. Correções em voo somam velocidade.
- **Explorar mapa** muda o arraste para a câmera; **Voltar à nave** restaura a mira.
- **Pausar** suspende a tentativa; voltar ao aplicativo mantém a pausa até **Retomar**.
- **Reiniciar** restaura nave, combustível, tempo, câmera e contatos.
- **Seleção de fases** retorna à campanha, inclusive durante pausa ou após o desfecho. Conclusões e desbloqueios são salvos neste aparelho; repetir começa uma tentativa nova.

Na fase inicial, um arraste vertical para baixo de 80 unidades lógicas (160 pixels na janela padrão, sem escala adicional do sistema) produz um impulso suficiente para chegar à Terra. Use a área central, fora dos botões. A prévia termina no primeiro contato ou após três segundos.

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

Abra **ORBT Fases** na barra superior da Godot para criar, abrir, mover corpos, editar propriedades, validar, salvar e testar JSON. O teste usa cópia independente e o carregador do jogo. Consulte o [manual completo do editor](docs/auxiliar/guia-editor-de-fases.md) para o fluxo de autoria, propriedades, validação, salvamento e testes. Os [detalhes técnicos e roteiro de reprodução](docs/tecnica/editor-de-fases.md) ficam na documentação de desenvolvimento.

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

O catálogo `Recursos/Niveis.json` aponta para arquivos independentes em `Recursos/Fases/`. Jogo e plugin compartilham o carregador e a validação. A seleção usa metadados e progresso persistente por ID, com backup recuperável. Checkpoints de pouso e preferências continuam pendentes.

Estado atualizado em 29/10/2026: o PR #47 integrou à `alpha` o código e a documentação dos PRs #42–#46, incluindo progresso persistente. Os [quatro critérios da #40](docs/auxiliar/validacao-issue-40.md) foram demonstrados no Windows; validação integrada com 383 verificações sem falhas. O catálogo real contém uma fase. Aceite Android, checkpoints/Continuar, preferências e expansão da campanha permanecem pendentes. Acompanhe o [Projects ORBT](https://github.com/orgs/EclipseEstudio/projects/1) e a matriz de continuidade na documentação.
