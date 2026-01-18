# Docker Compose Templates

Repositorio de templates docker-compose.yml padronizados para deploy de aplicacoes da **Aiknow Systems**.

## Estrutura do Projeto

```
compose/
├── CLAUDE.md           # Contexto Claude Code
├── GEMINI.md           # Contexto Gemini Code
├── README.md           # Este arquivo
├── stacks/             # Stacks completas
│   ├── n8n/
│   ├── uptime-kuma/    # Monitoramento
│   └── kopia/          # Backup Server
└── templates/          # Scripts e blocos reutilizaveis
```

## Guia de Deploy Rapido

Todas as novas stacks possuem um script `setup.sh` para facilitar a instalacao:

```bash
cd stacks/uptime-kuma
sudo bash setup.sh
```

## Stacks Disponiveis

| Stack | Descricao | Porta Padrao | Setup.sh |
|-------|-----------|--------------|----------|
| [uptime-kuma](stacks/uptime-kuma/) | Monitoramento de Uptime | 3001 | ✅ |
| [kopia](stacks/kopia/) | Servidor de Backup | 51515 | ✅ |
| [n8n](stacks/n8n/) | Automacao de Workflow | 5678 | 🚧 |

## Diretrizes de Seguranca (Security-First)

- **Acesso:** Portas expostas em todas as interfaces (Multihome) (Acesso via LAN, Tailscale ou Funnel).
- **Rede:** Todas as stacks usam a rede externa `llmserver`.
- **Manutencao:** Watchtower incluso para auto-update.
- **Portas:** Seguimos a **Regra 45-55** para resolucao de conflitos.
