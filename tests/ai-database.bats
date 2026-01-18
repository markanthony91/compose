#!/usr/bin/env bats
setup() {
    REPO_ROOT=$(cd "${BATS_TEST_DIRNAME}/.." && pwd)
    load "${REPO_ROOT}/tests/mocks/system_mocks.bash"
    TEST_DIR="/tmp/ai_db_test"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    source "${REPO_ROOT}/stacks/ai-database/setup.sh"
}
teardown() { rm -rf "/tmp/ai_db_test"; }
@test "AI-Database: deve criar .env com portas e senhas" {
    run configure_env << 'EOF'
5445
senha123
6380
senha456
5051
admin@test.com
senha789
EOF
    [ "$status" -eq 0 ]
    [ -f .env ]
    grep "DB_PORT=5445" .env
    grep "REDIS_PORT=6380" .env
}
