# Docker Compose Templates

Repositorio de templates docker-compose.yml padronizados para deploy de aplicacoes.

## Sobre

Este repositorio contem stacks Docker Compose prontas para producao, seguindo boas praticas de seguranca e organizacao.

**Autor:** Mark - Aiknow Systems

## Estrutura

```
compose/
├── CLAUDE.md           # Diretrizes para desenvolvimento
├── README.md           # Este arquivo
├── .gitignore          # Arquivos ignorados
└── stacks/             # Stacks completas
    ├── n8n/            # Workflow automation
    ├── autoheal/       # Reinicio automatico (em breve)
    └── monitoring/     # Prometheus + Grafana (em breve)
```

## Pre-requisitos

```bash
# 1. Docker Engine 24+ e Compose v2
docker --version
docker compose version

# 2. Criar network compartilhada
docker network create llmserver

# 3. Tailscale instalado (para acesso externo)
tailscale --version
```

## Uso Rapido

```bash
# Clonar repositorio
git clone https://github.com/markanthony91/compose.git
cd compose

# Escolher uma stack
cd stacks/n8n

# Copiar e configurar .env
cp .env.example .env
nano .env

# Subir stack
docker compose up -d

# Executar testes
./run_tests.sh

# Expor via Tailscale
tailscale funnel 443 http://localhost:5678
```

## Stacks Disponiveis

| Stack | Descricao | Porta | Status |
|-------|-----------|-------|--------|
| [n8n](stacks/n8n/) | Workflow automation + PostgreSQL + Redis | 5678 | ✅ |
| autoheal | Reinicio automatico de containers | - | 🚧 |
| monitoring | Prometheus + Grafana + cAdvisor | 3000 | 🚧 |

## Recursos de Cada Stack

Toda stack inclui:

- ✅ **Network llmserver** - Comunicacao entre containers
- ✅ **Watchtower** - Atualizacao automatica (dom 22:00)
- ✅ **Backup Restic** - Backup diario para destino remoto
- ✅ **Healthchecks** - Monitoramento de saude
- ✅ **Testes Goss** - Validacao pos-deploy
- ✅ **Tailscale** - Acesso seguro externo

## Padrao de Portas

| Range | Uso |
|-------|-----|
| 15000-20000 | Aplicacoes web |
| 20001-25000 | APIs e backends |
| 25001-30000 | Bancos de dados |
| 30001-35000 | Monitoramento |

## Testes

```bash
# Instalar goss (uma vez)
curl -fsSL https://goss.rocks/install | sh

# Executar testes de uma stack
cd stacks/n8n
./run_tests.sh
```

## Contribuindo

1. Seguir padroes do `CLAUDE.md`
2. Validar sintaxe: `docker compose config`
3. Criar testes Goss
4. Nunca commitar senhas reais
5. Documentar cada stack

## Licenca

MIT
