#!/usr/bin/env bats
setup() {
    REPO_ROOT=$(cd "${BATS_TEST_DIRNAME}/.." && pwd)
    load "${REPO_ROOT}/tests/mocks/system_mocks.bash"
    TEST_DIR="/tmp/autogen_test"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    source "${REPO_ROOT}/stacks/autogen-studio/setup.sh"
}
teardown() { rm -rf "/tmp/autogen_test"; }
@test "AutoGen Studio: deve configurar porta no .env" {
    run main << 'EOF'
8055
sk-test
EOF
    [ "$status" -eq 0 ]
    [ -f .env ]
    grep "AUTOGEN_PORT=8055" .env
}
