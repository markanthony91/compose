# Docker Compose Templates

Repositorio de templates docker-compose.yml padronizados da **Aiknow Systems**.

## Stacks Disponiveis

| Stack | Descricao | Porta Padrao | Setup.sh |
|-------|-----------|--------------|----------|
| [ai-database](stacks/ai-database/) | Postgres (pgvector) + Redis | 5432 / 6379 | ✅ |
| [supabase](stacks/supabase/) | Backend completo | 8000 | ✅ |
| [autogen-studio](stacks/autogen-studio/) | Playground Multi-agentes | 8081 | ✅ |
| [langgraph](stacks/langgraph/) | Motor de Agentes de Estado | 8123 | ✅ |
| [qdrant](stacks/qdrant/) | Vector DB (RAG) | 6333 / 6334 | ✅ |
| [open-webui](stacks/open-webui/) | Interface IA + RAG | 3000 | ✅ |
| [uptime-kuma](stacks/uptime-kuma/) | Monitoramento | 3001 | ✅ |
| [n8n](stacks/n8n/) | Automacao | 5678 | 🚧 |
