# Retentativa do checkpoint — issue #49

Base `9f79864`, após integração do PR #83. Uma falha de gravação preservava o arquivo anterior, mas não havia ação para salvar novamente o último pouso sem repeti-lo. O serviço agora conserva uma cópia independente do snapshot e da versão ainda não gravados, em memória, até nova gravação bem-sucedida, vitória ou descarte explícito.

O menu oferece **Salvar último pouso** enquanto houver pendência gravável. Continuar fica indisponível nesse intervalo, para não restaurar silenciosamente o checkpoint anterior. Depois de gravar, o menu volta a oferecer Continuar com o pouso recuperado. A retomada continua pausada, com o apoio, posição, combustível e tempo do snapshot.

Uma nova falha conserva a pendência e o último arquivo válido. Recarregar o serviço não apaga uma pendência nem remove seu bloqueio. Checkpoints bloqueados não permitem retentativa. Vitória e descarte eliminam a pendência; não é possível ressuscitá-la por uma retentativa posterior. O formato do save, checksum, substituição por temporário e cópia anterior permanecem iguais. A pendência não sobrevive ao encerramento do aplicativo: até conseguir salvar, só existe no processo atual.

## Verificação

Godot 4.7.2/Windows: suíte completa com **2.741 verificações aprovadas**, incluindo 16 de retentativa. O PCK exportado passou em 30 verificações gerais e nos mesmos 16 testes de retentativa executados externamente no desktop.

`tests/test_retentar_checkpoint.gd` começa com checkpoint inicial salvo, injeta falha no método `_gravar` durante um pouso intermediário e confirma que o arquivo anterior permanece igual. O menu é exercitado com falha repetida e recuperação da escrita; uma nova instância lê o arquivo real, e Continuar restaura apoio com combustível 3 e tempo 12,5 s, pausado. O teste verifica a cópia anterior, ausência de gravação de preferências/progresso durante a retentativa, bloqueio, descarte e vitória. Os caminhos são absolutos, exclusivos em `.godot/`, para que o teste de remoção use o sistema de arquivos real também ao executar contra PCK; arquivos do teste são removidos ao final.

Capturas D3D12 reais no desktop em viewport 180×240 e janela 360×480, sem recortes simulados. Dados e falhas são de teste; a captura usa somente caminhos isolados. Reproduzir com `godot --path . --script tests/capturar_retentar_checkpoint.gd`; saídas em `.godot/checkpoint-retentar-*.png`.

| Etapa | Evidência |
| --- | --- |
| Falha com retentativa disponível | [Salvar último pouso](evidencias-retentar-checkpoint-2026-10-30/pendente.png) |
| Gravação recuperada | [Continuar disponível](evidencias-retentar-checkpoint-2026-10-30/salvo.png) |
| Retomada do pouso recuperado | [Partida pausada](evidencias-retentar-checkpoint-2026-10-30/continuar.png) |

Este ensaio injeta a falha de escrita; não simula armazenamento fisicamente cheio nem corte de energia. A recuperação escreve e lê arquivos reais no Windows. Falta testar a nova retentativa no Android e por toque; #49/#4 permanecem abertas para esse aceite.
