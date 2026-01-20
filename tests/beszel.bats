#!/usr/bin/env bats

setup() {
    REPO_ROOT=$(cd "${BATS_TEST_DIRNAME}/.." && pwd)
    load "${REPO_ROOT}/tests/mocks/system_mocks.bash"
    
    # Injeta variaveis necessarias antes do source
    export STACK_NAME="beszel"
    
    # Cria pasta temporaria para nao sujar o repo
    TEST_DIR="/tmp/beszel_test"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    # Carrega o script
    source "${REPO_ROOT}/stacks/beszel/setup.sh"
}

teardown() {
    rm -rf "/tmp/beszel_test"
}

@test "Beszel: configure_env deve criar .env corretamente" {
    run configure_env 8090
    [ "$status" -eq 0 ]
    [ -f .env ]
    grep "BESZEL_PORT=8090" .env
}
