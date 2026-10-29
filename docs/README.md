# Documentação do ORBT

O [README principal](../README.md) apresenta o projeto e explica como executar o jogo. A documentação detalhada está dividida pelo tipo de informação:

| Pasta | Conteúdo | Quando consultar |
| --- | --- | --- |
| [Técnica](tecnica/README.md) | Contratos de dados, arquitetura, simulação, ferramentas e exportação | Implementar, integrar ou depurar o projeto |
| [Regras de negócio](regras-de-negocio/README.md) | Comportamento do jogo, condições da partida e progressão | Entender, discutir ou validar as regras com a equipe |
| [Auxiliar](auxiliar/README.md) | Manuais de uso, arte, acompanhamento, histórico e evidências | Criar conteúdo, retomar o trabalho ou consultar registros |

## Documentação técnica

- [Contrato JSON e modelo de simulação](tecnica/fases-e-simulacao.md)
- [Catálogo e persistência da campanha](tecnica/campanha.md)
- [Implementação e testes do editor de fases](tecnica/editor-de-fases.md)
- [Exportação e aceite Android](tecnica/android.md)

## Regras de negócio

- [Jogabilidade e ciclo da partida](regras-de-negocio/jogabilidade.md)
- [Acesso às fases e progressão da campanha](regras-de-negocio/campanha.md)

## Documentação auxiliar

- [Editor de fases: manual de uso](auxiliar/guia-editor-de-fases.md)
- [Identidade visual, fontes e inventário](auxiliar/arte/README.md)
- [Estado atual, Projects, issues e próximos passos](auxiliar/estado-da-branch.md)
- [Histórico das implementações e evidências](auxiliar/historico-implementacao.md)
- [Aceite da issue 40 e evidências da execução](auxiliar/validacao-issue-40.md)
- [Plano temporário da issue 4 (histórico substituído)](auxiliar/plano-temporario-issue-4.md)

## Manutenção

Registre cada informação na categoria correspondente e use links para relacionar regras, implementação e evidências. Mudanças de comportamento devem atualizar as regras de negócio e seus contratos técnicos; mudanças de implementação devem manter os guias técnicos coerentes com o código.

Use nomes de arquivos em minúsculas, com hífens e sem acentos. Mantenha os índices e os links relativos atualizados ao criar ou mover páginas. Fontes de arte e evidências pertencem à documentação auxiliar e continuam versionadas. Registros históricos mantêm suas datas e deixam explícito quando foram substituídos.

Os comandos dos guias partem da raiz do repositório. A separação de pastas não altera as regras nem aprova decisões do protótipo: cada documento mantém seus limites de aceite.
