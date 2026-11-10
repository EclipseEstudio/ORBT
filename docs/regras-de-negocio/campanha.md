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

Cada fase tem três douradas. As fases 2–30 têm uma azul secreta; a primeira não contém azul. Total: **90 douradas e 29 azuis**.

Chegar à Terra confirma a coleta. O recorde de cada cor por fase é o máximo obtido numa conclusão; tentativas diferentes não somam estrelas da mesma cor. Derrota não confirma coleta e resultado pior não reduz recorde. Douradas e azuis têm recordes independentes.

A seleção soma os recordes do catálogo atual e mostra douradas nos cartões. Azuis não aparecem nos cartões ou no contador da fase. O resultado mostra três douradas acesas/apagadas e azul apenas quando coletada na tentativa.

Pausa preserva coletas. Reinício restaura estrelas/tanques. Último pouso recupera os IDs do checkpoint; coletas posteriores reaparecem. O salto entre portais não coleta no espaço entre entrada e saída.

## Progresso e checkpoint

`user://progresso.json`, esquema 3, guarda conclusões, liberações e recordes. Esquemas 1/2 são migrados após validação. IDs estáveis preservam recordes; fases fora do catálogo podem manter dados salvos, mas não entram nos totais exibidos.

`user://checkpoint.json` guarda início/último pouso, não um estado arbitrário em voo: posição, apoio, orientação, recursos, relógio e coletas. A validação compara fase e `content_version`. Mudanças incompatíveis devem incrementar essa versão. Vitória limpa o checkpoint compatível.

Ambos usam checksum, arquivo temporário e `.bak`. Falhas exibem aviso/retentativa; progresso pode valer só na sessão até salvar. Versões desconhecidas são preservadas e bloqueadas contra sobrescrita automática.

A API do controlador permite reabrir checkpoint pausado, mas **menu e seleção atuais não oferecem botão Continuar persistido**. Último pouso continua disponível na derrota da tentativa ativa.

## Preferências e reset

`user://preferencias.json`, esquema 2, guarda música, efeitos, vibração e dicas; lê também esquema 1. Padrões: volumes 100%, vibração e dicas ativadas. Música continua na pausa; efeitos de simulação aguardam retomada.

**Resetar Progresso** limpa checkpoint e progresso/recordes, inclusive backup de progresso, mantendo preferências independentes. Detalhes: [persistência](../tecnica/campanha.md). Instalação compatível: [atualização Android](../tecnica/atualizacao-android.md).
