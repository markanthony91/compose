#!/usr/bin/env bats

setup() {
    REPO_ROOT=$(cd "${BATS_TEST_DIRNAME}/.." && pwd)
    load "${REPO_ROOT}/tests/mocks/system_mocks.bash"
    TEST_DIR="/tmp/bats_test"
    mkdir -p "$TEST_DIR"
    cp "${REPO_ROOT}/stacks/uptime-kuma/setup.sh" "$TEST_DIR/"
}

teardown() {
    rm -rf "/tmp/bats_test"
}

@test "Uptime Kuma: setup.sh deve gerar .env corretamente" {
    cd "/tmp/bats_test"
    docker() { return 0; }
    export -f docker
    run ./setup.sh << 'EOF'
3045
n
EOF
    [ "$status" -eq 0 ]
    [ -f .env ]
}
