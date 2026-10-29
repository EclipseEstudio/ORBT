> SUBSTITUÍDO em 26/10/2026: plano histórico, anterior aos PRs #42–#46. Não executar sua sequência de branches/integrações. Retomar por [estado atual](estado-da-branch.md) e [roteiro Android](../tecnica/android.md). Conteúdo original preservado abaixo.

# Plano temporário — issue #4

Atualizado em 22/10/2026. Documento de passagem para uma nova sessão; a implementação da #4 não foi iniciada nesta etapa. Remover ou incorporar à documentação permanente após o trabalho.

## Objetivo

[Issue #4 — Integrar e validar a primeira fase funcional no Android](https://github.com/EclipseEstudio/ORBT/issues/4): entregar uma fase JSON que abre diretamente no Android e permite observar, lançar, pousar, corrigir, falhar, chegar à Terra e reiniciar, com câmera, HUD e suspensão funcionando.

## Contexto para retomar

- O usuário informou que as entregas #6 e #1 foram aprovadas. Aprovação e merge devem ser conferidos no GitHub antes de começar; não houve confirmação técnica de merge nesta sessão.
- Destino confirmado pelo usuário: `main` (não existe `master` na consulta realizada).
- #6: branch remota `implementa-nave-e-controles`, último commit conhecido `31cd300`.
- #1: branch remota `feat/issue-1-corpos-celestes`, commit `8c4c5c0`, derivada da #6. Integrar #6 antes de #1 caso ainda estejam pendentes.
- A #1 ajustou saída tangencial da origem, detecção de pequena penetração e ausência de atração de asteroides/Terra. Acrescentou três verificações de regressão.
- Última execução: Godot 4.7.2 no Windows, 68 verificações de controles e 142 de partida, todas passando. Isso não é evidência de execução Android.
- Godot disponível em `C:\Users\macb\Desktop\Godot\Godot_v4.7.2-stable_win64_console.exe`.
- Nunca usar `codex/` nas branches. Usar `feat/`, `fix/`, `chore/` conforme o trabalho. Sugestão para esta entrega: `feat/issue-4-primeira-fase-android`.
- Preservar os arquivos preexistentes não rastreados em `Recursos/ModelosVisuais/` e `docs/orbt - game design document.md`; não incluí-los automaticamente em commits.

## O que já existe

A branch de nave já contém boa parte da integração: contrato JSON v1 e carregador, início no apoio, Terra, limites, controlador de partida, combustível, deriva, temporizador, vitória/derrota, pausa/reinício, câmera de abertura/acompanhamento/exploração e HUD. Há preset e script de exportação Android. Auditar os requisitos antes de reimplementar funcionalidades.

Referências locais:

- `docs/tecnica/fases-e-simulacao.md`: contrato, unidades e regras propostas.
- `docs/auxiliar/estado-da-branch.md`: implementação e evidências históricas.
- `docs/tecnica/android.md`: preparação, APK histórico e roteiro em aparelho.
- `Recursos/Fases/teste_001.json`: fase de referência.
- `src/Nivel/carregador_fase.gd`, `src/Nivel/nivel.gd`, `src/Nivel/camera_nivel.gd` e `src/Nivel/interface_partida.gd`.
- `src/ControladorJogo/partida.gd` e `src/Nave/simulacao_voo.gd`.

O APK documentado em 15/10 é anterior ao commit da #1. Gerar um novo pacote a partir da versão integrada; não atribuir ao pacote antigo as correções posteriores.

## Sequência de execução

1. Conferir instruções locais, estado do Git, PRs e merges. Atualizar a referência remota de `main` e criar a branch de trabalho a partir dela, preservando alterações locais.
2. Ler a descrição atual da #4 e das sub-issues #32–#37. Cruzar cada critério com código, testes e evidência; listar apenas as lacunas reais.
3. Conferir #32/#33: contrato JSON, validações, diagnóstico de dados inválidos, reconstrução e carregamento da fase sem modificar os dados autorais.
4. Conferir #34/#35: posicionamento inicial e Terra, apoio correto, limites independentes da câmera e da resolução.
5. Conferir #36/#37: chegada, cobrança única, reinício do tempo, último impulso/deriva, derrota com causa, desfecho único e reinício completo.
6. Conferir integração de câmera/HUD: apresentação da Terra, retorno à nave, acompanhamento, explorar/recentralizar sem lançar, combustível/tempo/destino e área segura.
7. Corrigir as lacunas encontradas e adicionar testes somente onde houver comportamento relevante sem cobertura. Executar as suítes existentes e a verificação do pacote.
8. Gerar APK atualizado, instalar em aparelho de referência disponível e executar o roteiro abaixo. Se não houver aparelho acessível, registrar o bloqueio e manter o aceite Android pendente.
9. Registrar evidências e decisões na documentação permanente, atualizar Projects e abrir PR para `main` com resultados e pendências explícitos.

## Validação

Comandos na raiz, usando a mesma Godot configurada para exportação:

```powershell
./tests/run.ps1 -Godot 'C:\Users\macb\Desktop\Godot\Godot_v4.7.2-stable_win64_console.exe'
./tests/run_exportacao.ps1 -Godot 'C:\Users\macb\Desktop\Godot\Godot_v4.7.2-stable_win64_console.exe'
./scripts/exportar-android.ps1 -Godot 'C:\Users\macb\Desktop\Godot\Godot_v4.7.2-stable_win64_console.exe'
```

Em ambiente restrito, a engine pode precisar de acesso às suas pastas de dados fora do repositório. Não confundir falhas de permissão com falhas de jogo.

| Cenário em aparelho | Resultado esperado |
| --- | --- |
| Abrir aplicativo | Fase JSON direta; apresenta Terra, volta à nave e habilita controle |
| Rota de referência | Arraste para baixo de 80 unidades lógicas na área livre; impulso para cima chega à Terra |
| Cancelar, pausar ou perder foco durante gesto | Sem cobrança ou disparo pendente; retomada explícita |
| Multitouch e botões | Segundo dedo e interface não geram impulso indevido |
| Pousar e sair da origem | Sem atravessamento; pouso não recarrega combustível |
| Corrigir em voo | Velocidade somada, uma cobrança e tempo reiniciado |
| Último combustível | Deriva continua sob gravidade; chegada ainda pode vencer |
| Sol, asteroide, limites e timeout | Uma derrota e causa visível |
| Explorar e recentralizar | Câmera funciona sem interferir na mira |
| Reiniciar | Restaura nave, apoio, saldo, tempo, câmera, contatos e gestos |
| Suspender e retomar | Física/tempo pausados; gesto cancelado; nenhum lançamento residual |
| Área segura e prévia | HUD legível, controles acessíveis, medir desempenho e conferir prévia contra voo |

Registrar commit, versão Godot, modelo do aparelho, versão Android, versão/hash do APK, JSON/parâmetros, passos, esperado, observado e captura/gravação. Pedir a outro integrante para reproduzir a rota. Não marcar aceite Android com base apenas em testes desktop ou exportação.

## Decisões a conferir com a equipe

As regras estão documentadas como propostas: direção livre oposta ao arraste, modelo gravitacional/tolerâncias (#13), alcance da prévia, tempo/deriva, lançamento contra a origem e contato seguro sem combustível (#9/#37). Conferir o que foi efetivamente aprovado; não presumir que aprovação de código resolveu todas as decisões de jogabilidade.

## Projects — pedido explícito do usuário

O usuário pediu para mover as tarefas no Projects. Isso continua pendente: o conector não expõe operações de Projects e o navegador estava sem login. A tentativa anterior de criar PR pelo conector retornou 403. Não houve atualização do quadro.

- Identificar o projeto correto e os nomes reais de seus status ao recuperar acesso.
- Atualizar #6 e #1 conforme aprovação, merge e critérios pendentes; não declarar conclusão Android sem evidência.
- Mover #4 para o status equivalente a Em andamento quando o trabalho começar.
- Atualizar #32–#37 individualmente conforme auditoria e validação, sem encerramento em lote por inferência.
- Ao terminar, conferir as mudanças no quadro e informar o que foi movido e o que permaneceu pendente.

## Limite de escopo e conclusão

Não iniciar editor, campanha, persistência ou acabamento visual nesta entrega. A #4 estará pronta quando o ciclo completo estiver integrado, repetível no aparelho e documentado, com decisões de M1 resolvidas e tarefas atualizadas. Este documento serve como contexto para a próxima sessão; não é evidência de aceite.
