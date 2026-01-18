# CLAUDE.md - Docker Compose Templates

Este arquivo fornece contexto para o Claude Code ao trabalhar neste repositorio.

## Visao Geral do Projeto

**Docker Compose Templates** e um repositorio de arquivos docker-compose.yml padronizados para deploy de aplicacoes. Desenvolvido para facilitar o trabalho de analistas de suporte.

- **Autor:** Mark - Aiknow Systems
- **Publico-alvo:** Analistas Junior de Suporte/Infraestrutura
- **Foco:** Templates prontos para producao com boas praticas

## Estrutura do Projeto

```
compose/
├── CLAUDE.md                    # Contexto para Claude Code
├── README.md                    # Documentacao principal
├── templates/                   # Templates base reutilizaveis
│   ├── traefik/                 # Proxy reverso
│   ├── portainer/               # Gerenciamento Docker
│   └── monitoring/              # Prometheus + Grafana
├── stacks/                      # Stacks completas de aplicacoes
│   ├── n8n/                     # Automacao
│   ├── ollama/                  # IA Local
│   └── nextcloud/               # Cloud pessoal
└── examples/                    # Exemplos de configuracao
    └── .env.example
```

## Padrao de Compose Files

### Estrutura Obrigatoria

Todo docker-compose.yml deve seguir esta estrutura:

```yaml
################################################################################
# Stack: nome-da-stack
# Descricao: Descricao clara do que a stack faz
# Autor: [Nome] - [Empresa]
# Data: YYYY-MM-DD
# Versao: X.Y
#
# Requisitos:
#   - Docker Engine 24+
#   - Docker Compose v2
#   - Network externa: llmserver
#   - [Outros requisitos]
#
# Portas Expostas:
#   - XXXX: Servico principal
#   - YYYY: Admin/API
#
# Healthchecks:
#   - Todos os containers possuem healthcheck
#   - Autoheal pode reiniciar containers unhealthy
################################################################################

# YAML Anchors - Configuracoes reutilizaveis (opcional)
x-common: &common
  restart: unless-stopped
  logging: &default-logging
    driver: "json-file"
    options:
      max-size: "10m"
      max-file: "3"
  security_opt:
    - no-new-privileges:true

services:
  nome_servico:
    image: imagem:tag-fixa
    container_name: stack-servico
    <<: *common
    environment:
      TZ: ${GENERIC_TIMEZONE:-America/Sao_Paulo}
    networks:
      - llmserver
    healthcheck:
      test: ["CMD", "comando", "de", "teste"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
    deploy:
      resources:
        limits:
          memory: 1G
    labels:
      - "com.aiknow.project=nome-stack"
      - "com.aiknow.service=nome-servico"
      - "com.aiknow.maintainer=mark@aiknow.systems"
      - "com.centurylinklabs.watchtower.enable=true"
      - "autoheal=true"

  # Watchtower - Atualizacao Automatica (obrigatorio em toda stack)
  watchtower:
    image: containrrr/watchtower:latest
    container_name: stack-watchtower
    restart: unless-stopped
    environment:
      TZ: ${GENERIC_TIMEZONE:-America/Sao_Paulo}
      WATCHTOWER_LABEL_ENABLE: "true"
      WATCHTOWER_SCHEDULE: "0 0 22 * * 0"  # Domingo 22:00
      WATCHTOWER_CLEANUP: "true"
      WATCHTOWER_INCLUDE_STOPPED: "true"
      WATCHTOWER_REVIVE_STOPPED: "true"
      WATCHTOWER_TIMEOUT: 300s
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - llmserver
    logging:
      <<: *default-logging
    security_opt:
      - no-new-privileges:true
    healthcheck:
      test: ["CMD", "/watchtower", "--health-check"]
      interval: 60s
      timeout: 10s
      retries: 3
      start_period: 10s
    labels:
      - "com.aiknow.project=nome-stack"
      - "com.aiknow.service=watchtower"

networks:
  llmserver:
    external: true

volumes:
  dados:
    name: stack_dados
```

### Convencoes de Nomenclatura

| Elemento | Padrao | Exemplo |
|----------|--------|---------|
| Arquivo | `docker-compose.yml` | `docker-compose.yml` |
| Container | `stack-servico` | `n8n-postgres` |
| Network | `llmserver` (externa) | `llmserver` |
| Volume | `stack_dados` | `n8n_postgres_data` |
| Variavel | `STACK_VARIAVEL` | `N8N_PORT` |

### Labels Obrigatorias

```yaml
labels:
  # Identificacao Aiknow
  - "com.aiknow.project=nome-stack"
  - "com.aiknow.service=nome-servico"
  - "com.aiknow.maintainer=mark@aiknow.systems"
  # Watchtower - Atualizacao automatica
  - "com.centurylinklabs.watchtower.enable=true"
  # Autoheal - Reinicio automatico se unhealthy
  - "autoheal=true"
```

### YAML Anchors (Padrao)

Use anchors para evitar duplicacao:

```yaml
# Definir anchor
x-common: &common
  restart: unless-stopped
  networks:
    - llmserver
  logging: &default-logging
    driver: "json-file"
    options:
      max-size: "10m"
      max-file: "3"
  security_opt:
    - no-new-privileges:true

# Usar anchor
services:
  app:
    <<: *common
    image: app:1.0
```

## Boas Praticas

### 1. Sempre Usar

- **Versao de imagem fixa** - Nunca usar `latest` em producao (exceto watchtower)
- **restart: unless-stopped** - Garantir resiliencia
- **healthcheck** - Monitorar saude do container
- **logging** - Configurar rotacao de logs (10m, 3 arquivos)
- **network llmserver** - Rede externa compartilhada
- **volumes nomeados** - Persistencia de dados
- **security_opt: no-new-privileges** - Seguranca
- **deploy.resources.limits** - Limites de memoria
- **Watchtower** - Atualizacao automatica semanal
- **Labels** - Identificacao e integracao com Autoheal

### 2. Evitar

- Portas hardcoded (usar variaveis)
- Senhas em texto plano (usar secrets ou .env)
- Bind mounts para dados criticos
- Privileged mode (exceto quando necessario)
- Host network mode (preferir bridge)
- Tag `latest` (exceto watchtower)

### 3. Seguranca

```yaml
services:
  app:
    security_opt:
      - no-new-privileges:true
    read_only: true  # quando possivel
    tmpfs:
      - /tmp
    user: "1000:1000"  # quando possivel
```

## Network Padrao

Todas as stacks usam a network externa `llmserver`:

```yaml
networks:
  llmserver:
    external: true
```

### Pre-requisito

```bash
docker network create llmserver
```

### Beneficios

- Containers de diferentes stacks se comunicam
- Ex: n8n acessa Ollama via `http://ollama:11434`
- Isolamento do host mantido

## Variaveis de Ambiente

### Arquivo .env Padrao

```bash
# .env
################################################################################
# Stack: nome-stack
# Descricao: Variaveis de ambiente para a stack
################################################################################

# Geral
COMPOSE_PROJECT_NAME=nome_stack
GENERIC_TIMEZONE=America/Sao_Paulo

# Versao da aplicacao principal
APP_VERSION=1.0.0

# Rede
DOMAIN=exemplo.com.br

# Portas (Range: 15000-35000)
APP_PORT=25000

# Credenciais (NUNCA commitar valores reais)
DB_PASSWORD=changeme
ADMIN_PASSWORD=changeme

# Recursos
MEMORY_LIMIT=2g
```

### Padrao de Portas

| Range | Uso |
|-------|-----|
| 15000-20000 | Aplicacoes web |
| 20001-25000 | APIs e backends |
| 25001-30000 | Bancos de dados |
| 30001-35000 | Monitoramento |

## Healthchecks

### Padrao por Tipo de Servico

```yaml
# Web/API
healthcheck:
  test: ["CMD-SHELL", "wget --spider -q http://localhost:8080/health || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s

# PostgreSQL
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
  interval: 10s
  timeout: 5s
  retries: 5
  start_period: 10s

# Redis
healthcheck:
  test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]
  interval: 10s
  timeout: 5s
  retries: 5
  start_period: 5s

# Worker/Background
healthcheck:
  test: ["CMD-SHELL", "pgrep -f 'processo' || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 30s

# Watchtower
healthcheck:
  test: ["CMD", "/watchtower", "--health-check"]
  interval: 60s
  timeout: 10s
  retries: 3
  start_period: 10s
```

## Logging

```yaml
logging: &default-logging
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

## Watchtower (Obrigatorio)

Toda stack deve incluir Watchtower para atualizacao automatica:

```yaml
watchtower:
  image: containrrr/watchtower:latest
  container_name: stack-watchtower
  restart: unless-stopped
  environment:
    TZ: ${GENERIC_TIMEZONE:-America/Sao_Paulo}
    WATCHTOWER_LABEL_ENABLE: "true"
    WATCHTOWER_SCHEDULE: "0 0 22 * * 0"  # Domingo 22:00
    WATCHTOWER_CLEANUP: "true"
    WATCHTOWER_INCLUDE_STOPPED: "true"
    WATCHTOWER_REVIVE_STOPPED: "true"
    WATCHTOWER_TIMEOUT: 300s
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock:ro
  networks:
    - llmserver
```

### Forcar Atualizacao Manual

```bash
docker exec stack-watchtower /watchtower --run-once
```

## Limites de Recursos

```yaml
deploy:
  resources:
    limits:
      memory: 1G
      # cpus: "1.0"  # opcional
```

### Recomendacoes

| Tipo | Memoria |
|------|---------|
| Banco de dados | 1G |
| Cache (Redis) | 512M |
| Aplicacao web | 2G |
| Workers | 1G |

## Comandos Uteis

```bash
# Subir stack
docker compose up -d

# Ver logs
docker compose logs -f [servico]

# Verificar healthchecks
docker ps --format "table {{.Names}}\t{{.Status}}"

# Parar stack
docker compose down

# Remover tudo (incluindo volumes)
docker compose down -v

# Atualizar imagens manualmente
docker compose pull && docker compose up -d

# Forcar atualizacao via Watchtower
docker exec stack-watchtower /watchtower --run-once

# Verificar status detalhado
docker compose ps
```

## Fluxo de Trabalho Git

### Commits

```bash
# Padrao de commits (Conventional Commits)
feat: nova stack para n8n
fix: correcao de porta no traefik
docs: atualizacao do README
refactor: reorganizacao de networks
```

### Branches

```bash
main    # Producao - stacks testadas e aprovadas
```

## Fluxo de Trabalho Obrigatorio para Claude

### 1. Ao Criar Nova Stack

```bash
# 1. Criar diretorio da stack
# 2. Criar docker-compose.yml com:
#    - Cabecalho completo
#    - YAML Anchors para reducao de duplicacao
#    - Todos os healthchecks
#    - Watchtower incluso
#    - Network llmserver (externa)
#    - Labels completas
# 3. Criar .env.example (sem valores sensiveis)
# 4. Criar README.md da stack
# 5. Validar sintaxe: docker compose config
# 6. Atualizar README.md principal
# 7. Atualizar CLAUDE.md (estatisticas e stacks)
# 8. Commit com mensagem descritiva
# 9. Push para repositorio
```

### 2. Ao Editar Stack Existente

```bash
# 1. Ler docker-compose.yml completo
# 2. Atualizar versao e data no cabecalho
# 3. Validar sintaxe: docker compose config
# 4. Atualizar .env.example se necessario
# 5. Atualizar README.md se necessario
# 6. Commit e push
```

## Checklist de Stack

Antes de finalizar qualquer stack:

- [ ] Cabecalho completo com metadados
- [ ] YAML Anchors para configuracoes comuns
- [ ] Versao de imagem fixa (nao usar latest)
- [ ] restart: unless-stopped
- [ ] Healthcheck em TODOS os containers
- [ ] Logging configurado (10m, 3 arquivos)
- [ ] Network llmserver (externa)
- [ ] Volumes nomeados
- [ ] security_opt: no-new-privileges
- [ ] deploy.resources.limits (memoria)
- [ ] Labels Aiknow
- [ ] Labels Watchtower e Autoheal
- [ ] Watchtower incluso na stack
- [ ] .env.example criado
- [ ] README.md da stack criado
- [ ] Sintaxe validada (`docker compose config`)
- [ ] README.md principal atualizado
- [ ] CLAUDE.md atualizado
- [ ] Commit realizado
- [ ] Push para repositorio

## Stacks Existentes

### n8n (v1.1)

**Descricao:** Workflow automation com PostgreSQL, Redis e Workers.

**Componentes:**
- PostgreSQL 16 (banco de dados)
- Redis 7 (gerenciamento de filas)
- n8n 2.3.4 (interface principal)
- 2 Workers (processamento paralelo)
- Watchtower (atualizacao automatica)

**Recursos:**
- YAML Anchors para reduzir duplicacao
- Queue mode com Redis
- Healthchecks em todos os servicos
- Limites de memoria configurados
- Labels Aiknow + Watchtower + Autoheal
- Atualizacao automatica domingo 22:00

**Uso:**
```bash
cd stacks/n8n
cp .env.example .env
docker compose up -d
```

## Estatisticas do Projeto

| Metrica | Valor |
|---------|-------|
| Stacks | 1 |
| Templates | 0 |
| Inicio | 2026-01-18 |
| Ultima atualizacao | 2026-01-18 |

## Dicas para Claude

1. **Ler antes de editar** - Sempre ler o arquivo completo
2. **Manter padrao** - Seguir estrutura das stacks existentes
3. **Didatica** - Lembrar que o publico sao analistas junior
4. **Validar sintaxe** - `docker compose config` antes de commit
5. **Documentar** - README.md sempre atualizado
6. **Seguranca** - Nunca commitar senhas ou tokens reais
7. **Network** - Sempre usar llmserver (externa)
8. **Versoes fixas** - Nunca usar tag `latest` (exceto watchtower)
9. **Healthchecks** - Obrigatorio em TODOS os containers
10. **Watchtower** - Obrigatorio em TODA stack
11. **Labels** - Aiknow + Watchtower + Autoheal
12. **Limites** - Sempre definir deploy.resources.limits
13. **YAML Anchors** - Usar para evitar duplicacao
14. **Minimo necessario** - Nao adicionar servicos alem do solicitado
