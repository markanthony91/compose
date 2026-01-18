#!/bin/bash
set -euo pipefail

# Cores
readonly GREEN='[0;32m'
readonly CYAN='[0;36m'
readonly NC='[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }

main() {
    log_info "Configurando Qdrant Vector DB..."
    
    if [ ! -f .env ]; then
        echo "Qual porta REST deseja usar? [6333]"
        read -p "> " rest_port
        QDRANT_REST_PORT=${rest_port:-6333}

        echo "Qual porta gRPC deseja usar? [6334]"
        read -p "> " grpc_port
        QDRANT_GRPC_PORT=${grpc_port:-6334}

        cat > .env << EOF
QDRANT_REST_PORT=$QDRANT_REST_PORT
QDRANT_GRPC_PORT=$QDRANT_GRPC_PORT
EOF
        log_info "Arquivo .env criado."
    fi

    log_info "Iniciando a stack..."
    docker compose up -d
    
    log_info "=== QDRANT PRONTO ==="
    log_info "REST: http://localhost:$(grep '^QDRANT_REST_PORT=' .env | cut -d= -f2)"
    log_info "gRPC: http://localhost:$(grep '^QDRANT_GRPC_PORT=' .env | cut -d= -f2)"
}

main "$@"
