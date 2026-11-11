> Registro histórico. Descreve a revisão testada à época; consulte a [documentação atual](../../../README.md) para o comportamento vigente.

# Atualização Android sem desinstalação — 05/11/2026

## Diagnóstico no aparelho

O aparelho conectado foi um Samsung SM-A556E (Galaxy A55), Android 16 / API 36. O ORBT instalado era exatamente o APK publicado da versão 0.3.2 / código 5, com SHA-256 `f45ff9a893a4847a671f9ff0b69de22d45e78f17c0c7bd23dc12edc29e456d2f` e certificado permanente registrado no projeto. A comparação não encontrou troca de assinatura nessa instalação.

O erro anterior relatado pelo usuário não foi reproduzido nesses testes; não atribuir a causa original a uma assinatura diferente sem evidência. O site ainda oferece a 0.3.2; as alterações seguintes estavam somente no workspace.

Durante a consulta inicial, o gerenciador de pacotes tentou acessar um perfil Android protegido, emitindo erro de permissão. O instalador auxiliar foi corrigido para identificar o perfil atual e usá-lo explicitamente nas consultas, leitura dos saves e instalação. O diagnóstico foi repetido sem esse erro.

## Testes reais concluídos

| Teste | Resultado |
| --- | --- |
| Atualizar 0.3.2 / código 5 para 0.3.3 / código 6 por USB | Aprovado, usando `install -r --user`, sem desinstalação nem limpeza de dados |
| Abrir o mesmo candidato pela pasta Downloads do celular | Usuário confirmou instalação concluída sem desinstalar |
| Progresso, checkpoint, preferências e cópia do progresso | Quatro arquivos com hashes idênticos antes/depois em ambos os testes |
| Versão após a instalação | Android confirmou versão 0.3.3 e código 6 |
| Comparação com a release publicada | Mesmo pacote/certificado, código maior, sem nova migração de assinatura |

APK local testado: `build/android/ORBT-0.3.3-qa.apk`. SHA-256: `8ec90e357eed4164146f2b281c183534b7dbcc26a61fe9e4dbe5d794ed1dd901`. Certificado SHA-256: `8cb1972c2bec45b3de59fe76441564527bd8e0f802aa88dff6d09c6289013843`.

O teste USB foi autorizado pelo usuário depois do diagnóstico somente de leitura. O teste pelo instalador foi executado pelo próprio usuário, seguido da comparação dos arquivos. Os relatórios completos com hashes individuais permanecem em `.godot/`, fora do Git; não foram copiados identificadores do aparelho nem conteúdo dos saves para esta evidência.

## Processo reforçado

- Exportação local e CI confrontam versão do projeto, versão/código do preset e identidade do APK real. Arquivo antigo com mesmo nome, versão divergente ou outra assinatura reprova a verificação.
- Candidato preparado como 0.3.3 / código 6, preservando a chave permanente da 0.3.2.
- `instalar-android.ps1 -SomenteDiagnostico` permite comparar com a instalação do aparelho sem alterá-la.
- `-ConferirDados -Relatorio ...` comprova a atualização e a integridade dos saves; falta de arquivos ou erro de leitura não gera aprovação falsa.
- A página de download foi ajustada localmente para mostrar a versão oferecida junto ao tamanho, evitando confusão com downloads repetidos. Essa alteração da página ainda não foi publicada.

Validação automatizada desta etapa: 24 verificações PowerShell e 34 do pacote exportado isolado, todas aprovadas. Os testes físicos acima complementam essas verificações; não substituem avaliar conforto do zoom ou vibração.

Estado final: candidato instalado no aparelho e processo de atualização validado nos dois caminhos testados. Nenhuma nova release foi publicada; o download público continua sendo a 0.3.2.
