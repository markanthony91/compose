#!/usr/bin/env bats

setup() {
    REPO_ROOT=$(cd "${BATS_TEST_DIRNAME}/.." && pwd)
    load "${REPO_ROOT}/tests/mocks/system_mocks.bash"

    TEST_DIR="/tmp/beszel_test"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"

    source "${REPO_ROOT}/stacks/beszel/setup.sh"

    DOCKER_CALLS="${TEST_DIR}/docker_calls.log"

    docker() {
        echo "$*" >> "$DOCKER_CALLS"

        if [[ "$1" == "info" ]]; then
            return 0
        fi

        if [[ "$1" == "compose" && "$2" == "version" ]]; then
            echo "Docker Compose version v2.24.0"
            return 0
        fi

        if [[ "$1" == "compose" && "$2" == "up" ]]; then
            return 0
        fi

        if [[ "$1" == "compose" && "$2" == "--profile" && "$4" == "up" ]]; then
            return 0
        fi

        echo "docker $*"
        return 0
    }
}

teardown() {
    rm -rf "/tmp/beszel_test"
}

@test "Beszel: write_env_if_missing deve criar .env com placeholders" {
    run write_env_if_missing 8090 http://localhost:8090
    [ "$status" -eq 0 ]
    [ -f .env ]
    grep -q "BESZEL_PORT=8090" .env
    grep -q "BESZEL_APP_URL=http://localhost:8090" .env
    grep -q "BESZEL_AGENT_KEY=__ADD_BESZEL_PUBLIC_KEY__" .env
    grep -q "BESZEL_AGENT_TOKEN=__ADD_BESZEL_TOKEN__" .env
}

@test "Beszel: agent_env_ready deve falhar com placeholders e passar com credenciais reais" {
    write_env_if_missing 8090 http://localhost:8090

    run agent_env_ready
    [ "$status" -eq 1 ]

    ensure_env_value "BESZEL_AGENT_KEY" "ssh-ed25519 AAAATESTE"
    ensure_env_value "BESZEL_AGENT_TOKEN" "token-real"

    run agent_env_ready
    [ "$status" -eq 0 ]
}

@test "Beszel: main deve subir apenas o hub quando agent nao estiver configurado" {
    run main 8090 http://localhost:8090
    [ "$status" -eq 0 ]
    [ -f .env ]
    grep -q "compose up -d beszel" "$DOCKER_CALLS"
    ! grep -q -- "--profile agent up -d beszel-agent" "$DOCKER_CALLS"
}

@test "Beszel: main deve subir hub e agent quando .env tiver token e chave" {
    write_env_if_missing 8090 http://localhost:8090
    ensure_env_value "BESZEL_AGENT_KEY" "ssh-ed25519 AAAATESTE"
    ensure_env_value "BESZEL_AGENT_TOKEN" "token-real"

    run main 8090 http://localhost:8090
    [ "$status" -eq 0 ]
    grep -q "compose up -d beszel" "$DOCKER_CALLS"
    grep -q -- "compose --profile agent up -d beszel-agent" "$DOCKER_CALLS"
}
