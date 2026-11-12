# Campanha e salvamento

Fonte: `Recursos/Niveis.json`, `src/Campanha/`, `src/ControladorJogo/controlador_jogo.gd` e `src/Configuracoes/preferencias.gd`. Conferido em 10/11/2026.

## Progressão

São 30 fases em três níveis. O catálogo ordena por `order` e depois ID. Abrir uma fase exige concluir todas as anteriores; liberações indevidas em saves antigos não contornam essa regra.

| Nível | Fases | Meta de entrada |
| --- | --- | --- |
| 1 | 1–10 | Nenhuma |
| 2 | 11–20 | Todas as 30 douradas das fases 1–10 |
| 3 | 21–30 | Todas as douradas de cada bloco anterior: 60 no total |

O código verifica cada bloco anterior separadamente. Azuis não desbloqueiam níveis. Estrelas não são gastas. Nomes e recursos: [catálogo](../projeto/catalogo-fases.md).

## Estrelas

Cada fase tem três douradas e uma azul secreta. Total: **90 douradas e 30 azuis**.

Chegar à Terra confirma a coleta. O recorde de cada cor por fase é o máximo obtido numa conclusão; tentativas diferentes não somam estrelas da mesma cor. Derrota não confirma coleta e resultado pior não reduz recorde. Douradas e azuis têm recordes independentes.

A seleção soma os recordes do catálogo atual e mostra douradas nos cartões. Azuis não aparecem nos cartões ou no contador da fase. O resultado mostra três douradas acesas/apagadas e azul apenas quando coletada na tentativa.

Pausa preserva coletas. Reinício restaura estrelas/tanques. Último pouso recupera os IDs do checkpoint; coletas posteriores reaparecem. O salto entre portais não coleta no espaço entre entrada e saída.

## Progresso e checkpoint

`user://progresso.json`, esquema 4, guarda conclusões, liberações, recordes e fases vencidas com um lançamento. Esquemas 1–3 são migrados após validação, preservando estrelas e sem inventar lançamentos antigos. IDs estáveis preservam recordes; fases fora do catálogo podem manter dados salvos, mas não entram nos totais exibidos.

## Conquistas

O ícone de medalha no menu abre a lista vertical de conquistas. Créditos são acessados pelo título ORBT. Cada card contém imagem, título, descrição, progresso e cadeado enquanto bloqueado; uma confirmação substitui o cadeado após o desbloqueio.

| Conquista | Requisito |
| --- | --- |
| Nível 1/2/3 dourado | As 30 amarelas do respectivo bloco de dez fases |
| Explorador azul 1/2/3 | 10, 20 ou 30 estrelas azuis confirmadas |
| Coleção celeste | Todas as 30 azuis da campanha |
| Impulso certeiro 1/2 | Chegar à Terra com um único lançamento em 5 ou 10 fases distintas |

As nove conquistas são derivadas do progresso confirmado. Impulsos efetivamente aplicados, inclusive correções em voo, contam como lançamentos; cancelamentos, mira bloqueada e pedidos descartados não contam. Portais não adicionam lançamentos. Repetir a mesma fase não aumenta a quantidade de fases distintas. Um replay pior preserva o resultado anterior.

Último pouso restaura a contagem do trecho salvo; checkpoint antigo sem contagem não comprova a conquista até reiniciar a fase. Resetar Progresso também limpa as conquistas. Não há bônus de combustível, moedas ou alteração dos portões por desbloquear uma conquista.

`user://checkpoint.json` guarda início/último pouso, não um estado arbitrário em voo: posição, apoio, orientação, recursos, relógio e coletas. A validação compara fase e `content_version`. Mudanças incompatíveis devem incrementar essa versão. Vitória limpa o checkpoint compatível.

Ambos usam checksum, arquivo temporário e `.bak`. Falhas exibem aviso/retentativa; progresso pode valer só na sessão até salvar. Versões desconhecidas são preservadas e bloqueadas contra sobrescrita automática.

A API do controlador permite reabrir checkpoint pausado, mas **menu e seleção atuais não oferecem botão Continuar persistido**. Último pouso continua disponível na derrota da tentativa ativa.

## Preferências e reset

`user://preferencias.json`, esquema 2, guarda música, efeitos, vibração e dicas; lê também esquema 1. Padrões: volumes 100%, vibração e dicas ativadas. Música continua na pausa; efeitos de simulação aguardam retomada.

**Resetar Progresso** limpa checkpoint e progresso/recordes, inclusive backup de progresso, mantendo preferências independentes. Detalhes: [persistência](../tecnica/campanha.md). Instalação compatível: [atualização Android](../tecnica/atualizacao-android.md).
