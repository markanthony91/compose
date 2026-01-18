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
        docker network create llmserver
    fi
}

configure_env() {
    local default_port="${1:-3001}"
    echo "APP_PORT=$default_port" > .env
    log_info "Porta configurada: $default_port"
}

main() {
    log_info "Iniciando Setup da Stack: uptime-kuma"
    check_requirements
    configure_env "${1:-3001}"
    docker compose up -d
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
