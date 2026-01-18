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
#   - [Outros requisitos]
#
# Portas Expostas:
#   - XXXX: Servico principal
#   - YYYY: Admin/API
################################################################################

services:
  nome_servico:
    image: imagem:tag
    container_name: nome_container
    restart: unless-stopped
    # ... configuracoes ...

networks:
  default:
    name: stack_network

volumes:
  dados:
    name: stack_dados
```

### Convencoes de Nomenclatura

| Elemento | Padrao | Exemplo |
|----------|--------|---------|
| Arquivo | `docker-compose.yml` | `docker-compose.yml` |
| Container | `stack_servico` | `n8n_app` |
| Network | `stack_network` | `n8n_network` |
| Volume | `stack_dados` | `n8n_dados` |
| Variavel | `STACK_VARIAVEL` | `N8N_PORT` |

### Labels Obrigatorias

```yaml
labels:
  - "com.aiknow.project=nome-stack"
  - "com.aiknow.maintainer=mark@aiknow.systems"
  - "com.aiknow.version=1.0"
```

## Boas Praticas

### 1. Sempre Usar

- **Versao de imagem fixa** - Nunca usar `latest` em producao
- **restart: unless-stopped** - Garantir resiliencia
- **healthcheck** - Monitorar saude do container
- **logging** - Configurar rotacao de logs
- **networks explicitas** - Isolar comunicacao
- **volumes nomeados** - Persistencia de dados

### 2. Evitar

- Portas hardcoded (usar variaveis)
- Senhas em texto plano (usar secrets ou .env)
- Bind mounts para dados criticos
- Privileged mode (exceto quando necessario)
- Host network mode (preferir bridge)

### 3. Seguranca

```yaml
# Exemplo de configuracao segura
services:
  app:
    security_opt:
      - no-new-privileges:true
    read_only: true
    tmpfs:
      - /tmp
    user: "1000:1000"
```

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
TZ=America/Sao_Paulo

# Rede
DOMAIN=exemplo.com.br
SUBNET=172.20.0.0/16

# Portas (Range: 15000-35000)
APP_PORT=25000
ADMIN_PORT=25001

# Credenciais (NUNCA commitar valores reais)
DB_PASSWORD=changeme
ADMIN_PASSWORD=changeme

# Recursos
MEMORY_LIMIT=2g
CPU_LIMIT=1.0
```

### Padrao de Portas

| Range | Uso |
|-------|-----|
| 15000-20000 | Aplicacoes web |
| 20001-25000 | APIs e backends |
| 25001-30000 | Bancos de dados |
| 30001-35000 | Monitoramento |

## Healthchecks

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

## Logging

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
    labels: "service"
```

## Redes

### Rede Interna Padrao

```yaml
networks:
  internal:
    driver: bridge
    internal: true

  external:
    driver: bridge
```

### Com Traefik

```yaml
networks:
  traefik_proxy:
    external: true
```

## Comandos Uteis

```bash
# Subir stack
docker compose up -d

# Ver logs
docker compose logs -f [servico]

# Parar stack
docker compose down

# Remover tudo (incluindo volumes)
docker compose down -v

# Atualizar imagens
docker compose pull && docker compose up -d

# Verificar status
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
# 2. Criar docker-compose.yml com cabecalho
# 3. Criar .env.example (sem valores sensiveis)
# 4. Criar README.md da stack
# 5. Testar localmente: docker compose config
# 6. Atualizar README.md principal
# 7. Commit com mensagem descritiva
# 8. Push para repositorio
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
- [ ] Versao de imagem fixa (nao usar latest)
- [ ] restart: unless-stopped
- [ ] Healthcheck configurado
- [ ] Logging configurado
- [ ] Networks explicitas
- [ ] Volumes nomeados
- [ ] Labels de identificacao
- [ ] .env.example criado
- [ ] README.md da stack criado
- [ ] Sintaxe validada (`docker compose config`)
- [ ] README.md principal atualizado
- [ ] Commit realizado
- [ ] Push para repositorio

## Stacks Existentes

*(Sera atualizado conforme novas stacks forem adicionadas)*

## Estatisticas do Projeto

| Metrica | Valor |
|---------|-------|
| Stacks | 0 |
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
7. **Portas** - Usar range 15000-35000
8. **Versoes fixas** - Nunca usar tag `latest`
9. **Minimo necessario** - Nao adicionar servicos alem do solicitado
10. **Labels** - Sempre incluir labels de identificacao
