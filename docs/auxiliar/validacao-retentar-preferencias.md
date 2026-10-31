# Retentativa de configurações — issue #50

Base `0f4e241`, após integração do PR #81. Quando uma gravação de preferências falhava, os volumes eram aplicados na sessão e um aviso aparecia, mas não existia ação para salvar novamente sem alterar um seletor.

O serviço agora mantém pendência após uma tentativa de gravação malsucedida. A tela explica que os volumes ainda não foram salvos e mostra **Tentar salvar novamente**. Fechar e reabrir a tela conserva os valores e a pendência no mesmo processo. Uma nova falha mantém o botão; uma gravação bem-sucedida remove aviso e pendência sem exigir alteração dos seletores. Esse estado é de memória: não restaura ajustes não salvos após encerrar o aplicativo.

Carregar um arquivo inválido continua usando os padrões com diagnóstico, sem tratá-los como uma edição pendente e sem sobrescrever o arquivo automaticamente. Alterações de volume feitas pelo usuário continuam seguindo o fluxo de gravação existente. Campanha e checkpoint não participam dessa gravação.

## Verificação

Godot 4.7.2/Windows: suíte completa com **2.678 verificações aprovadas**, incluindo 14 de retentativa. O PCK exportado passou em 30 verificações gerais e nos mesmos 14 testes de retentativa executados externamente no desktop.

`tests/test_retentar_preferencias.gd` usa somente caminhos exclusivos em `.godot/` e um diretório inicialmente ausente para provocar falha real de abertura do arquivo temporário. Verifica volumes aplicados, aviso/botão, pausa, nova falha, reabertura da tela, acesso ao botão em viewport 180×240 com recortes simulados, gravação depois de disponibilizar o diretório e leitura do arquivo por outra instância. Também verifica que entrada numérica inválida não altera arquivo salvo e que carregar JSON inválido não oferece retentativa de uma edição inexistente. Os arquivos e diretórios do teste são removidos ao final; não há simulação de disco fisicamente cheio ou corte de energia.

Capturas D3D12 reais no desktop em viewport 180×240, janela 360×480, sem recortes simulados nas imagens. O jogo permanece pausado e os arquivos de captura usam caminho temporário isolado. Reproduzir com `godot --path . --script tests/capturar_retentar_preferencias.gd`; saídas em `.godot/preferencias-*.png`.

- [Falha com aviso de sessão e retentativa](evidencias-retentar-preferencias-2026-10-30/falha.png).
- [Gravação recuperada, com os mesmos volumes](evidencias-retentar-preferencias-2026-10-30/salva.png).

Toque, legibilidade, recortes reais e comportamento do armazenamento Android continuam pendentes nas #4/#50. As evidências desktop não encerram esse aceite.
