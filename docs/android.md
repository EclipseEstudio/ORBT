# Exportação e aceite Android

## Entrega desta branch

O preset `Android` em `export_presets.cfg` está pronto para um APK de depuração:

- Identificador `com.eclipseestudio.orbt`, nome ORBT, versão 0.1.0 / código 1.
- ARM de 32 e 64 bits; modelos prontos da Godot, sem build Gradle personalizado.
- Catálogo `Recursos/Niveis.json` e arquivos `Recursos/Fases/*.json` incluídos explicitamente.
- Testes, documentação, scripts auxiliares, referências visuais e temporários excluídos.
- Tela em retrato; HUD ajustado à área segura informada pelo Android, em coordenadas lógicas.
- A fase abre diretamente no Android. Suspender/perder foco pausa a partida e cancela a entrada; é preciso tocar em Retomar.

O renderizador continua Mobile. A compatibilidade gráfica, os recortes de tela e o desempenho precisam ser verificados no aparelho escolhido. Nenhuma regra proposta do protótipo ganha aceite por causa da exportação.

## Preparar o computador uma vez

Use Godot 4.7.2, versão que validou esta implementação, e modelos correspondentes ao editor. Em **Editor > Manage Export Templates**, instale os modelos Android. [Modelos de exportação](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html#export-templates).

Instale OpenJDK 17 e Android SDK, incluindo os componentes exigidos pela versão do Godot. O Android Studio fornece o SDK Manager. Em **Editor > Editor Settings > Export > Android**, informe **Java SDK Path** e **Android SDK Path**. O segundo deve apontar para a pasta que contém `platform-tools` e `build-tools`. Siga as versões de componentes do [guia oficial Android](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html).

As configurações de SDK pertencem ao editor utilizado, não ao projeto. Um editor portátil em modo autocontido pode ter configurações e modelos diferentes do editor instalado. Execute os scripts com o caminho do mesmo editor configurado.

Não coloque senhas no preset. Credenciais ficam nas configurações locais da Godot; arquivos de assinatura `.keystore` e `.jks` estão ignorados pelo Git. A entrega usa assinatura de depuração para teste.

## Gerar e instalar

Na raiz do repositório, com a Godot configurada no PATH:

```powershell
./scripts/exportar-android.ps1 -Godot godot
```

Se aparecer **'godot' não é reconhecido**, o executável não está no PATH. Use o caminho do arquivo `.exe` que abre seu editor, entre aspas. Exemplo (substitua pela pasta onde você extraiu a Godot):

```powershell
.\scripts\exportar-android.ps1 -Godot "C:\Ferramentas\Godot\Godot_v4.7.2-stable_win64_console.exe"
```

Não é necessário alterar o PATH quando se usa o caminho completo. Prefira o executável terminado em `_console.exe` para acompanhar o diagnóstico no terminal.

Saída: `build/android/ORBT-debug.apk`; diagnóstico: `build/android/export-apk.log`. O script verifica o executável antes de alterar a saída e falha se a engine reportar erro, retornar código diferente de zero ou não produzir arquivo válido. Com o executável localizado, um APK antigo é removido antes da tentativa para evitar entrega desatualizada.

Pelo editor, abra **Project > Export**, selecione **Android**, clique em **Export Project** e mantenha **Export With Debug** marcado. Salve em `build/android/ORBT-debug.apk`.

Transfira o APK para o telefone e abra pelo gerenciador de arquivos; autorize a instalação por esse aplicativo quando solicitada. Abra ORBT e aguarde a câmera apresentar a Terra e voltar à nave. A rota de referência é um arraste vertical para baixo de 80 unidades lógicas na área central livre: um impulso completo para cima chega à Terra.

## Evidências locais em 14/10/2026

- Godot 4.7.2.stable.official.ed1daf0bf / Windows.
- Controles e interface: 68 verificações; dados, física e partida: 139; nenhuma falha.
- `tests/run_exportacao.ps1`: 10 verificações sem falhas sobre o PCK gerado pelo preset Android, executado de pasta isolada. Catálogo/fase presentes, arquivos de desenvolvimento excluídos, cena principal resolvida e rota concluída com combustível 4.
- A exportação de APK foi tentada. O editor usado informou modelos Android ausentes, Java SDK não configurado e ausência de SDK válido com `adb`/`apksigner`. Nenhum APK foi produzido.
- O primeiro teste de empacotamento encontrou bloqueio do armazenamento interno `user://` pelo ambiente restrito. Reexecutado com acesso normal aos dados da Godot, passou sem erros de script/exportação. A mensagem sobre `build-tools` ausente não impede exportar apenas PCK.
- PCK não é um aplicativo Android. Não há evidência de instalação, desempenho ou ergonomia em aparelho nesta entrega.

## Roteiro para aceite em aparelho — issues #4 e #15–#20

Registre modelo do aparelho, versão do Android, versão/hash da branch, versão da Godot, JSON usado e gravação ou captura. Preencha resultado observado, sem marcar itens apenas pela implementação existir.

| Cenário | Resultado esperado | Observado no aparelho |
| --- | --- | --- |
| Abrir ORBT | Fase direta; Terra apresentada; retorno à nave; combustível 5 | Pendente |
| Lançar pela rota descrita | Uma cobrança; tempo começa; chegada à Terra | Pendente |
| Toque parado / voltar ao círculo | Nenhum impulso/cobrança; próximo gesto exige novo toque | Pendente |
| Dois dedos / botões | Segundo dedo não assume mira; botões não lançam | Pendente |
| Explorar / recentralizar | Arraste só move câmera; não há lançamento ao voltar | Pendente |
| Soltar exploração sobre interface | Próximo arraste funciona, sem contato preso | Pendente |
| Suspender com dedo na tela | Gesto cancelado; tempo e física pausados; Retomar não lança | Pendente |
| Correção em voo | Soma velocidade, cobra uma unidade e reinicia tempo | Pendente |
| Último combustível | Continua à deriva; chegada ainda pode vencer | Pendente |
| Pouso / lançar contra origem | Não atravessa apoio; pouso não recarrega; saldo zero encerra | Pendente |
| Perigo / limites / tempo | Uma derrota, causa visível, nave interrompida | Pendente |
| Reiniciar após resultado | Restaura posição, apoio, combustível, tempo e câmera | Pendente |
| Recortes e navegação do sistema | HUD legível e botões acessíveis na área segura | Pendente |
| Mira repetida durante voo | Prévia limpa ao cancelar; medir FPS/custo e comparar com voo | Pendente |

As escolhas de direção livre, gravidade, tempo, pouso sem saldo e contato contra origem estão registradas em [fases-e-simulacao.md](fases-e-simulacao.md) como propostas. O aceite dessas regras e a execução deste roteiro são condições para encerrar as issues que exigem demonstração no Android.
