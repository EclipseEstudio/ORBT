extends RefCounted
## Textos da campanha, apresentados sem alterar a simulação ou o progresso.

const INTRODUCAO := "Lia, piloto veterana da Corporação Horizonte, leva suprimentos médicos de volta à Terra, seu lar."
const CHEGADA := "Terra alcançada.\nLia manteve a carga segura."
const DESFECHO := "De volta ao lar.\nLia entregou os suprimentos à Terra."

static func chegada(ultima_fase: bool) -> String:
	return DESFECHO if ultima_fase else CHEGADA
