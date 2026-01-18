# Docker Compose Templates

Repositorio de templates docker-compose.yml padronizados para deploy de aplicacoes da **Aiknow Systems**.

## Estrutura do Projeto

```
compose/
├── CLAUDE.md           # Contexto Claude Code
├── GEMINI.md           # Contexto Gemini Code
├── README.md           # Este arquivo
├── stacks/             # Stacks completas
│   ├── ai-database/    # Central de Vetores e Filas
│   ├── supabase/       # Backend completo (Auth/REST/DB)
│   ├── n8n/            # Automacao de Workflow
│   └── uptime-kuma/    # Monitoramento
└── templates/          # Scripts e blocos reutilizaveis
```

## Guia de Deploy Rapido

Todas as novas stacks possuem um script `setup.sh` para facilitar a instalacao:

```bash
cd stacks/supabase
sudo bash setup.sh
```

## Stacks Disponiveis

| Stack | Descricao | Porta Padrao | Setup.sh |
|-------|-----------|--------------|----------|
| [ai-database](stacks/ai-database/) | Postgres (pgvector) + Redis + pgAdmin | 5432 / 6379 | ✅ |
| [supabase](stacks/supabase/) | Backend completo (Auth, REST, Studio) | 8000 | ✅ |
| [uptime-kuma](stacks/uptime-kuma/) | Monitoramento de Uptime | 3001 | ✅ |
| [n8n](stacks/n8n/) | Automacao de Workflow | 5678 | 🚧 |

## Diretrizes de Seguranca (Security-First)

- **Acesso:** Portas expostas em todas as interfaces, controladas pelo Firewall do Host (Multihome).
- **Rede:** Todas as stacks usam a rede externa `llmserver`.
- **Manutencao:** Watchtower incluso para auto-update.
- **Portas:** Seguimos a **Regra 45-55** para resolucao de conflitos.
