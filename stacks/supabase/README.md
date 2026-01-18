# Stack: Supabase Self-Hosted

Este e o motor de backend para os agentes de IA da **Aiknow Systems**.

## Como Rodar

1. Basta executar o script de setup interativo:
   ```bash
   sudo bash setup.sh
   ```
2. O script vai gerar automaticamente as chaves de seguranca e subir os containers.

## Segredos Gerados

O `setup.sh` gera as seguintes chaves no seu `.env`:
- **JWT_SECRET:** Usado para autenticar as sessoes.
- **ANON_KEY:** Chave publica para o seu frontend.
- **SERVICE_ROLE_KEY:** Chave mestre (ignore todas as permissoes RLS).

## Banco de Vetores (pgvector)

O banco de dados ja vem com suporte ao `pgvector`. Para usar nos seus agentes:
1. Acesse o Dashboard Studio (porta 8000).
2. No SQL Editor, rode:
   ```sql
   CREATE EXTENSION IF NOT EXISTS vector;
   ```

## Troubleshooting

- **RAM:** Se os containers ficarem em loop de restart, verifique se ha memoria livre suficiente (minimo 2GB livre).
- **Logs:** `docker compose logs -f auth` para problemas de login.
