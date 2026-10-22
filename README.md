# ORBT

Puzzle espacial em Godot 4.7.2, com fase de protótipo, pouso, impulsos, combustível, gravidade, prévia de trajetória e ciclo de partida.

## Jogar

Abra `project.godot` na Godot e execute o projeto (F5). No computador, clique em **Start**. O fluxo Android abre a fase diretamente quando executado nessa plataforma. O APK de depuração foi gerado e verificado; instalação e teste em aparelho permanecem pendentes.

- Pressione a área livre do jogo, arraste e solte para lançar na direção oposta ao arraste.
- Volte ao círculo para cancelar. Para tentar de novo, solte e inicie outro toque/clique.
- Cada impulso custa uma unidade. Correções em voo somam velocidade.
- **Explorar mapa** muda o arraste para a câmera; **Voltar à nave** restaura a mira.
- **Pausar** suspende a tentativa; voltar ao aplicativo mantém a pausa até **Retomar**.
- **Reiniciar** restaura nave, combustível, tempo, câmera e contatos.

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

O preset **Android** inclui catálogo e fases JSON, usa orientação retrato e gera um APK de depuração para ARM de 32/64 bits. A importação de texturas ETC2/ASTC necessária ao renderizador Mobile está habilitada. Consulte a [preparação e validação Android](docs/android.md).

Depois de configurar JDK, SDK Android e modelos de exportação no mesmo editor utilizado pelo comando:

```powershell
./scripts/exportar-android.ps1 -Godot godot
```

Se `godot` não for reconhecido, passe em `-Godot` o caminho completo do executável entre aspas. Veja o [exemplo sem PATH](docs/android.md#gerar-e-instalar).

Saída: `build/android/ORBT-debug.apk`. APKs, pacotes e logs em `build/` ficam fora do Git.

Para verificar o conteúdo exportado sem precisar do SDK Android:

```powershell
./tests/run_exportacao.ps1 -Godot godot
```

Esse teste exporta um PCK com o preset Android e carrega a fase em uma pasta isolada, conferindo inclusões/exclusões e vitória. Ele verifica recursos e scripts empacotados no desktop; não substitui gerar o APK nem testar toque e desempenho no telefone.

## Editor de fases

Abra **ORBT Fases** na barra superior da Godot para criar, abrir, mover corpos, editar propriedades, validar, salvar e testar JSON. O teste usa cópia independente e o carregador do jogo. Consulte o [guia do editor](docs/editor-de-fases.md), incluindo ativação/desativação, alterações pendentes e roteiro de reprodução.

## Documentação

- [Estado da branch, issues e evidências](docs/estado-da-branch.md)
- [Contrato JSON e regras do protótipo](docs/fases-e-simulacao.md)
- [Exportação e aceite Android](docs/android.md)
- [Editor de fases JSON](docs/editor-de-fases.md)

O catálogo `Recursos/Niveis.json` aponta para arquivos independentes em `Recursos/Fases/`. Jogo e plugin compartilham o carregador e a validação. Campanha e persistência continuam fora desta entrega.
