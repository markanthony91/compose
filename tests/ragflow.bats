#!/usr/bin/env bats
setup() {
    REPO_ROOT=$(cd "${BATS_TEST_DIRNAME}/.." && pwd)
    load "${REPO_ROOT}/tests/mocks/system_mocks.bash"
    TEST_DIR="/tmp/ragflow_test"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    source "${REPO_ROOT}/stacks/ragflow/setup.sh"
}
teardown() { rm -rf "/tmp/ragflow_test"; }
@test "RAGFlow: deve criar .env corretamente" {
    run main
    [ "$status" -eq 0 ]
    [ -f .env ]
    grep "DB_PASSWORD" .env
}
