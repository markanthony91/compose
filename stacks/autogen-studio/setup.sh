#!/bin/bash
set -euo pipefail

# Cores
readonly GREEN='[0;32m'
readonly CYAN='[0;36m'
readonly NC='[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }

main() {
    log_info "Configurando AutoGen Studio..."
    
    if [ ! -f .env ]; then
        echo "Qual porta deseja usar? [8081]"
        read -p "> " port
        AUTOGEN_PORT=${port:-8081}

        echo "Deseja inserir uma OpenAI API Key? (Opcional se usar Ollama)"
        read -p "> " api_key

        cat > .env << EOF
AUTOGEN_PORT=$AUTOGEN_PORT
OPENAI_API_KEY=$api_key
EOF
        log_info "Arquivo .env criado."
    fi

    log_info "Iniciando a stack..."
    docker compose up -d
    
    log_info "=== AUTOGEN STUDIO PRONTO ==="
    log_info "Acesse em: http://localhost:$(grep '^AUTOGEN_PORT=' .env | cut -d= -f2)"
}

main "$@"
