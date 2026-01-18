#!/bin/bash
set -euo pipefail

# Cores
readonly GREEN='[0;32m'
readonly NC='[0m'

main() {
    echo -e "${GREEN}[INFO]${NC} Configurando RAGFlow..."
    
    if [ ! -f .env ]; then
        local db_pass=$(openssl rand -hex 16)
        echo "RAGFLOW_PORT=8002" > .env
        echo "DB_PASSWORD=$db_pass" >> .env
        echo -e "${GREEN}[✓]${NC} Arquivo .env criado."
    fi

    # Garante que o ES tem memoria virtual suficiente
    sudo sysctl -w vm.max_map_count=262144 || true

    docker compose up -d
    echo -e "${GREEN}=== RAGFLOW PRONTO ===${NC}"
    echo "Acesse em: http://localhost:$(grep RAGFLOW_PORT .env | cut -d= -f2)"
}

main "$@"
