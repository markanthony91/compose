#!/bin/bash

# Mock para apt-get
apt-get() {
    echo "apt-get $*"
    return 0
}

# Mock para curl
curl() {
    echo "curl $*"
    return 0
}

# Mock para ping
ping() {
    echo "ping $*"
    return 0
}

# Mock para ngrok
ngrok() {
    if [[ "$1" == "--version" ]]; then
        echo "ngrok version 3.0.0"
    else
        echo "ngrok $*"
    fi
    return 0
}

# Mock para gpg
gpg() {
    echo "gpg $*"
    return 0
}

# Mock para tee
tee() {
    cat
}

# Mock para id (controle de root)
id() {
    if [[ "$1" == "-u" ]]; then
        echo "${MOCK_EUID:-0}"
    else
        command id "$@"
    fi
}

# Mock para command -v
command() {
    if [[ "$1" == "-v" ]]; then
        case "$2" in
            ngrok)
                [[ "${MOCK_NGROK_INSTALLED:-false}" == "true" ]] && echo "/usr/bin/ngrok" && return 0
                return 1
                ;;
            tailscale)
                [[ "${MOCK_TAILSCALE_INSTALLED:-false}" == "true" ]] && echo "/usr/bin/tailscale" && return 0
                return 1
                ;;
            docker)
                [[ "${MOCK_DOCKER_INSTALLED:-true}" == "true" ]] && echo "/usr/bin/docker" && return 0
                return 1
                ;;
            *)
                builtin command -v "$2"
                return $?
                ;;
        esac
    fi
    builtin command "$@"
}
