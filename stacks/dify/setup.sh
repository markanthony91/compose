#!/bin/bash
set -euo pipefail

# Cores
readonly GREEN='[0;32m'
readonly NC='[0m'

main() {
    echo -e "${GREEN}[INFO]${NC} Configurando Dify..."
    
    if [ ! -f .env ]; then
        local db_pass=$(openssl rand -hex 16)
        local secret=$(openssl rand -hex 32)
        echo "DIFY_PORT=8001" > .env
        echo "DB_PASSWORD=$db_pass" >> .env
        echo "SECRET_KEY=$secret" >> .env
        echo -e "${GREEN}[✓]${NC} Segredos gerados no .env"
    fi

    docker compose up -d
    echo -e "${GREEN}=== DIFY PRONTO ===${NC}"
    echo "Acesse em: http://localhost:$(grep DIFY_PORT .env | cut -d= -f2)"
}

main "$@"
