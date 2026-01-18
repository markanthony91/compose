# Docker Compose Templates

Repositorio de templates docker-compose.yml padronizados da **Aiknow Systems**.

## Stacks Disponiveis

| Stack | Descricao | Porta Padrao | Status |
|-------|-----------|--------------|--------|
| [ai-database](stacks/ai-database/) | Postgres (pgvector) + Redis | 5432 | ✅ |
| [supabase](stacks/supabase/) | Backend completo (Auth/REST) | 8000 | ✅ |
| [dify](stacks/dify/) | Orquestrador de Agentes | 8001 | ✅ |
| [ragflow](stacks/ragflow/) | Deep Document Parsing RAG | 8002 | ✅ |
| [open-webui](stacks/open-webui/) | Interface IA + RAG | 3000 | ✅ |
| [uptime-kuma](stacks/uptime-kuma/) | Monitoramento | 3001 | ✅ |
| [n8n](stacks/n8n/) | Automacao | 5678 | 🚧 |
