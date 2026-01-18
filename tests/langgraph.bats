#!/usr/bin/env bats
setup() {
    REPO_ROOT=$(cd "${BATS_TEST_DIRNAME}/.." && pwd)
    load "${REPO_ROOT}/tests/mocks/system_mocks.bash"
    TEST_DIR="/tmp/langgraph_test"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    source "${REPO_ROOT}/stacks/langgraph/setup.sh"
}
teardown() { rm -rf "/tmp/langgraph_test"; }
@test "LangGraph: deve gerar DB_PASSWORD no .env" {
    run main
    [ "$status" -eq 0 ]
    [ -f .env ]
    grep "DB_PASSWORD" .env
}
