#!/bin/bash

# Colored terminal logging + error file logging.

_autodock_log__supports_color() {
    [ -t 1 ] && [ -z "${NO_COLOR:-}" ]
}

autodock_supports_color() {
    _autodock_log__supports_color
}

_autodock_log__init_colors() {
    if _autodock_log__supports_color; then
        AUTODOCK_LOG_COLOR_RESET=$'\033[0m'
        AUTODOCK_LOG_COLOR_DIM=$'\033[2m'
        AUTODOCK_LOG_COLOR_RED=$'\033[31m'
        AUTODOCK_LOG_COLOR_GREEN=$'\033[32m'
        AUTODOCK_LOG_COLOR_YELLOW=$'\033[33m'
        AUTODOCK_LOG_COLOR_BLUE=$'\033[34m'
        AUTODOCK_LOG_COLOR_MAGENTA=$'\033[35m'
        AUTODOCK_LOG_COLOR_CYAN=$'\033[36m'
    else
        AUTODOCK_LOG_COLOR_RESET=""
        AUTODOCK_LOG_COLOR_DIM=""
        AUTODOCK_LOG_COLOR_RED=""
        AUTODOCK_LOG_COLOR_GREEN=""
        AUTODOCK_LOG_COLOR_YELLOW=""
        AUTODOCK_LOG_COLOR_BLUE=""
        AUTODOCK_LOG_COLOR_MAGENTA=""
        AUTODOCK_LOG_COLOR_CYAN=""
    fi
}

_autodock_log__init_colors

_autodock_log__level_to_int() {
    case "${1:-INFO}" in
        DEBUG) echo 10 ;;
        INFO)  echo 20 ;;
        WARN)  echo 30 ;;
        ERROR) echo 40 ;;
        *)     echo 20 ;;
    esac
}

_autodock_log__should_log() {
    local msg_level_int
    local current_level_int
    msg_level_int=$(_autodock_log__level_to_int "${1:-INFO}")
    current_level_int=$(_autodock_log__level_to_int "${AUTODOCK_LOG_LEVEL:-INFO}")
    [ "$msg_level_int" -ge "$current_level_int" ]
}

_autodock_log__ts() {
    date '+%Y-%m-%d %H:%M:%S'
}

_autodock_log__write_file() {
    local level="$1"
    shift
    local msg="$*"
    local file="${AUTODOCK_LOG_FILE:-errors.txt}"

    mkdir -p "$(dirname "$file")" 2>/dev/null || true
    echo "$(_autodock_log__ts) - [$level] $msg" >> "$file"
}

_autodock_log__print() {
    local level="$1"
    local color="$2"
    shift 2
    local msg="$*"

    if ! _autodock_log__should_log "$level"; then
        return 0
    fi

    local ts
    ts=$(_autodock_log__ts)
    printf '%s%s[%s]%s %s\n' "${AUTODOCK_LOG_COLOR_DIM}${ts} " "${color}" "$level" "${AUTODOCK_LOG_COLOR_RESET}" "$msg"
}

log_debug() {
    _autodock_log__print "DEBUG" "${AUTODOCK_LOG_COLOR_MAGENTA}" "$@"
}

log_info() {
    _autodock_log__print "INFO" "${AUTODOCK_LOG_COLOR_BLUE}" "$@"
}

log_warn() {
    _autodock_log__print "WARN" "${AUTODOCK_LOG_COLOR_YELLOW}" "$@" >&2
}

log_success() {
    _autodock_log__print "INFO" "${AUTODOCK_LOG_COLOR_GREEN}" "$@"
}

log_error(){
    _autodock_log__print "ERROR" "${AUTODOCK_LOG_COLOR_RED}" "$@" >&2
    _autodock_log__write_file "ERROR" "$@"
}

die() {
    log_error "$@"
    exit 1
}

require_command() {
    local cmd="$1"

    if command -v "$cmd" >/dev/null 2>&1; then
        return 0
    fi

    if declare -F autodock_die >/dev/null 2>&1; then
        autodock_die ADK001_MISSING_COMMAND "$cmd"
    fi

    # Fallback (when the error database isn't loaded).
    log_error "[ADK001_MISSING_COMMAND] $cmd"
    exit 1
}
