#!/bin/bash
set -euo pipefail

# Cores
readonly GREEN='[0;32m'
readonly CYAN='[0;36m'
readonly NC='[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }

main() {
    log_info "Configurando Open WebUI..."
    
    if [ ! -f .env ]; then
        cp .env.example .env
        # Gera uma chave secreta segura
        local key=$(openssl rand -hex 32)
        sed -i "s/WEBUI_SECRET_KEY=/WEBUI_SECRET_KEY=$key/" .env
        log_info "Chave WEBUI_SECRET_KEY gerada automaticamente."
    fi

    log_info "Iniciando a stack..."
    docker compose up -d
    
    log_info "=== OPEN WEBUI PRONTO ==="
    log_info "Acesse em: http://localhost:$(grep '^PORT=' .env | cut -d= -f2)"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
