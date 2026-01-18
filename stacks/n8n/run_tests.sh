#!/bin/bash
################################################################################
# Script: run_tests.sh
# Descricao: Executa testes Goss na stack n8n
# Autor: Mark - Aiknow Systems
# Data: 2026-01-18
#
# Uso:
#   ./run_tests.sh          # Executa todos os testes
#   ./run_tests.sh --wait   # Apenas aguarda servicos (sem testes)
#   ./run_tests.sh --help   # Mostra ajuda
#
# Requisitos:
#   - Docker e Docker Compose
#   - Stack n8n rodando (docker compose up -d)
#   - goss instalado no host OU usar dcgoss
################################################################################

set -euo pipefail

# Cores
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Diretorio do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Funcoes de log
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Verificar se dcgoss esta instalado
check_dcgoss() {
    if command -v dcgoss &> /dev/null; then
        return 0
    fi

    # Verificar se goss esta disponivel via docker
    if docker run --rm goss/goss goss --version &> /dev/null; then
        log_warn "dcgoss nao encontrado, usando goss via docker"
        return 1
    fi

    log_error "dcgoss ou goss nao encontrado"
    echo ""
    echo "Instalar dcgoss:"
    echo "  curl -fsSL https://goss.rocks/install | sh"
    echo ""
    echo "Ou usar goss via docker:"
    echo "  docker pull goss/goss"
    exit 1
}

# Verificar se stack esta rodando
check_stack() {
    log_info "Verificando se stack esta rodando..."

    if ! docker compose ps --format json | grep -q "running"; then
        log_error "Stack n8n nao esta rodando"
        echo ""
        echo "Subir stack primeiro:"
        echo "  docker compose up -d"
        exit 1
    fi

    log_success "Stack n8n esta rodando"
}

# Executar testes via dcgoss
run_dcgoss_tests() {
    log_info "Executando testes com dcgoss..."

    # Exportar variaveis do .env se existir
    if [[ -f .env ]]; then
        set -a
        source .env
        set +a
    fi

    # Executar dcgoss run no container n8n
    if dcgoss run n8n; then
        log_success "Todos os testes passaram!"
        return 0
    else
        log_error "Alguns testes falharam"
        return 1
    fi
}

# Executar testes via goss direto no container
run_goss_in_container() {
    local container="n8n"

    log_info "Executando testes via goss no container..."

    # Copiar arquivos goss para o container
    docker cp goss.yaml "$container":/tmp/goss.yaml
    docker cp goss_wait.yaml "$container":/tmp/goss_wait.yaml 2>/dev/null || true

    # Instalar goss no container (se necessario)
    docker exec "$container" sh -c '
        if ! command -v goss &> /dev/null; then
            curl -fsSL https://goss.rocks/install | sh
        fi
    ' 2>/dev/null || true

    # Executar testes
    if docker exec "$container" goss -g /tmp/goss.yaml validate --format documentation; then
        log_success "Todos os testes passaram!"
        return 0
    else
        log_error "Alguns testes falharam"
        return 1
    fi
}

# Apenas aguardar servicos
wait_only() {
    log_info "Aguardando servicos ficarem prontos..."

    local timeout=120
    local interval=5
    local elapsed=0

    while [[ $elapsed -lt $timeout ]]; do
        # Verificar healthchecks
        local healthy=$(docker compose ps --format json | grep -c '"Health":"healthy"' || echo 0)
        local total=$(docker compose ps --format json | grep -c '"State":"running"' || echo 0)

        log_info "Servicos healthy: $healthy/$total (${elapsed}s/${timeout}s)"

        if [[ $healthy -ge 3 ]]; then  # postgres, redis, n8n
            log_success "Todos os servicos principais estao healthy!"
            return 0
        fi

        sleep $interval
        elapsed=$((elapsed + interval))
    done

    log_error "Timeout aguardando servicos"
    docker compose ps
    return 1
}

# Mostrar ajuda
show_help() {
    echo "Uso: $0 [opcao]"
    echo ""
    echo "Opcoes:"
    echo "  (sem opcao)   Executa todos os testes"
    echo "  --wait        Apenas aguarda servicos ficarem healthy"
    echo "  --help        Mostra esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0              # Executa testes"
    echo "  $0 --wait       # Aguarda servicos"
    echo ""
    echo "Pre-requisitos:"
    echo "  1. Stack rodando: docker compose up -d"
    echo "  2. dcgoss instalado: curl -fsSL https://goss.rocks/install | sh"
}

# Main
main() {
    echo "=========================================="
    echo "  Testes Goss - Stack n8n"
    echo "=========================================="
    echo ""

    case "${1:-}" in
        --help|-h)
            show_help
            exit 0
            ;;
        --wait|-w)
            check_stack
            wait_only
            exit $?
            ;;
        *)
            check_stack
            wait_only || exit 1

            if check_dcgoss; then
                run_dcgoss_tests
            else
                run_goss_in_container
            fi
            exit $?
            ;;
    esac
}

main "$@"
