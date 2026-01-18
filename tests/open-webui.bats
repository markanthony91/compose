#!/usr/bin/env bats
setup() {
    REPO_ROOT=$(cd "${BATS_TEST_DIRNAME}/.." && pwd)
    load "${REPO_ROOT}/tests/mocks/system_mocks.bash"
    TEST_DIR="/tmp/openwebui_test"
    mkdir -p "$TEST_DIR"
    cp "${REPO_ROOT}/stacks/open-webui/.env.example" "$TEST_DIR/"
    cd "$TEST_DIR"
    source "${REPO_ROOT}/stacks/open-webui/setup.sh"
}
teardown() { rm -rf "/tmp/openwebui_test"; }
@test "Open WebUI: deve gerar secret key no .env" {
    run main
    [ "$status" -eq 0 ]
    [ -f .env ]
    grep "WEBUI_SECRET_KEY=" .env
}
