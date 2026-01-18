# CLAUDE.md - Docker Compose Templates

Este arquivo fornece contexto para o Claude Code ao trabalhar neste repositorio.

## Visao Geral do Projeto

**Docker Compose Templates** e um repositorio de arquivos docker-compose.yml padronizados para deploy de aplicacoes. Desenvolvido para facilitar o trabalho de analistas de suporte.

- **Autor:** Mark - Aiknow Systems
- **Publico-alvo:** Analistas Junior de Suporte/Infraestrutura
- **Foco:** Templates prontos para producao com boas praticas

## Requisitos Obrigatorios para TODA Stack

Toda stack criada neste repositorio DEVE atender aos seguintes requisitos:

### 1. Network Externa `llmserver`
```yaml
networks:
  llmserver:
    external: true
```
- Permite comunicacao entre containers de diferentes stacks
- Ex: n8n acessa Ollama via `http://ollama:11434`

### 2. Atualizacao Automatica (Watchtower)
- Toda stack DEVE incluir Watchtower
- Schedule: Domingo as 22:00
- Nao requer intervencao manual para atualizar

### 3. Backup Automatico (Restic)
- Toda stack DEVE incluir servico de backup
- Backup incremental para destino remoto
- Restauracao em caso de perda do servidor

### 4. Versao Estavel
- Sempre usar versao estavel mais recente
- Pesquisar antes de definir a versao
- Nunca usar tag `latest` (exceto watchtower)

### 5. Suporte Tailscale
- Todos os servicos devem ser acessiveis via Tailscale
- Suporte a Tailscale Funnel (exposicao publica)
- Suporte a `tailscale serve --bg` (proxy local)
- Portas expostas apenas em 127.0.0.1

### 6. Arquivos Obrigatorios
- `docker-compose.yml` - Compose principal
- `.env.example` - Variaveis de ambiente (sem senhas)
- `README.md` - Documentacao da stack
- `.gitignore` - Ignorar .env com senhas

## Estrutura do Projeto

```
compose/
├── CLAUDE.md                    # Contexto para Claude Code
├── README.md                    # Documentacao principal
├── .gitignore                   # Arquivos ignorados
├── stacks/                      # Stacks completas de aplicacoes
│   ├── n8n/                     # Automacao
│   │   ├── docker-compose.yml
│   │   ├── .env.example
│   │   └── README.md
│   ├── ollama/                  # IA Local
│   └── [outras stacks]/
└── templates/                   # Templates base (futuro)
```

## Padrao de Compose Files

### Estrutura Obrigatoria Completa

```yaml
################################################################################
# Stack: nome-da-stack
# Descricao: Descricao clara do que a stack faz
# Autor: Mark - Aiknow Systems
# Data: YYYY-MM-DD
# Versao: X.Y
#
# Requisitos:
#   - Docker Engine 24+
#   - Docker Compose v2
#   - Network externa: llmserver
#   - Tailscale instalado no host
#
# Portas Expostas:
#   - XXXX: Servico principal (127.0.0.1 apenas)
#
# Tailscale:
#   - Funnel: tailscale funnel 443 http://localhost:XXXX
#   - Serve: tailscale serve --bg http://localhost:XXXX
#
# Backup:
#   - Volumes: lista de volumes com backup
#   - Destino: configurar em RESTIC_REPOSITORY
#   - Schedule: diario as 03:00
################################################################################

# YAML Anchors - Configuracoes reutilizaveis
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

services:
  # ==========================================================================
  # Servico Principal
  # ==========================================================================
  app:
    image: imagem:versao-estavel
    container_name: stack-app
    <<: *common
    environment:
      TZ: ${GENERIC_TIMEZONE:-America/Sao_Paulo}
    ports:
      - "127.0.0.1:${APP_PORT}:8080"  # Apenas localhost para Tailscale
    volumes:
      - app_data:/data
    healthcheck:
      test: ["CMD-SHELL", "wget --spider -q http://localhost:8080/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    deploy:
      resources:
        limits:
          memory: 2G
    labels:
      - "com.aiknow.project=stack"
      - "com.aiknow.service=app"
      - "com.aiknow.maintainer=mark@aiknow.systems"
      - "com.centurylinklabs.watchtower.enable=true"
      - "autoheal=true"

  # ==========================================================================
  # Watchtower - Atualizacao Automatica (OBRIGATORIO)
  # ==========================================================================
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
      - "com.aiknow.project=stack"
      - "com.aiknow.service=watchtower"

  # ==========================================================================
  # Backup - Restic (OBRIGATORIO)
  # ==========================================================================
  backup:
    image: mazzolino/restic:latest
    container_name: stack-backup
    restart: unless-stopped
    environment:
      TZ: ${GENERIC_TIMEZONE:-America/Sao_Paulo}
      # Destino do backup (configurar no .env)
      RESTIC_REPOSITORY: ${RESTIC_REPOSITORY}
      RESTIC_PASSWORD: ${RESTIC_PASSWORD}
      # Credenciais S3/B2/etc (se aplicavel)
      AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID:-}
      AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY:-}
      # Schedule: diario as 03:00
      BACKUP_CRON: "0 3 * * *"
      # Retencao
      RESTIC_FORGET_ARGS: "--keep-daily 7 --keep-weekly 4 --keep-monthly 6"
      # Pre-backup hooks (opcional - para dump de banco)
      PRE_COMMANDS: |-
        echo "Iniciando backup..."
      POST_COMMANDS: |-
        echo "Backup concluido!"
    volumes:
      # Volumes para backup (adicionar todos os volumes da stack)
      - app_data:/data/app_data:ro
      # Socket Docker para comandos pre/post
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - llmserver
    logging:
      <<: *default-logging
    security_opt:
      - no-new-privileges:true
    labels:
      - "com.aiknow.project=stack"
      - "com.aiknow.service=backup"

networks:
  llmserver:
    external: true

volumes:
  app_data:
    name: stack_app_data
```

## Convencoes de Nomenclatura

| Elemento | Padrao | Exemplo |
|----------|--------|---------|
| Container | `stack-servico` | `n8n-postgres` |
| Network | `llmserver` (externa) | `llmserver` |
| Volume | `stack_servico_data` | `n8n_postgres_data` |
| Variavel | `SERVICO_CONFIG` | `N8N_PORT` |

## Labels Obrigatorias

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

## Tailscale - Configuracao

### Exposicao via Funnel (Publico)

```bash
# Expor servico publicamente
tailscale funnel 443 http://localhost:${APP_PORT}

# Verificar status
tailscale funnel status
```

### Exposicao via Serve (Rede Tailscale)

```bash
# Expor apenas na rede Tailscale
tailscale serve --bg http://localhost:${APP_PORT}

# Com HTTPS
tailscale serve --bg --https=443 http://localhost:${APP_PORT}

# Verificar status
tailscale serve status
```

### Padrao de Portas

Todas as portas DEVEM ser expostas apenas em `127.0.0.1`:

```yaml
ports:
  - "127.0.0.1:${APP_PORT}:8080"  # CORRETO
  # - "${APP_PORT}:8080"          # ERRADO - expoe para todos
```

## Backup - Configuracao

### Destinos Suportados (Restic)

| Destino | RESTIC_REPOSITORY |
|---------|-------------------|
| Local | `/backups` |
| S3 | `s3:s3.amazonaws.com/bucket` |
| B2 | `b2:bucket:path` |
| SFTP | `sftp:user@host:/path` |
| Rclone | `rclone:remote:path` |

### Variaveis de Ambiente (.env)

```bash
# Backup - Restic
RESTIC_REPOSITORY=s3:s3.amazonaws.com/meu-bucket/backups
RESTIC_PASSWORD=senha_forte_para_criptografia

# Credenciais S3 (se usar S3/B2)
AWS_ACCESS_KEY_ID=sua_access_key
AWS_SECRET_ACCESS_KEY=sua_secret_key
```

### Backup de Banco de Dados

Para bancos de dados, usar PRE_COMMANDS para dump:

```yaml
backup:
  environment:
    PRE_COMMANDS: |-
      # Dump PostgreSQL antes do backup
      docker exec stack-postgres pg_dump -U user db > /data/postgres_dump.sql
```

### Restauracao

```bash
# Listar snapshots
docker exec stack-backup restic snapshots

# Restaurar ultimo snapshot
docker exec stack-backup restic restore latest --target /restore

# Restaurar snapshot especifico
docker exec stack-backup restic restore abc123 --target /restore
```

## Healthchecks - Por Tipo de Servico

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
```

## Limites de Recursos

```yaml
deploy:
  resources:
    limits:
      memory: 1G
```

| Tipo | Memoria Recomendada |
|------|---------------------|
| Banco de dados | 1G |
| Cache (Redis) | 512M |
| Aplicacao web | 2G |
| Workers | 1G |
| IA/LLM | 8G+ |

## Arquivo .env.example (Template)

```bash
################################################################################
# Stack: nome-stack
# Descricao: Variaveis de ambiente
#
# INSTRUCOES:
#   1. Copie: cp .env.example .env
#   2. Edite com seus valores
#   3. NUNCA commite .env com senhas reais
################################################################################

# ==============================================================================
# GERAL
# ==============================================================================
COMPOSE_PROJECT_NAME=nome_stack
GENERIC_TIMEZONE=America/Sao_Paulo

# Versao da aplicacao (consultar release notes)
APP_VERSION=1.0.0

# ==============================================================================
# REDE / ACESSO
# ==============================================================================
# Porta local (Tailscale fara o proxy)
APP_PORT=25000

# Dominio Tailscale (para webhooks)
# Obter com: tailscale status --json | jq -r '.Self.DNSName'
TAILSCALE_DOMAIN=seu-servidor.tailnet-xxx.ts.net

# ==============================================================================
# CREDENCIAIS
# ==============================================================================
# Gerar com: openssl rand -hex 32
SECRET_KEY=changeme

# Banco de dados
DB_PASSWORD=changeme

# ==============================================================================
# BACKUP - RESTIC
# ==============================================================================
# Destino: s3:bucket, b2:bucket, sftp:user@host:/path, /local/path
RESTIC_REPOSITORY=s3:s3.amazonaws.com/seu-bucket/backups

# Senha para criptografia do backup (gerar com: openssl rand -base64 32)
RESTIC_PASSWORD=changeme

# Credenciais S3/B2 (se aplicavel)
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=

# ==============================================================================
# PRE-REQUISITOS
# ==============================================================================
# Antes de subir a stack:
#
# 1. Criar network:
#    docker network create llmserver
#
# 2. Inicializar repositorio Restic:
#    docker run --rm -e RESTIC_REPOSITORY=... -e RESTIC_PASSWORD=... \
#      mazzolino/restic restic init
#
# 3. Configurar Tailscale:
#    tailscale up
#    tailscale funnel 443 http://localhost:${APP_PORT}
################################################################################
```

## Fluxo de Trabalho Obrigatorio

### Ao Criar Nova Stack

1. **Pesquisar versao estavel** da aplicacao
2. **Criar diretorio** `stacks/nome-stack/`
3. **Criar docker-compose.yml** com:
   - Cabecalho completo
   - Servico principal com versao estavel
   - Watchtower (obrigatorio)
   - Backup Restic (obrigatorio)
   - Network llmserver (externa)
   - Healthchecks em todos os containers
   - Labels completas
   - Portas em 127.0.0.1 (para Tailscale)
4. **Criar .env.example** com todas as variaveis
5. **Criar README.md** com:
   - Descricao e arquitetura
   - Pre-requisitos
   - Instrucoes de instalacao
   - Configuracao Tailscale
   - Comandos de backup/restore
6. **Validar sintaxe**: `docker compose config`
7. **Atualizar README.md principal**
8. **Atualizar CLAUDE.md** (estatisticas)
9. **Commit e push**

## Checklist de Stack

- [ ] Versao estavel pesquisada e definida
- [ ] Cabecalho completo com metadados
- [ ] Network llmserver (external: true)
- [ ] Portas em 127.0.0.1 apenas
- [ ] Watchtower incluso
- [ ] Backup Restic incluso
- [ ] Healthcheck em TODOS os containers
- [ ] Labels Aiknow + Watchtower + Autoheal
- [ ] Logging configurado
- [ ] Limites de memoria definidos
- [ ] security_opt: no-new-privileges
- [ ] .env.example completo
- [ ] README.md com Tailscale e backup
- [ ] goss.yaml criado (testes)
- [ ] goss_wait.yaml criado
- [ ] run_tests.sh criado
- [ ] Sintaxe validada (`docker compose config`)
- [ ] CLAUDE.md atualizado
- [ ] Commit e push

## Stacks Existentes

### n8n (v1.1)

**Descricao:** Workflow automation com PostgreSQL, Redis e Workers.

**Componentes:**
- PostgreSQL 16, Redis 7, n8n 2.3.4
- 2 Workers, Watchtower
- (Backup Restic a adicionar)

**Tailscale:**
```bash
tailscale funnel 443 http://localhost:5678
```

## Estatisticas

| Metrica | Valor |
|---------|-------|
| Stacks | 1 |
| Inicio | 2026-01-18 |
| Ultima atualizacao | 2026-01-18 |

## Testes com Goss/dcgoss

Toda stack DEVE incluir testes para validar que os servicos estao funcionando.

### Estrutura de Testes

```
stacks/nome-stack/
├── docker-compose.yml
├── .env.example
├── README.md
├── goss.yaml           # Testes principais
├── goss_wait.yaml      # Aguardar servicos
└── run_tests.sh        # Script de execucao
```

### Instalacao do dcgoss

```bash
# Instalar goss + dcgoss
curl -fsSL https://goss.rocks/install | sh
```

### Executar Testes

```bash
cd stacks/nome-stack

# Subir stack
docker compose up -d

# Executar testes
./run_tests.sh

# Ou via dcgoss diretamente
dcgoss run nome-container
```

### Template goss.yaml

```yaml
# Portas
port:
  tcp:8080:
    listening: true

# Endpoints HTTP
http:
  http://localhost:8080/health:
    status: 200
    timeout: 10000

# Processos
process:
  node:
    running: true

# DNS (resolucao na rede)
dns:
  postgres:
    resolvable: true

# Comandos
command:
  "app --version":
    exit-status: 0
    timeout: 10000

# Arquivos
file:
  /data:
    exists: true
    filetype: directory
```

### Template goss_wait.yaml

```yaml
# Aguardar portas abrirem antes dos testes
port:
  tcp:8080:
    listening: true

http:
  http://localhost:8080/health:
    status: 200
    timeout: 30000
```

## Dicas para Claude

1. **Pesquisar versao** - Sempre buscar versao estavel antes de criar stack
2. **Network llmserver** - OBRIGATORIO em toda stack
3. **Watchtower** - OBRIGATORIO em toda stack
4. **Backup Restic** - OBRIGATORIO em toda stack
5. **Tailscale** - Portas em 127.0.0.1, documentar Funnel/Serve
6. **Healthchecks** - TODOS os containers
7. **.env.example** - OBRIGATORIO, sem senhas reais
8. **.gitignore** - Verificar se existe no projeto
9. **Validar sintaxe** - `docker compose config` antes de commit
10. **README completo** - Incluir Tailscale e backup
11. **Testes Goss** - OBRIGATORIO em toda stack

## Referencias

- [Goss Documentation](https://goss.readthedocs.io/)
- [dcgoss - Docker Compose](https://goss.readthedocs.io/en/stable/containers/docker-compose/)
- [Restic Documentation](https://restic.readthedocs.io/)
- [Watchtower Documentation](https://containrrr.dev/watchtower/)
- [Tailscale Funnel](https://tailscale.com/kb/1223/funnel)
- [Tailscale Serve](https://tailscale.com/kb/1242/tailscale-serve)

### 10. Design para Testabilidade
Para que os testes unitarios funcionem:
- **Guard:** Todo script deve terminar com o bloco condicional `if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main "$@"; fi`.
- **Independencia:** Funcoes como `configure_env` devem ser puras e testaveis via `source`.
