# Revisão das issues — 30/10/2026

Escopo e critérios de aceite preservados. Nenhuma issue é encerrada por esta sincronização. A próxima implementação é #48, após consolidar a revisão da #13. Validação Android permanece na #4.

## [Issue #13](https://github.com/EclipseEstudio/ORBT/issues/13)

Implementação parcial existente: `SimulacaoVoo` soma a aceleração das fontes com suavização, usa Euler semi-implícito a 60 Hz e compartilha integrador/contatos com a prévia (#11/#12/#18). Proximidade não limita a atração. A atualização da alpha reúne recalibração da primeira fase (G=2, softening=8, massas 24.000/30.000) e testes adicionais; a fórmula não muda.

Pendente nesta issue: consolidar a decisão do modelo, parâmetros e tolerâncias e registrar execução reproduzível de aproximação, desvio lateral e duas fontes, com versão, valores e trajetórias. Existência de código/testes não equivale a aceite; critérios originais permanecem pendentes. Android integra #4; legibilidade/custo da prévia ficam em #18. Gravitação mútua, órbitas e rotação continuam fora do escopo inicial. Referência: `docs/tecnica/fases-e-simulacao.md` e `docs/auxiliar/estado-da-branch.md`.

## [Issue #48](https://github.com/EclipseEstudio/ORBT/issues/48)

Próxima implementação recomendada após consolidar a revisão da #13. Progresso de campanha já existe e deve ser reutilizado/preservado; snapshots de tentativa continuam ausentes. Antes do aceite, definir checkpoint de início (inclusive início livre), pouso sem combustível, restauração após derrota e diferença entre restaurar e Reiniciar. Persistência após encerrar o processo pertence à #49; apresentação completa de Continuar pertence à #51. Nenhum critério foi dado como concluído nesta revisão.

## [Issue #49](https://github.com/EclipseEstudio/ORBT/issues/49)

Permanece pendente, após #48. Reutilizar a infraestrutura de persistência/recuperação existente sem confundir IDs concluídos/liberados com snapshot da tentativa. Recuperar pausado e com gesto cancelado; preservar progresso e conteúdo autoral diante de checkpoint incompatível. Fluxo completo de menus em #51, sem dependência circular para implementar o serviço.

## [Issue #51](https://github.com/EclipseEstudio/ORBT/issues/51)

Preservar seleção/campanha e controles de pausa, reinício e retorno à seleção já existentes. Implementar somente os fluxos restantes com #48/#49/#50: Continuar, configurações, créditos e ações específicas dos resultados. Não refazer o progresso da #40 nem tratar restauração de checkpoint como repetição de fase.

## [Issue #52](https://github.com/EclipseEstudio/ORBT/issues/52)

A atualização da alpha reúne seis fases no catálogo: `teste_001`, `salto_curto`, `na_diagonal`, `curva_suave`, `escala_segura` e `entre_asteroides`. As cinco adicionais foram adaptadas do protótipo `dev-macb/orbt`, com início livre, corpos estáticos e rotas cobertas em `tests/test_fases.gd`. Preservar IDs estáveis e a compatibilidade de desbloqueio de saves anteriores.

Entrega parcial: completar as quatro fases restantes e revisar a sequência didática/composição para atender aos dez mapas. O aceite de conteúdo e a revisão por outra pessoa permanecem pendentes; seis arquivos e testes automatizados não concluem esta issue. Balanceamento e soluções com revisão cruzada ficam na #53. Órbitas/portais/rotação continuam condicionais.

## [Issue #53](https://github.com/EclipseEstudio/ORBT/issues/53)

Já há seis fases no catálogo da atualização da alpha e rotas automatizadas em `tests/test_fases.gd`; isso é evidência técnica parcial, sem substituir playtest. Preservar essas rotas e calibrar a campanha completa após #52, registrando impulsos, pousos, consumo, saldo e reprodução por outro integrante em aparelho. A recalibração da gravidade da primeira fase deve acompanhar a decisão/evidência da #13. Critérios de aceite permanecem pendentes.
