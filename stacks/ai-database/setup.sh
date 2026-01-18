#!/bin/bash
set -euo pipefail

log_info() { echo "[INFO] $1"; }

configure_env() {
    read -p "Porta DB: " db_port
    read -p "Pass DB: " db_pass
    read -p "Porta Redis: " redis_port
    read -p "Pass Redis: " redis_pass
    read -p "Porta pgAdmin: " pgadmin_port
    read -p "Email pgAdmin: " pgadmin_email
    read -p "Pass pgAdmin: " pgadmin_pass

    echo "DB_PORT=$db_port" > .env
    echo "DB_PASS=$db_pass" >> .env
    echo "REDIS_PORT=$redis_port" >> .env
    echo "REDIS_PASS=$redis_pass" >> .env
    echo "PGADMIN_PORT=$pgadmin_port" >> .env
    echo "PGADMIN_EMAIL=$pgadmin_email" >> .env
    echo "PGADMIN_PASS=$pgadmin_pass" >> .env
}

main() {
    configure_env
    docker compose up -d
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
