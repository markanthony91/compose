# Docker Compose Templates

Repositorio de templates docker-compose.yml padronizados da **Aiknow Systems**.

## Stacks Disponiveis e Cobertura de Testes

| Stack | Descricao | Testes Unitarios | Status |
|-------|-----------|------------------|--------|
| [ai-database](stacks/ai-database/) | Postgres (pgvector) + Redis | 1 | ✅ |
| [supabase](stacks/supabase/) | Backend completo (Auth/REST) | 1 | ✅ |
| [qdrant](stacks/qdrant/) | Vector DB (RAG) | 1 | ✅ |
| [open-webui](stacks/open-webui/) | Interface IA + RAG | 1 | ✅ |
| [dify](stacks/dify/) | Orquestracao de Agentes | 1 | ✅ |
| [ragflow](stacks/ragflow/) | Deep Doc Parsing | 1 | ✅ |
| [autogen-studio](stacks/autogen-studio/) | Multi-Agentes | 1 | ✅ |
| [langgraph](stacks/langgraph/) | Motores de Estado | 1 | ✅ |
| [kopia](stacks/kopia/) | Servidor de Backup | 1 | ✅ |
| [uptime-kuma](stacks/uptime-kuma/) | Monitoramento | 1 | ✅ |
| [n8n](stacks/n8n/) | Automacao | 0 | 🚧 |

## Diretrizes de Seguranca

- **Multihome:** Suporte a LAN, Tailscale e Localhost.
- **Testes:** Todo `setup.sh` deve ter um teste `.bats` correspondente.
