# Personal Trainer IA Completo

Projeto híbrido Flutter + HTML funcional. O HTML oficial permanece como fonte de verdade, enquanto Flutter fornece empacotamento Android, WebView e ponte nativa para descanso, vibração, bip, compartilhamento e links externos.

## Importar o HTML oficial
1. Coloque `Personal_Trainer_IA_Estrutura_Comercial_Simplificada 1.html` na raiz.
2. Execute `bash tools/importar_html_base.sh`.
3. Confirme que `assets/web/personal_ia.html` possui aproximadamente 22 MB.
4. Commit e push.

## Por que híbrido
Essa abordagem preserva agora todas as funções existentes sem reescrevê-las de forma incompleta. Os módulos podem ser migrados gradualmente para Dart depois, com comparação direta contra o HTML.

## Conteúdo atualizável
O catálogo de 106 exercícios está em `assets/data/exercises_seed.json`. Firebase poderá substituir/adicionar exercícios e imagens sem novo APK após a configuração do backend.
