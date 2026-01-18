# n8n - Workflow Automation

Stack completa do n8n com PostgreSQL, Redis, Workers e atualizacao automatica.

## Arquitetura

```
                    ┌─────────────────┐
                    │   Tailscale     │
                    │   Funnel/Proxy  │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │      n8n        │
                    │   (Web + API)   │
                    │   porta 5678    │
                    └────────┬────────┘
                             │
           ┌─────────────────┼─────────────────┐
           │                 │                 │
    ┌──────▼──────┐   ┌──────▼──────┐   ┌──────▼──────┐
    │  PostgreSQL │   │    Redis    │   │   Workers   │
    │   (dados)   │   │   (filas)   │   │  (1 e 2)    │
    └─────────────┘   └─────────────┘   └─────────────┘
                             │
                    ┌────────▼────────┐
                    │   Watchtower    │
                    │ (auto-update)   │
                    │  dom 22:00      │
                    └─────────────────┘
```

## Componentes

| Servico | Imagem | Funcao |
|---------|--------|--------|
| postgres | postgres:16-alpine | Banco de dados principal |
| redis | redis:7-alpine | Gerenciamento de filas |
| n8n | n8n:2.3.4 | Interface web + webhooks |
| n8n-worker-1 | n8n:2.3.4 | Processamento paralelo |
| n8n-worker-2 | n8n:2.3.4 | Processamento paralelo |
| watchtower | containrrr/watchtower | Atualizacao automatica |

## Recursos

### Healthchecks
Todos os containers possuem healthcheck configurado:
- **postgres:** `pg_isready` (10s interval)
- **redis:** `redis-cli ping` (10s interval)
- **n8n:** `/healthz` endpoint (30s interval)
- **workers:** `pgrep n8n worker` (30s interval)
- **watchtower:** `--health-check` (60s interval)

### Atualizacao Automatica (Watchtower)
- **Schedule:** Todo domingo as 22:00
- **Escopo:** Apenas containers com label `watchtower.enable=true`
- **Cleanup:** Remove imagens antigas automaticamente
- **Revive:** Reinicia containers parados apos atualizar

### Integracao com Autoheal
Containers com label `autoheal=true` serao reiniciados automaticamente se ficarem unhealthy:
- n8n (main)
- n8n-worker-1
- n8n-worker-2

## Pre-requisitos

```bash
# Criar network externa
docker network create llmserver

# Criar volume externo para dados do n8n
docker volume create n8n_data
```

## Instalacao

```bash
# 1. Clonar repositorio
git clone https://github.com/markanthony91/compose.git
cd compose/stacks/n8n

# 2. Configurar variaveis
cp .env.example .env
nano .env

# 3. Gerar chave de criptografia
openssl rand -hex 32
# Copie o resultado para N8N_ENCRYPTION_KEY no .env

# 4. Subir stack
docker compose up -d

# 5. Verificar status
docker compose ps
docker compose logs -f n8n
```

## Configuracao do .env

| Variavel | Descricao | Exemplo |
|----------|-----------|---------|
| N8N_VERSION | Versao do n8n | 2.3.4 |
| N8N_HOST | Dominio de acesso | n8n.empresa.com.br |
| N8N_PROTOCOL | http ou https | https |
| WEBHOOK_URL | URL para webhooks | https://n8n.empresa.com.br |
| N8N_ENCRYPTION_KEY | Chave 32 chars | (gerar com openssl) |
| POSTGRES_PASSWORD | Senha do banco | (senha forte) |
| REDIS_PASSWORD | Senha do Redis | (senha forte) |

## Comandos Uteis

```bash
# Ver logs
docker compose logs -f n8n
docker compose logs -f n8n-worker-1
docker compose logs -f watchtower

# Verificar healthchecks
docker ps --format "table {{.Names}}\t{{.Status}}"

# Reiniciar n8n (mantendo banco)
docker compose restart n8n n8n-worker-1 n8n-worker-2

# Parar tudo
docker compose down

# Forcar atualizacao manual (sem esperar domingo)
docker exec n8n-watchtower /watchtower --run-once

# Backup do banco
docker exec n8n-postgres pg_dump -U n8n n8n > backup.sql

# Restore do banco
cat backup.sql | docker exec -i n8n-postgres psql -U n8n n8n
```

## Escalando Workers

Para adicionar mais workers, copie o bloco do worker-2 e altere:
- `container_name: n8n-worker-3`
- `QUEUE_WORKER_ID: worker-3`
- `com.aiknow.worker-id=3`

## Limites de Recursos

| Servico | Memoria |
|---------|---------|
| postgres | 1 GB |
| redis | 512 MB |
| n8n | 2 GB |
| workers | 1 GB cada |
| watchtower | - |

## Acesso

- **URL:** https://seu-dominio.com.br (via Tailscale Funnel ou proxy)
- **Porta local:** :5678

## Troubleshooting

### n8n nao inicia
```bash
# Verificar se postgres esta healthy
docker compose ps
docker compose logs postgres
```

### Workers nao processam
```bash
# Verificar conexao com Redis
docker compose logs redis
docker exec n8n-redis redis-cli -a $REDIS_PASSWORD ping
```

### Container unhealthy
```bash
# Ver detalhes do healthcheck
docker inspect --format='{{json .State.Health}}' n8n | jq

# Forcar reinicio
docker compose restart nome_servico
```

### Watchtower nao atualiza
```bash
# Ver logs do watchtower
docker compose logs watchtower

# Verificar labels
docker inspect n8n | jq '.[0].Config.Labels'

# Executar atualizacao manual
docker exec n8n-watchtower /watchtower --run-once --debug
```

## Links

- [Documentacao n8n](https://docs.n8n.io/)
- [n8n Releases](https://github.com/n8n-io/n8n/releases)
- [n8n Community](https://community.n8n.io/)
- [Watchtower Docs](https://containrrr.dev/watchtower/)

## Fontes

- [n8n Release Notes](https://docs.n8n.io/release-notes/)
- [n8n Docker Hub](https://hub.docker.com/r/n8nio/n8n)
