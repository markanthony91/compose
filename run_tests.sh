#!/bin/bash
echo "=== Executando Testes de Stacks (Compose) ==="
if ! command -v bats &> /dev/null; then
    echo "Erro: bats nao encontrado."
    exit 1
fi
bats tests/*.bats
