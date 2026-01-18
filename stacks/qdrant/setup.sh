#!/bin/bash
set -euo pipefail

log_info() { echo "[INFO] $1"; }

configure_env() {
    read -p "REST: " rest_port
    read -p "GRPC: " grpc_port
    echo "QDRANT_REST_PORT=$rest_port" > .env
    echo "QDRANT_GRPC_PORT=$grpc_port" >> .env
}

main() {
    log_info "Iniciando Setup da Stack: qdrant"
    configure_env
    docker compose up -d
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
