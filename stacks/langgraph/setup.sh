#!/bin/bash
set -euo pipefail

# Cores
readonly GREEN='[0;32m'
readonly NC='[0m'

main() {
    log_info "Iniciando Setup da Stack: langgraph"
    echo -e "${GREEN}[INFO]${NC} Configurando LangGraph Server..."
    
    if [ ! -f .env ]; then
        local db_pass=$(openssl rand -hex 16)
        echo "LANGGRAPH_PORT=8123" > .env
        echo "DB_PASSWORD=$db_pass" >> .env
        echo -e "${GREEN}[✓]${NC} Segredos gerados no .env"
    fi

    # Cria arquivo de config minima se nao existir
    if [ ! -f langgraph.json ]; then
        echo '{"graphs": {}, "dependencies": ["langgraph"]}' > langgraph.json
    fi

    docker compose up -d
    echo -e "${GREEN}=== LANGGRAPH SERVER PRONTO ===${NC}"
    echo "Acesse a API em: http://localhost:$(grep LANGGRAPH_PORT .env | cut -d= -f2)"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
