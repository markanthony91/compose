### 8. Stacks Existentes e Portas

| Stack | Porta Host | Finalidade |
|-------|------------|------------|
| ai-database | 5432 / 6379 | Vetores (RAG) e Filas |
| supabase | 8000 | Backend Full-stack |
| autogen-studio | 8081 | Playground Multi-agentes |
| langgraph | 8123 | Motor de Agentes de Estado |
| qdrant | 6333 / 6334 | Vector DB para RAG |
| open-webui | 3000 | Interface IA + RAG |
| uptime-kuma | 3001 | Monitoramento de Uptime |
| n8n | 5678 | Automacao |

### 9. Testes Unitarios de Setup
Para garantir a confiabilidade das stacks:
- **Requisito:** Cada stack com `setup.sh` DEVE possuir um arquivo de teste correspondente em `tests/[nome].bats`.
- **Mocks:** Utilize o arquivo `tests/mocks/system_mocks.bash` para simular comandos de sistema (Docker, Tailscale, ss).
- **Execucao:** Todos os testes devem passar ao rodar `./run_tests.sh`.
