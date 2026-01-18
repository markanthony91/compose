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
    log_info "Verificando Docker..."
    if ! command -v docker &> /dev/null; then
        log_error "Docker nao encontrado."
        exit 1
    fi
    if ! docker network inspect llmserver &> /dev/null; then
        log_warn "Criando rede llmserver..."
        docker network create llmserver
    fi
}

configure_env() {
    local stack_name="$1"
    local default_port="$2"
    log_info "Configurando $stack_name..."
    
    echo "Qual porta host deseja usar? [Padrao: $default_port]"
    read -p "> " port
    port=${port:-$default_port}

    if ss -tuln | grep -q ":$port "; then
        log_error "Porta $port em uso!"
        log_warn "Dica: Use o range 45-55 (ex: ${port%?}45)"
        read -p "Nova porta: " port
    fi

    echo "APP_PORT=$port" > .env
    log_success "Porta configurada: $port"
}

setup_tailscale() {
    local port=$(grep "APP_PORT" .env | cut -d= -f2)
    echo "Deseja expor no Tailscale Funnel? (s/n)"
    read -p "> " choice
    if [[ "$choice" =~ ^[Ss]$ ]]; then
        sudo tailscale funnel --bg "$port"
        log_success "Funnel ativo na porta $port"
    fi
}

main() {
    check_requirements
    configure_env "${1:-stack}" "${2:-8080}"
    docker compose up -d
    setup_tailscale
}

main "$@"
