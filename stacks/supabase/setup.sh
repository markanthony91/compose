#!/bin/bash
set -euo pipefail

# Cores
readonly GREEN='[0;32m'
readonly YELLOW='[1;33m'
readonly RED='[0;31m'
readonly NC='[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }

check_requirements() {
    if ! docker network inspect llmserver &> /dev/null; then
        docker network create llmserver
    fi
}

generate_secrets() {
    log_info "Gerando chaves de seguranca exclusivas..."
    JWT_SECRET=$(openssl rand -hex 32)
    ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.$(openssl rand -hex 32)"
    SERVICE_ROLE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.$(openssl rand -hex 32)"
    DB_PASSWORD=$(openssl rand -hex 16)
}

configure_env() {
    log_info "Configurando Stack: supabase"
    
    # Porta do Dashboard Studio
    read -p "Porta do Dashboard Supabase [8000]: " STUDIO_PORT
    STUDIO_PORT=${STUDIO_PORT:-8000}

    cat > .env << EOF
# Supabase Secrets
POSTGRES_PASSWORD=$DB_PASSWORD
JWT_SECRET=$JWT_SECRET
ANON_KEY=$ANON_KEY
SERVICE_ROLE_KEY=$SERVICE_ROLE_KEY

# Ports
STUDIO_PORT=$STUDIO_PORT
KONG_HTTP_PORT=8001
KONG_HTTPS_PORT=8444

# Project Config
SITE_URL=http://localhost:$STUDIO_PORT
EOF
    log_info "Chaves geradas e salvas no .env (Mantenha este arquivo seguro!)"
}

main() {
    check_requirements
    generate_secrets
    configure_env
    
    log_info "Baixando configuracoes oficiais do Kong..."
    mkdir -p volumes/api
    curl -s https://raw.githubusercontent.com/supabase/supabase/master/docker/volumes/api/kong.yml > volumes/api/kong.yml

    log_info "Iniciando a stack Supabase..."
    docker compose up -d
    
    log_info "=== SUPABASE PRONTO ==="
    log_info "Dashboard: http://localhost:$STUDIO_PORT"
    log_info "User: supabase / Pass: ${DB_PASSWORD} (Postgres)"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
