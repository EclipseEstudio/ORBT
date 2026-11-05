# Preferências e atualização Android — 05/11/2026

Configurações agora inclui Vibração e Dicas, ativadas por padrão, com persistência no esquema 2. O esquema 1 continua aceito e preserva os volumes. Desativar dicas oculta a ajuda durante a partida; diálogos de pausa/resultado e avisos permanecem. Ao reativar dicas, a ajuda pode aparecer novamente. Vibração é emitida somente por impulso confirmado (25 ms), pouso (40 ms), chegada (60 ms) ou derrota (90 ms); não há pulso para gesto cancelado. A opção ativada também oferece uma prévia curta.

| Altura lógica | Ativadas | Desativadas |
| --- | --- | --- |
| 240 px | [imagem](ativadas-240.png) | [imagem](desativadas-240.png) |
| 320 px | [imagem](ativadas-320.png) | [imagem](desativadas-320.png) |
| 390 px | [imagem](ativadas-390.png) | [imagem](desativadas-390.png) |

Capturas reais com Godot 4.7.2 / Windows / Compatibility / Intel UHD Graphics, largura lógica 180 px e escala inteira 3×. Reproduzir com `tests/capturar_opcoes_jogador.gd -- 320`, trocando a altura para 240 ou 390. Na tela curta, o conteúdo rola e o cabeçalho permanece fixo.

Validação: suíte completa aprovada, incluindo 22 verificações novas em `test_opcoes_jogador.gd`, e 14 verificações PowerShell de compatibilidade e sintaxe. Também foi exercitada a configuração CI com credenciais ausentes e com a chave real: a ausência falha sem gerar outra chave; a configuração mantém a identidade do certificado. O SDK de teste desse exercício é uma estrutura de arquivos para validar o configurador, não uma execução Android. Um APK real foi exportado em uma etapa independente com as ferramentas Android locais.

Total contabilizado: 2.982 verificações Godot, 31 do pacote exportado e 14 PowerShell, todas aprovadas (3.027 no total). O configurador e o APK assinado também foram conferidos conforme descrito acima.

APK local de validação: `build/android/ORBT-0.3.2-qa.apk`, versão 0.3.2 / código 5, pacote `com.eclipseestudio.orbt`. Assinatura permanente e permissão `VIBRATE` foram conferidas no arquivo. SHA-256 atual: `cf3cf47ce9e176edce22cb7ade175431566951f6ab731fe13908eb47eec271cc`, regenerado com os [efeitos de voo](../evidencias-efeitos-2026-11-05/README.md). O certificado público está em `scripts/assinatura-android.json`; chave e senha permanecem fora do Git. Os três segredos necessários foram cadastrados no repositório GitHub.

A comparação com o APK publicado de 0.3.1 aprovou o aumento de código e identificou a migração de assinatura temporária para permanente. Instalação, reinstalação preservando dados e resposta física da vibração não foram executadas no aparelho. O APK local não foi publicado no site nesta etapa; a alteração da página contém as instruções de atualização para uma próxima publicação.

Ajuste de oxigênio: o primeiro lançamento inicia o consumo; pouso pausa e nova decolagem retoma o saldo, sem recarga por impulso. Foram acrescentadas duas verificações de pouso/decolagem e atualizadas as de correção e saldo quase esgotado. A suíte completa, incluindo as rotas das dez fases, passou novamente. O APK de teste acima foi regenerado com essa regra. A pausa geral continua congelando toda a partida.
