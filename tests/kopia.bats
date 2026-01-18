#!/usr/bin/env bats
setup() {
    REPO_ROOT=$(cd "${BATS_TEST_DIRNAME}/.." && pwd)
    load "${REPO_ROOT}/tests/mocks/system_mocks.bash"
    TEST_DIR="/tmp/kopia_test"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    source "${REPO_ROOT}/stacks/kopia/setup.sh"
}
teardown() { rm -rf "/tmp/kopia_test"; }
@test "Kopia: deve configurar storage no .env" {
    run configure_env << 'EOF'
51545
senha123
/mnt/repo
/data
EOF
    [ "$status" -eq 0 ]
    [ -f .env ]
    grep "REPO_PATH=/mnt/repo" .env
}
