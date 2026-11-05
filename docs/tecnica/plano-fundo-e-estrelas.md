# Plano: fundo do menu e estrelas coletáveis

Registro do planejamento original. Em 05/11/2026, as estrelas foram implementadas na campanha de 20 fases: consulte as [regras atuais](../regras-de-negocio/campanha.md) e o [contrato de coleta](estrelas-coletaveis.md). As propostas abaixo ficam como histórico; não representam pendências atuais das estrelas. O fundo do menu é um trabalho separado.

## Fundo do menu principal

Objetivo: substituir o fundo atual por uma imagem pixel art mais detalhada, preservando a composição do wireframe: título no alto, nave/planeta na região central e ações na base.

1. Produzir uma arte vertical em resolução nativa baixa, inicialmente 180×390, com paleta coerente com a nave e os corpos existentes. Incluir detalhes de superfície, estrelas em diferentes planos e iluminação controlada. Manter áreas escuras atrás do título e dos botões para garantir contraste.
2. Preparar a composição com foco central e margens para recorte em telas 180×240, 180×320 e 180×390. Evitar texto, botões ou logos incorporados à imagem. Os controles continuam sendo elementos da interface.
3. Integrar como textura de produção em `Recursos/ModelosVisuais/fundo_menu.png`, aproveitando o carregamento de `src/Visual/fundo_menu.gd`. Preservar filtros de pixel art, sem desfoque. Conferir o recorte atual por preenchimento e separar a aplicação ao menu principal das telas de créditos/configurações para que a troca não acrescente ruído às demais telas.
4. Inspecionar capturas reais nas três alturas, área segura com recortes e escala inteira. Conferir texto, botões, tamanho do arquivo e inclusão do recurso no APK. Validar no Android antes de publicar.

Entrega futura: arte aprovada, imagem integrada e capturas comparativas. Ordem sugerida: composição → arte → integração → conferência em telas e aparelho. Não há geração nem substituição de arte neste ajuste.

## Estrelas coletáveis durante o voo

Objetivo: oferecer rotas opcionais mais desafiadoras, sem impedir a conclusão da fase ao chegar à Terra.

### Regras propostas

- Começar com até três estrelas fixas por fase, distribuídas manualmente. A quantidade é uma escolha inicial de design, a calibrar no protótipo.
- A nave coleta ao atravessar a área da estrela; cada ID conta uma vez por tentativa. A coleta não cobra combustível nem restaura oxigênio. A estrela desaparece com uma resposta visual curta, respeitando as opções de vibração/dicas.
- Reiniciar a fase restaura todas as estrelas. Pausa e exploração preservam o estado. Retornar ao último pouso restaura os IDs coletados naquele checkpoint e recoloca as estrelas coletadas depois dele.
- Ao chegar à Terra, registrar o melhor total obtido numa mesma conclusão. Uma tentativa pior não reduz o recorde; não somar automaticamente estrelas de tentativas diferentes. A derrota não altera o melhor resultado da campanha.
- Mostrar a contagem da tentativa no HUD e o melhor resultado na seleção e na conclusão, preservando espaço e leitura em 180 pixels de largura. Chegar à Terra continua liberando a próxima fase independentemente das estrelas.

### Dados e integração

| Área | Implementação futura |
| --- | --- |
| JSON das fases | Campo opcional `stars`, com `id`, `position` e `radius`; ausência equivale a nenhuma estrela. Validar IDs únicos, números finitos, posição dentro dos limites e raio positivo. Impedir posições dentro de corpos ou saídas de portais. |
| Simulação e coleta | Usar os segmentos realmente percorridos no passo, verificando distância do ponto ao segmento contra raio da estrela + raio da nave. Evitar perder estrelas em alta velocidade. |
| Portais | Expor os trechos físicos de entrada/saída no resultado da simulação; nunca tratar o salto entre portais como um segmento coletável. Definir a ordem temporal de coleta e contato com a Terra dentro do mesmo passo. |
| Partida | Guardar IDs coletados em um conjunto, emitir evento de coleta e incluir o conjunto no checkpoint. O estado visual deriva desse conjunto. |
| Campanha e save | Adicionar melhor resultado por ID/conteúdo da fase. Migrar explicitamente o esquema 1 atual, preservando fases concluídas e liberadas, checksum, backup e retentativa de gravação. Checkpoints antigos entram com conjunto vazio. Não sobrescrever formatos mais novos desconhecidos. |
| Editor | Adicionar criar/mover/remover estrela, validação, desfazer/refazer e teste da fase. Dados continuam usando o carregador comum. |
| Apresentação | Sprite pequeno contrastante, animação curta sem partículas pesadas, contador compacto e resultado na seleção/conclusão. Distinguir estrelas coletáveis das estrelas decorativas do fundo. |

### Sequência de implementação

1. Validar uma fase piloto e o contrato JSON opcional, sem editar as dez fases de uma vez.
2. Implementar os segmentos físicos e a coleta determinística, incluindo portais e contatos simultâneos.
3. Integrar reinício, derrota, checkpoint e persistência com migração compatível.
4. Acrescentar HUD, resultado, seleção e edição de estrelas.
5. Distribuir estrelas nas fases restantes, calibrar rotas e verificar no aparelho.

### Critérios de aceite

Coletar uma estrela com voo normal e em alta velocidade; impedir duplicação; não coletar pelo salto de portal; resolver coleta/chegada no mesmo passo em ordem temporal; manter os recursos e a física; restaurar corretamente pausa, reinício e checkpoint; preservar recordes maiores e migrar saves antigos sem perder progresso; recuperar backup/retentar gravação; manter HUD e cartões legíveis em 180×240, 180×320 e 180×390.

O fundo pode ser feito de forma independente. As estrelas precisam primeiro de contrato, coleta e persistência; a expansão visual vem depois desse fluxo validado.
