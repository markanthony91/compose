#!/bin/bash
set -euo pipefail

# Cores
readonly GREEN='[0;32m'
readonly YELLOW='[1;33m'
readonly RED='[0;31m'
readonly NC='[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

check_requirements() {
    if ! docker network inspect llmserver &> /dev/null; then
        log_warn "Criando rede llmserver..."
        docker network create llmserver
    fi
}

configure_env() {
    log_info "Configuracao da Stack AI-Database"
    
    # 1. Postgres
    read -p "Porta Postgres [5432]: " DB_PORT
    DB_PORT=${DB_PORT:-5432}
    read -s -p "Senha Postgres: " DB_PASS
    echo ""

    # 2. Redis
    read -p "Porta Redis [6379]: " REDIS_PORT
    REDIS_PORT=${REDIS_PORT:-6379}
    read -s -p "Senha Redis: " REDIS_PASS
    echo ""

    # 3. pgAdmin
    read -p "Porta pgAdmin [5050]: " PGADMIN_PORT
    PGADMIN_PORT=${PGADMIN_PORT:-5050}
    read -p "Email pgAdmin: " PGADMIN_EMAIL
    read -s -p "Senha pgAdmin: " PGADMIN_PASS
    echo ""

    cat > .env << EOF
DB_PORT=$DB_PORT
DB_PASS=$DB_PASS
REDIS_PORT=$REDIS_PORT
REDIS_PASS=$REDIS_PASS
PGADMIN_PORT=$PGADMIN_PORT
PGADMIN_EMAIL=$PGADMIN_EMAIL
PGADMIN_PASS=$PGADMIN_PASS
EOF
    log_success "Arquivo .env configurado."
}

main() {
    check_requirements
    configure_env
    docker compose up -d
    log_info "Stack AI-Database pronta!"
    log_info "Acesse pgAdmin em: http://localhost:$PGADMIN_PORT"
}

main "$@"
