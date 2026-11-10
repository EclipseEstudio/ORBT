# Visão geral

Fonte: `project.godot`, `Recursos/Niveis.json`, `src/ControladorJogo/`, `src/Nave/`, `src/Nivel/` e `src/Campanha/`. Conferido em 10/11/2026.

ORBT é um puzzle espacial 2D em pixel art para Android. A nave retorna à Terra usando impulsos, gravidade e pousos. O desenvolvimento e os testes também rodam no desktop.

O projeto declara versão 0.5.0 e código Android 9. Usa renderizador Mobile e viewport 180 × 320; o CI fixa Godot 4.7.2, Java 17 e Build-Tools Android 36.1.0. O único preset de exportação versionado é Android.

| Área | Implementação presente |
| --- | --- |
| Campanha | 30 fases, três blocos de dez, sequência e metas de estrelas |
| Recursos | Combustível por impulso, oxigênio por tentativa e tanques coletáveis |
| Estrelas | Três douradas por fase; azul secreta nas fases 2–30; recordes confirmados na vitória |
| Física | Gravidade suavizada, contatos por segmento, pouso, correção e deriva |
| Corpos | Planetas, estações, Terra, sóis, asteroides; leitura de satélites antigos |
| Mecânicas avançadas | Órbitas circulares, rotação, faixas de pouso, portais pareados e nebulosas |
| Apresentação | Títulos dispensáveis, dicas, câmera, bússolas, parallax, explosão e rastro |
| Interface | Splash, menu, seleção, pausa, configurações, créditos e resultados |
| Persistência | Progresso e checkpoint separados, backups/retentativas; preferências |
| Autoria | Plugin ORBT Fases com edição, histórico, validação, rascunho e teste isolado |
| Distribuição | Scripts Android, CI de PR e página que seleciona APKs das Releases |

Regras detalhadas: [jogabilidade](../regras-de-negocio/jogabilidade.md) e [campanha](../regras-de-negocio/campanha.md). Conteúdo: [catálogo](catalogo-fases.md).

## Narrativa e limites

`src/Narrativa/narrativa.gd` define Lia, piloto veterana da Corporação Horizonte, transportando suprimentos médicos à Terra. O menu mantém a introdução em um rótulo oculto com tooltip; a partida usa textos de chegada/desfecho. Isso não equivale a uma apresentação narrativa completa. Não há cena final de praia implementada.

Não foram identificados modo infinito, evento de erupção solar, exportação Web jogável ou portais móveis. O GitHub Pages oferece download do APK Android. Exemplos JSON fora do catálogo não aparecem na campanha.

As antigas etapas M1/M2/M3 explicam decisões no histórico. O código orienta o escopo vigente; testes humanos ainda necessários estão em [validação pendente](validacao-pendente.md).
