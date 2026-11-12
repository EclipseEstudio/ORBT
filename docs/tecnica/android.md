# Gerar e validar Android

Fonte: `project.godot`, `export_presets.cfg`, `.github/workflows/android-pr.yml` e scripts Android. Conferido em 10/11/2026.

## Configuração versionada

| Item | Valor |
| --- | --- |
| Preset | Android; APK debug, modelos prontos, Gradle personalizado desativado |
| Pacote | `com.eclipseestudio.orbt` |
| Versão/código | 0.5.1 / 10 |
| Arquiteturas | ARM 32 e 64 bits |
| Tela/renderização | Retrato, Mobile, ETC2/ASTC habilitado |
| Permissão | Vibração |
| Dados | Backup automático Android desativado no preset |
| Recursos explícitos | Catálogo, JSONs de fase e licenças de fonte/Godot |
| Exclusões | Editor, testes, docs, scripts, builds e referências visuais especificadas no preset |

## Preparar e exportar

Use a mesma Godot 4.7.2 configurada com os modelos correspondentes, JDK 17 e Android SDK. O CI usa Build-Tools 36.1.0. Informe Java SDK Path e Android SDK Path nas configurações do editor usado pelo comando. Um editor portátil pode usar outra pasta de configurações/modelos.

Na raiz:

```powershell
./scripts/exportar-android.ps1 -Godot godot -Ferramentas 'C:/Android/Sdk/build-tools/36.1.0'
```

Se não estiver no PATH, passe o caminho completo do executável `_console.exe`. O script também procura ferramentas nas variáveis `ANDROID_HOME`, `ANDROID_SDK_ROOT` e no SDK local previsto pelo próprio script. Saída: `build/android/ORBT-debug.apk`; log em `build/android/export-apk.log`.

O script valida a configuração, exporta, rejeita erros da engine e verifica identidade/assinatura. `-SomentePacote` produz pacote de recursos para inspeção, sem ser um aplicativo Android. Credenciais não devem ser gravadas no preset; preserve a chave de distribuição existente. Consulte [assinatura e atualização](atualizacao-android.md).

Para instalar com verificações:

```powershell
./scripts/instalar-android.ps1 -Adb 'C:/Android/Sdk/platform-tools/adb.exe' -Ferramentas 'C:/Android/Sdk/build-tools/36.1.0' -Apk 'build/android/ORBT-debug.apk'
```

Com vários aparelhos, acrescente `-Serial`. O aparelho deve estar autorizado. O fluxo instala sobre o aplicativo existente quando compatível; não desinstala automaticamente.

## CI de pull request

O workflow **Android — revisão e publicação** valida PRs para `alpha`. Baixa Godot/modelos fixados com checksum, prepara Java/SDK/assinatura, importa, roda `tests/run.ps1`, verifica PCK, gera APK e confere identidade e alinhamento.

O artefato `ORBT-android-debug-pr-N` contém APK, `revisao.txt` e `atualizacao.json`, com retenção de 14 dias. O relatório identifica cabeça, base, merge testado e hash. PR do mesmo repositório usa assinatura permanente; fork usa pacote de prévia e chave temporária. O PR não publica uma Release e não exige aumento de versão/código em relação ao APK publicado. Assim, várias entregas podem ser integradas à `alpha` usando a mesma versão em desenvolvimento.

Publicação é disparada somente pelo envio explícito de uma tag `v*`. Esse fluxo exige revisão integrada à `alpha`, tag compatível com a versão do projeto, notas próprias e código Android superior ao APK publicado. Ele repete a validação completa e publica o APK dessa execução. A comparação com a última versão é repetida imediatamente antes da publicação. Processo e exemplos: [publicação](publicacao-web.md#publicar-uma-versão).

## Roteiro no aparelho

Registre revisão, versão/hash do APK, aparelho/Android e resultado observado por cenário. Use conteúdo da versão atual; testes antigos não validam regras novas.

| Cenário | Esperado |
| --- | --- |
| Abrir offline | Menu, catálogo e fases acessíveis sem rede |
| Gesto e cancelamento | Direção oposta, custo único; círculo cancela; segundo dedo/botões não disparam |
| Origem e decolagem | BLOQUEADO para dentro; saída tangencial viável; proteção gravitacional sem renovar em correção |
| Oxigênio | Inicia ao lançar, pausa no pouso, não recarrega em correção; consumo dobra fora de bounds |
| Última carga | Deriva pode vencer; pouso sem saldo derrota; tanque pode recuperar controle |
| Mecânicas | Órbitas, faixas, portais e nebulosa coerentes nas fases avançadas |
| Pausa/foco | Suspensão cancela gesto e congela; retorno permanece pausado |
| Exploração | Pan/zoom sem lançamento acidental; máscara preservada; retorno à nave |
| Resultados | Motivo correto, último pouso/repetir, recordes e portões 30/60 |
| Áudio/vibração | Volumes, silêncio, pausa e opções persistentes |
| UI | Área segura, leitura, rolagem e alcance com polegar |
| Atualização | APK anterior atualizado preservando dados, por USB e instalador do telefone |
| Desempenho | Tempo de quadro/resposta medidos em fases avançadas; ausência de travamento |

`scripts/evidencias-android.ps1` coleta metadados do ambiente, sem substituir a execução do roteiro. Evidências de 2026-10/11 permanecem no [histórico](../historico/README.md).
