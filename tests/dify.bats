#!/usr/bin/env bats
setup() {
    REPO_ROOT=$(cd "${BATS_TEST_DIRNAME}/.." && pwd)
    load "${REPO_ROOT}/tests/mocks/system_mocks.bash"
    TEST_DIR="/tmp/dify_test"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    source "${REPO_ROOT}/stacks/dify/setup.sh"
}
teardown() { rm -rf "/tmp/dify_test"; }
@test "Dify: deve gerar segredos no .env" {
    run main
    [ "$status" -eq 0 ]
    [ -f .env ]
    grep "SECRET_KEY" .env
}
