#!/bin/bash
set -euo pipefail

# Cores
readonly GREEN='[0;32m'
readonly YELLOW='[1;33m'
readonly RED='[0;31m'
readonly CYAN='[0;36m'
readonly NC='[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

check_requirements() {
    log_info "Verificando Docker e Rede..."
    if ! docker network inspect llmserver &> /dev/null; then
        docker network create llmserver
    fi
    mkdir -p config cache
}

configure_env() {
    log_info "Configuracao Interativa do Kopia Backup..."
    
    # 1. Porta
    read -p "Qual porta deseja usar? [51515]: " APP_PORT
    APP_PORT=${APP_PORT:-51515}

    # 2. Senha
    read -s -p "Defina a senha do admin: " KOPIA_PASS
    echo ""

    # 3. Storage (SSD/NVMe)
    log_info "Discos Disponiveis:"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep -v "loop"
    read -p "Caminho do Repositorio (Destino): " REPO_PATH
    read -p "Caminho dos Dados (Origem): " DATA_PATH

    cat > .env << EOF
APP_PORT=$APP_PORT
KOPIA_PASS=$KOPIA_PASS
REPO_PATH=$REPO_PATH
DATA_PATH=$DATA_PATH
KOPIA_USER=admin
EOF
    log_info "Arquivo .env criado."
}

main() {
    log_info "Iniciando Setup da Stack: kopia"
    check_requirements
    configure_env
    docker compose up -d
    log_info "Deploy concluido!"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
