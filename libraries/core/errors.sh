#!/bin/bash

# AutoDock error database loader + helpers.
#
# Goals:
# - Keep user-facing error text out of workflow code
# - Provide consistent, guided fix instructions

if [ -z "${AUTODOCK_ROOT:-}" ]; then
    AUTODOCK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi

# Load error definitions.
# Each file in libraries/errors/ should define one or more functions:
#   autodock_error_<ERROR_CODE>()
# that prints a multi-line message to stdout.
_autodock_errors__load_db() {
    local db_dir="$AUTODOCK_ROOT/libraries/errors"
    [ -d "$db_dir" ] || return 0

    shopt -s nullglob
    local f
    for f in "$db_dir"/*.sh; do
        # shellcheck disable=SC1090
        source "$f"
    done
    shopt -u nullglob
}

_autodock_errors__load_db

autodock_error_message() {
    local code="${1:-}"
    shift || true

    if [ -z "$code" ]; then
        return 1
    fi

    local fn="autodock_error_${code}"
    if ! declare -F "$fn" >/dev/null 2>&1; then
        return 1
    fi

    "$fn" "$@"
}

# Print a guided error without exiting.
# Uses log_error (timestamped) for the first line, then prints the rest plainly.
autodock_print_error() {
    local code="${1:-}"
    shift || true

    local msg
    msg="$(autodock_error_message "$code" "$@" 2>/dev/null || true)"

    if [ -z "$msg" ]; then
        log_error "[$code] Unknown error"
        return 1
    fi

    local summary="$msg"
    local rest=""
    if [[ "$msg" == *$'\n'* ]]; then
        summary="${msg%%$'\n'*}"
        rest="${msg#*$'\n'}"
    fi

    log_error "[$code] $summary"
    if [ -n "$rest" ]; then
        printf '%s\n' "$rest" >&2
    fi
}

# Print a guided error and exit 1.
autodock_die() {
    autodock_print_error "$@" || true
    exit 1
}
