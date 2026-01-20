#!/bin/bash
set -euo pipefail

# Cores
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

check_requirements() {
    if ! docker network inspect llmserver &> /dev/null; then
        log_info "Criando rede llmserver..."
        docker network create llmserver
    fi
}

configure_env() {
    local default_port="${1:-8090}"
    echo "BESZEL_PORT=$default_port" > .env
    log_info "Porta configurada: $default_port"
}

main() {
    log_info "Iniciando Setup da Stack: beszel"
    check_requirements
    configure_env "${1:-8090}"
    docker compose up -d
    log_info "Beszel Hub disponivel em http://localhost:${1:-8090}"
    log_info "Importante: No primeiro acesso, crie seu usuario e pegue a KEY para configurar o Agent se necessario."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
