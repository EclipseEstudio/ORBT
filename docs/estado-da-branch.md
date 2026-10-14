# Estado da branch e continuidade das issues

Atualizado em 14/10/2026. Repositório: [EclipseEstudio/ORBT](https://github.com/EclipseEstudio/ORBT).

## Situação do Git

Branch `implementa-nave-e-controles`, baseada em `a93376c7b58d36b4f998cdee5ef99775e4e5ac3b`. A análise inicial confirmou esse commit idêntico ao remoto. Esta entrega reúne implementação, testes e preparação de exportação em commit local. Publicação no remoto e fechamento de issues não fazem parte da evidência de validação abaixo.

Na consulta realizada, as 41 issues estavam abertas. Foram preservados o GDD local e os arquivos preexistentes não rastreados em `Recursos/ModelosVisuais/` e `tmp/`.

## Escopo entregue

O controle da nave deixou de ser apenas um protótipo de impulso: agora pode ser testado numa fase com gravidade, pouso, combustível, prévia, tempo, câmera e desfechos. A implementação cobre o núcleo de [#6](https://github.com/EclipseEstudio/ORBT/issues/6) e as integrações necessárias para exercitá-lo.

| Issue | Implementação presente | Aceite ainda pendente |
| --- | --- | --- |
| [#15](https://github.com/EclipseEstudio/ORBT/issues/15) | Pousada/voo/deriva, vínculo por ID e posição relativa, decolagem, contato contra origem e restauração | Validação das regras propostas e aparelho |
| [#16](https://github.com/EclipseEstudio/ORBT/issues/16) | Um dedo, zona morta, cancelamento, prioridade da GUI, foco/suspensão/pausa e bloqueio em exploração/desfecho | Ergonomia e eventos reais no Android |
| [#17](https://github.com/EclipseEstudio/ORBT/issues/17) | Direção livre oposta ao arraste, curva contínua saturada e coordenadas lógicas independentes da câmera | Calibração e aceite da direção |
| [#18](https://github.com/EclipseEstudio/ORBT/issues/18) | Círculo, estimativa com velocidade atual, gravidade e interrupção em contato; limite de custo e limpeza | Legibilidade, custo e tolerância no Android |
| [#19](https://github.com/EclipseEstudio/ORBT/issues/19) | Combustível do JSON, cobrança única por ID, confirmação para tempo, correção aditiva e último impulso em deriva | Validação integrada no aparelho |
| [#20](https://github.com/EclipseEstudio/ORBT/issues/20) | Mouse emula toque pelo mesmo ciclo, incluindo cancelamento, interface, câmera e combustível | Comparação com toque físico |

Dependências implementadas para não deixar essas funcionalidades isoladas:

- **#7–#14:** corpos por dados, gravidade suavizada, contatos por segmento, zonas separadas e alertas de proximidade por ID. O modelo e as regras são candidatos documentados para aceite.
- **#32/#33:** contrato de fase v1, arquivo por fase, validação de tipos/referências/geometria, diagnóstico de erro e carregamento por arquivo ou memória. Os dados autorais não são alterados pela simulação.
- **#34–#37:** início no apoio, Terra, limites independentes da tela, vitória/derrota, tempo, pausa e reinício. Foram corrigidas a instanciação e a limpeza nas trocas de mundo/interface.
- **Integração #4:** HUD, câmera de abertura/acompanhamento/exploração, rota reproduzível e início direto da fase quando a plataforma é Android. Preset e script de exportação, JSON incluído, tela em retrato e margens de área segura. Pacote de recursos validado; geração de APK e instalação em aparelho ainda pendentes.

As cenas da nave e dos corpos usam agora simulação explícita compartilhada com a prévia, em vez de combinar `RigidBody2D` com outro cálculo para a previsão. Sprites e animações foram preservados. O cadastro global antigo de corpos foi substituído pelos dados completos de cada fase.

## Validação realizada

Godot `4.7.2.stable.official.ed1daf0bf`, Windows:

- **68 verificações de controles/interface**, sem falhas.
- **139 verificações de dados, física e partida**, sem falhas.
- **10 verificações do pacote exportado**, sem falhas: fase e catálogo incluídos, arquivos de desenvolvimento excluídos, cena principal e rota funcionando em pasta isolada.
- Rota de um impulso até a Terra com saldo inicial 5 e com o último combustível.
- Comparação de prévia e voo, com erro inferior a 0,001 unidade nos pontos testados.
- Rejeição de eventos duplicados/atrasados, inclusive entre reinícios; pausa sem cobrança pendente.
- Contato rápido, lançamento contra origem, limites, timeout, proximidades simultâneas e desfecho único.
- Troca real de fase libera o mundo anterior e restaura o saldo.
- Exploração limpa contato mesmo com soltura consumida pela GUI; redimensionamento, cancelamento do sistema e perda de foco também limpam o arraste.
- Conversão da área segura para a escala lógica verificada com recortes, barras e janela deslocada.
- Capturas de mira, pausa e vitória inspecionadas; execução gráfica Mobile/D3D12 e Compatibility/OpenGL no desktop.

Para reproduzir, consulte o [README](../README.md). O executor `tests/run.ps1` trata erros da engine como falha mesmo quando o processo retorna zero.

## Regras explícitas e trabalho seguinte

O [contrato de fases e simulação](fases-e-simulacao.md) registra parâmetros, unidades, regras propostas e limites de aceite. As escolhas não foram apresentadas como decisões já aprovadas no GDD.

A implementação desta branch está preparada para revisão. O pacote exportado usa os mesmos recursos de jogo e completou a rota de teste. A tentativa de APK identificou dependências ausentes no editor usado: JDK configurado, SDK Android e modelos de exportação da versão 4.7.2. Instruções e roteiro estão em [android.md](android.md).

Para encerrar as issues que exigem aceite Android, ainda é necessário gerar/instalar o APK e registrar aparelho/versão, ergonomia, gestos reais, suspensão/retomada, legibilidade e desempenho da prévia. Também é necessário validar com a equipe as regras de direção livre, gravidade, contato contra origem, contato seguro sem combustível e contagem durante pouso. Nenhuma dessas evidências foi substituída por teste desktop.

Depois do aceite de M1, seguem editor (#2/#21–#26), seleção/campanha (#5/#38–#41), persistência e acabamento visual (#3/#27–#31). Essas entregas não foram acrescentadas à branch de nave e controles.
