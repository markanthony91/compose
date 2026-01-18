#!/usr/bin/env bats
setup() {
    REPO_ROOT=$(cd "${BATS_TEST_DIRNAME}/.." && pwd)
    load "${REPO_ROOT}/tests/mocks/system_mocks.bash"
    TEST_DIR="/tmp/supabase_test"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    source "${REPO_ROOT}/stacks/supabase/setup.sh"
}
teardown() { rm -rf "/tmp/supabase_test"; }
@test "Supabase: deve gerar segredos no .env" {
    run main << 'EOF'
8005
EOF
    [ "$status" -eq 0 ]
    [ -f .env ]
    grep "JWT_SECRET" .env
    grep "STUDIO_PORT=8005" .env
}
