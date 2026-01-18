#!/usr/bin/env bats

setup() {
    REPO_ROOT=$(cd "${BATS_TEST_DIRNAME}/.." && pwd)
    load "${REPO_ROOT}/tests/mocks/system_mocks.bash"
    
    # Injeta variaveis necessarias antes do source
    export STACK_NAME="uptime-kuma"
    
    # Cria pasta temporaria para nao sujar o repo
    TEST_DIR="/tmp/uptime_test"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    # Carrega o script
    source "${REPO_ROOT}/stacks/uptime-kuma/setup.sh"
}

teardown() {
    rm -rf "/tmp/uptime_test"
}

@test "Uptime Kuma: configure_env deve criar .env corretamente" {
    run configure_env 3045
    [ "$status" -eq 0 ]
    [ -f .env ]
    grep "APP_PORT=3045" .env
}
