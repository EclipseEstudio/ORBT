# ORBT

Puzzle espacial em Godot 4.7.2. A branch `implementa-nave-e-controles` contém uma fase de protótipo com pouso, impulsos, combustível, gravidade, prévia de trajetória e ciclo de partida.

## Jogar

Abra `project.godot` na Godot e execute o projeto (F5). No computador, clique em **Start**. O fluxo Android abre a fase diretamente quando executado nessa plataforma. A configuração de exportação está incluída; a geração do APK depende das ferramentas Android e o teste em aparelho permanece pendente.

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

O preset **Android** inclui catálogo e fases JSON, usa orientação retrato e gera um APK de depuração para ARM de 32/64 bits. Consulte a [preparação e validação Android](docs/android.md).

Depois de configurar JDK, SDK Android e modelos de exportação no mesmo editor utilizado pelo comando:

```powershell
./scripts/exportar-android.ps1 -Godot godot
```

Saída: `build/android/ORBT-debug.apk`. APKs, pacotes e logs em `build/` ficam fora do Git.

Para verificar o conteúdo exportado sem precisar do SDK Android:

```powershell
./tests/run_exportacao.ps1 -Godot godot
```

Esse teste exporta um PCK com o preset Android e carrega a fase em uma pasta isolada, conferindo inclusões/exclusões e vitória. Ele verifica recursos e scripts empacotados no desktop; não substitui gerar o APK nem testar toque e desempenho no telefone.

## Documentação

- [Estado da branch, issues e evidências](docs/estado-da-branch.md)
- [Contrato JSON e regras do protótipo](docs/fases-e-simulacao.md)
- [Exportação e aceite Android](docs/android.md)

O catálogo `Recursos/Niveis.json` aponta para arquivos independentes em `Recursos/Fases/`. O carregador valida os dados antes de criar a simulação e também aceita dados em memória para a futura integração com o editor. Campanha, persistência e plugin de edição continuam fora desta branch.
