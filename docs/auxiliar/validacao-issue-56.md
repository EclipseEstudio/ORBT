# Proposta e validação da narrativa — issue #56

Proposta submetida à equipe: Lia é uma piloto veterana da Corporação Horizonte, transportando suprimentos médicos para a Terra, seu lar. O nome da piloto, a corporação e o tipo de carga são escolhas desta proposta, ainda não aprovadas. O GDD citado na issue não estava disponível nesta cópia; é necessário conferir sua seção 3 antes do aceite.

O menu apresenta a missão; vitórias intermediárias indicam a chegada e a segurança da carga; a última vitória apresenta a entrega à Terra. Repetir uma fase mantém as regras existentes. O texto não exige coleta, dublagem, cenas cinematográficas, reputação ou ramificações, e a simulação não é modificada pela narrativa.

## Evidências

Em 30/10/2026, Windows/Godot 4.7.2, base `d6742e4` com alterações deste PR: `tests/run.ps1` passou com 1.220 verificações, incluindo 14 da narrativa. `tests/run_exportacao.ps1` passou com 23 verificações no PCK; `tests/test_narrativa.gd` executado contra o PCK passou com 14 verificações. O PCK no desktop não substitui um APK testado em aparelho.

| Cenário | Esperado e observado |
| --- | --- |
| Menu inicial | Apresenta piloto experiente, corporação, carga e Terra; texto ignora toque e não se sobrepõe ao botão Campanha. |
| Menu com checkpoint ou diagnóstico | Ações permanecem na área visível; diagnóstico tem prioridade e oculta a introdução. |
| Primeira fase e derrota | Tutorial inicial e causa da derrota permanecem visíveis. |
| Vitória intermediária e final | Mensagem adequada, avanço oferecido apenas quando há próxima fase, progresso e repetição preservados. |

Capturas do menu e das duas vitórias foram inspecionadas no Windows/OpenGL. Para reproduzir, executar `godot --path . --rendering-method gl_compatibility --script tests/capturar_narrativa.gd`; as imagens ficam em `.godot/narrativa-*.png`. As vitórias das capturas são acionadas pelo roteiro de teste, não representam playtest da campanha.

Aprovação de identidade e textos pela equipe, comparação com o GDD e legibilidade em aparelho continuam pendentes; a #56 permanece aberta para aceite.
