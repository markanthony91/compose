# Docker Compose Templates

Repositorio de templates docker-compose.yml padronizados para deploy de aplicacoes.

## Sobre

Este repositorio contem stacks Docker Compose prontas para producao, seguindo boas praticas de seguranca e organizacao.

**Autor:** Mark - Aiknow Systems

## Estrutura

```
compose/
├── templates/      # Templates base reutilizaveis
├── stacks/         # Stacks completas de aplicacoes
└── examples/       # Exemplos de configuracao
```

## Uso Rapido

```bash
# Clonar repositorio
git clone https://github.com/mairinkdev/compose.git
cd compose

# Escolher uma stack
cd stacks/nome-stack

# Copiar e configurar .env
cp .env.example .env
nano .env

# Subir stack
docker compose up -d
```

## Stacks Disponiveis

| Stack | Descricao | Porta |
|-------|-----------|-------|
| *(em breve)* | | |

## Requisitos

- Docker Engine 24+
- Docker Compose v2
- Linux (Ubuntu 22.04+ recomendado)

## Padrao de Portas

| Range | Uso |
|-------|-----|
| 15000-20000 | Aplicacoes web |
| 20001-25000 | APIs e backends |
| 25001-30000 | Bancos de dados |
| 30001-35000 | Monitoramento |

## Contribuindo

1. Seguir padroes do `CLAUDE.md`
2. Validar sintaxe: `docker compose config`
3. Nunca commitar senhas reais
4. Documentar cada stack

## Licenca

MIT
