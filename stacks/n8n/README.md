# n8n - Workflow Automation

Stack completa do n8n com PostgreSQL, Redis e Workers para processamento em fila.

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
```

## Componentes

| Servico | Imagem | Funcao |
|---------|--------|--------|
| postgres | postgres:16-alpine | Banco de dados principal |
| redis | redis:7-alpine | Gerenciamento de filas |
| n8n | n8n:1.73.1 | Interface web + webhooks |
| n8n-worker-1 | n8n:1.73.1 | Processamento paralelo |
| n8n-worker-2 | n8n:1.73.1 | Processamento paralelo |

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

# Reiniciar n8n (mantendo banco)
docker compose restart n8n n8n-worker-1 n8n-worker-2

# Parar tudo
docker compose down

# Atualizar n8n (editar versao no compose primeiro)
docker compose pull
docker compose up -d

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

## Acesso

- **URL:** https://seu-dominio.com.br (via Tailscale Funnel ou proxy)
- **Porta local:** 127.0.0.1:5678

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

### Erro de permissao
```bash
# Verificar owner do volume
docker volume inspect n8n_data
```

## Links

- [Documentacao n8n](https://docs.n8n.io/)
- [n8n Community](https://community.n8n.io/)
