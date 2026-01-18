#!/usr/bin/env bats
setup() {
    REPO_ROOT=$(cd "${BATS_TEST_DIRNAME}/.." && pwd)
    load "${REPO_ROOT}/tests/mocks/system_mocks.bash"
    TEST_DIR="/tmp/qdrant_test"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    source "${REPO_ROOT}/stacks/qdrant/setup.sh"
}
teardown() { rm -rf "/tmp/qdrant_test"; }
@test "Qdrant: deve criar .env com portas customizadas" {
    run configure_env << 'EOF'
6345
6346
EOF
    [ "$status" -eq 0 ]
    [ -f .env ]
    grep "QDRANT_REST_PORT=6345" .env
}
