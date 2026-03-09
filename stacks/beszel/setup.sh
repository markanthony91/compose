#!/bin/bash
set -euo pipefail

readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'
readonly DEFAULT_PORT="8090"
readonly DEFAULT_APP_URL="http://localhost:${DEFAULT_PORT}"
readonly PLACEHOLDER_KEY="__ADD_BESZEL_PUBLIC_KEY__"
readonly PLACEHOLDER_TOKEN="__ADD_BESZEL_TOKEN__"

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

usage() {
    cat <<'EOF'
Uso: ./setup.sh [porta] [app_url]

Exemplos:
  ./setup.sh
  ./setup.sh 8095
  ./setup.sh 8095 http://localhost:8095

Fluxo:
  1. Sobe o Beszel Hub.
  2. Se KEY e TOKEN do agent estiverem preenchidos no .env, sobe o agent tambem.
EOF
}

require_command() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log_error "Comando obrigatorio ausente: $cmd"
        exit 1
    fi
}

check_requirements() {
    require_command docker

    if ! docker info >/dev/null 2>&1; then
        log_error "Docker nao esta acessivel. No WSL2, confirme que o daemon esta ativo."
        exit 1
    fi

    if ! docker compose version >/dev/null 2>&1; then
        log_error "Docker Compose plugin nao encontrado."
        exit 1
    fi

    if grep -qi microsoft /proc/version 2>/dev/null; then
        log_warn "Ambiente WSL detectado. O monitoramento refletira o Linux do WSL2, nao o Windows host."
    fi
}

create_directories() {
    mkdir -p beszel_data beszel_agent_data beszel_socket
}

write_env_if_missing() {
    local port="$1"
    local app_url="$2"

    if [[ -f .env ]]; then
        log_info "Arquivo .env existente preservado."
        return
    fi

    cat > .env <<EOF
BESZEL_PORT=${port}
BESZEL_APP_URL=${app_url}
BESZEL_AGENT_KEY=${PLACEHOLDER_KEY}
BESZEL_AGENT_TOKEN=${PLACEHOLDER_TOKEN}
TZ=America/Sao_Paulo
EOF

    log_info "Arquivo .env criado com placeholders para o agent."
}

ensure_env_value() {
    local key="$1"
    local value="$2"

    if grep -q "^${key}=" .env; then
        sed -i "s|^${key}=.*|${key}=${value}|" .env
    else
        printf '%s=%s\n' "$key" "$value" >> .env
    fi
}

agent_env_ready() {
    local key token
    key="$(grep '^BESZEL_AGENT_KEY=' .env | cut -d= -f2- || true)"
    token="$(grep '^BESZEL_AGENT_TOKEN=' .env | cut -d= -f2- || true)"

    [[ -n "$key" && -n "$token" && "$key" != "$PLACEHOLDER_KEY" && "$token" != "$PLACEHOLDER_TOKEN" ]]
}

start_hub() {
    log_info "Subindo Beszel Hub..."
    docker compose up -d beszel
}

start_agent_if_ready() {
    if agent_env_ready; then
        log_info "KEY e TOKEN detectados. Subindo o Beszel Agent..."
        docker compose --profile agent up -d beszel-agent
        return
    fi

    log_warn "Agent nao foi iniciado porque KEY/TOKEN ainda nao foram preenchidos no .env."
    cat <<'EOF'
Proximo passo:
  1. Abra o Hub.
  2. Crie um token em /settings/tokens.
  3. Adicione um sistema manualmente e copie a public key.
  4. Atualize BESZEL_AGENT_TOKEN e BESZEL_AGENT_KEY no .env.
  5. Rode novamente: ./setup.sh

Ao cadastrar o sistema no Hub, use este Host / IP:
  /beszel_socket/beszel.sock
EOF
}

main() {
    if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
        usage
        exit 0
    fi

    local port="${1:-$DEFAULT_PORT}"
    local app_url="${2:-http://localhost:${port}}"

    check_requirements
    create_directories
    write_env_if_missing "$port" "$app_url"
    ensure_env_value "BESZEL_PORT" "$port"
    ensure_env_value "BESZEL_APP_URL" "$app_url"
    start_hub
    start_agent_if_ready

    log_info "Hub disponivel em ${app_url}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
