#!/bin/bash

# AutoDock run workflow (entrypoint logic).
#
# This file defines functions only; the executable run.sh should stay minimal.

# Shellcheck note: these sources are intentionally dynamic, based on AUTODOCK_ROOT.

if [ -z "${AUTODOCK_ROOT:-}" ]; then
    AUTODOCK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi

source "$AUTODOCK_ROOT/libraries/core/config.sh"
source "$AUTODOCK_ROOT/libraries/core/config_json.sh"
source "$AUTODOCK_ROOT/libraries/core/logging.sh"
source "$AUTODOCK_ROOT/libraries/core/errors.sh"
source "$AUTODOCK_ROOT/libraries/ui/banner.sh"
source "$AUTODOCK_ROOT/libraries/host/media.sh"
source "$AUTODOCK_ROOT/libraries/host/devices.sh"
source "$AUTODOCK_ROOT/libraries/docker/docker.sh"
source "$AUTODOCK_ROOT/libraries/cli/arguments.sh"

_autodock_print_banner() {
    if autodock_supports_color; then
        printf '%s' "${AUTODOCK_LOG_COLOR_CYAN}"
        print_autodock_banner
        printf '%s' "${AUTODOCK_LOG_COLOR_RESET}"
    else
        print_autodock_banner
    fi
}

_autodock_image_ref() {
    echo "${AUTODOCK_IMAGE_NAME}:${AUTODOCK_IMAGE_TAG}"
}

_autodock_default_run_user() {
    echo "${AUTODOCK_BUILD_USER_NAME}:$(id -g)"
}

_autodock_append_proxy_env() {
    local -n out="$1"

    out+=("-e" "http_proxy")
    out+=("-e" "https_proxy")
    out+=("-e" "no_proxy")
    out+=("-e" "HTTP_PROXY")
    out+=("-e" "HTTPS_PROXY")
    out+=("-e" "NO_PROXY")
}

_autodock_append_x11() {
    local -n out="$1"

    if [ -z "${DISPLAY:-}" ] || [ ! -d /tmp/.x11-unix ]; then
        return 0
    fi

    local xsock=/tmp/.x11-unix
    local xauth=/tmp/.docker.xauth

    touch "$xauth" 2>/dev/null || true
    if command -v xauth >/dev/null 2>&1; then
        xauth nlist "$DISPLAY" | sed -e 's/^..../ffff/' | xauth -f "$xauth" nmerge - >/dev/null 2>&1 || true
    fi

    out+=("-e" "DISPLAY")
    out+=("-e" "QT_X11_NO_MITSHM=1")
    out+=("-v" "$xsock:$xsock")
    out+=("-v" "$xauth:$xauth")
    out+=("-e" "XAUTHORITY=$xauth")
}

_autodock_append_mount_spec() {
    local -n out="$1"
    local spec="$2"

    if [[ "$spec" != *:* ]]; then
        autodock_die ADK100_INVALID_MOUNT_SPEC "$spec"
    fi

    local host_path
    host_path="${spec%%:*}"
    if [ -z "$host_path" ]; then
        autodock_die ADK100_INVALID_MOUNT_SPEC "$spec"
    fi

    if [[ "$host_path" != /* ]]; then
        host_path="${AUTODOCK_CALLER_DIR:-$PWD}/$host_path"
        if command -v readlink >/dev/null 2>&1; then
            host_path=$(readlink -f "$host_path" 2>/dev/null || echo "$host_path")
        fi

        local rest
        rest="${spec#*:}"
        spec="$host_path:$rest"
    fi

    if [ ! -e "$host_path" ]; then
        autodock_die ADK101_MOUNT_HOST_PATH_NOT_FOUND "$host_path" "$spec"
    fi

    out+=("-v" "$spec")
}

_autodock_append_named_dir_mounts() {
    local -n out="$1"
    shift

    local -A used_targets=()
    local raw
    for raw in "$@"; do
        if [[ "$raw" != /* ]]; then
            raw="${AUTODOCK_CALLER_DIR:-$PWD}/$raw"
            if command -v readlink >/dev/null 2>&1; then
                raw=$(readlink -f "$raw" 2>/dev/null || echo "$raw")
            fi
        fi

        local directory
        directory=$(import_directory "$raw") || autodock_die ADK102_INVALID_DIR_ARG "$raw"

        local folder_name
        folder_name=$(basename "$directory")

        local target="/home/user/$folder_name"
        if [ -n "${used_targets[$target]:-}" ]; then
            autodock_die ADK103_DIR_BASENAME_COLLISION "$target"
        fi
        used_targets[$target]=1

        out+=("-v" "$directory:$target")
    done
}

_autodock_append_dev_convenience_mounts() {
    local -n out="$1"

    if [ "${AUTODOCK_CLI_MOUNT_SSH:-0}" -eq 1 ]; then
        if [ -n "${HOME:-}" ] && [ -d "${HOME}/.ssh" ]; then
            out+=("-v" "${HOME}/.ssh:/home/user/.ssh:ro")
        else
            log_warn "--ssh requested but ~/.ssh not found; skipping"
        fi
    fi

    if [ "${AUTODOCK_CLI_MOUNT_GITCONFIG:-0}" -eq 1 ]; then
        if [ -n "${HOME:-}" ] && [ -f "${HOME}/.gitconfig" ]; then
            out+=("-v" "${HOME}/.gitconfig:/home/user/.gitconfig:ro")
        else
            log_warn "--gitconfig requested but ~/.gitconfig not found; skipping"
        fi
    fi

    if [ "${AUTODOCK_CLI_MOUNT_SSH_AGENT:-0}" -eq 1 ]; then
        if [ -n "${SSH_AUTH_SOCK:-}" ] && [ -S "${SSH_AUTH_SOCK}" ]; then
            out+=("-v" "${SSH_AUTH_SOCK}:/ssh-agent")
            out+=("-e" "SSH_AUTH_SOCK=/ssh-agent")
        else
            log_warn "--ssh-agent requested but SSH_AUTH_SOCK is not available; skipping"
        fi
    fi

    if [ "${AUTODOCK_CLI_MOUNT_CACHES:-0}" -eq 1 ]; then
        if [ -z "${HOME:-}" ]; then
            log_warn "--cache requested but HOME is not set; skipping"
            return 0
        fi

        mkdir -p "${HOME}/.cache/pip" "${HOME}/.cache/huggingface" "${HOME}/.cache/torch" "${HOME}/.cache/uv" 2>/dev/null || true
        out+=("-v" "${HOME}/.cache/pip:/home/user/.cache/pip")
        out+=("-v" "${HOME}/.cache/huggingface:/home/user/.cache/huggingface")
        out+=("-v" "${HOME}/.cache/torch:/home/user/.cache/torch")
        out+=("-v" "${HOME}/.cache/uv:/home/user/.cache/uv")
    fi
}

_autodock_build_docker_run_args() {
    local out_name="$1"
    local device_type="$2"
    local image_ref="$3"

    local -n out="$out_name"

    out=("run")
    out+=("--shm-size" "${AUTODOCK_SHM_SIZE}")

    if [ "${AUTODOCK_CLI_DETACH:-0}" -eq 1 ]; then
        out+=("-d")
    else
        out+=("-ti")
    fi

    if [ "${AUTODOCK_CLI_NO_RM:-0}" -eq 0 ]; then
        out+=("--rm")
    fi

    out+=("--name" "${AUTODOCK_CONTAINER_NAME}")

    local run_user
    run_user="${AUTODOCK_RUN_USER:-}"
    if [ -z "$run_user" ]; then
        run_user=$(_autodock_default_run_user)
    fi
    out+=("--user" "$run_user")

    out+=("--net=${AUTODOCK_NETWORK_MODE}")
    out+=("--workdir" "${AUTODOCK_WORKDIR}")
    out+=("--group-add" "video")

    append_hostdevice_properties "$out_name" "$device_type" "${AUTODOCK_CLI_ENABLE_GPU:-1}"

    local repo_root="${AUTODOCK_REPO_ROOT:-${REPO_ROOT:-}}"
    if [ -z "$repo_root" ]; then
        repo_root="$(cd "$AUTODOCK_ROOT/.." && pwd)"
    fi

    if [ ! -d "$repo_root/src" ]; then
        autodock_die ADK110_REPO_SRC_DIR_MISSING "$repo_root"
    fi
    out+=("-v" "$repo_root/src:/home/user/src")

    if [ -d /media ]; then
        out+=("-v" "/media:/media")
    fi

    if [ -n "${USER:-}" ] && [ -d "/media/${USER}" ]; then
        out+=("-v" "/media/${USER}:/media/${USER}")
    fi

    if [ -d /dev ]; then
        out+=("-v" "/dev:/dev")
    fi

    _autodock_append_proxy_env "$out_name"
    _autodock_append_x11 "$out_name"

    if [ "${AUTODOCK_CLI_AUDIO:-0}" -eq 1 ]; then
        append_audio_devices "$out_name"
    fi
    if [ "${AUTODOCK_CLI_HID:-0}" -eq 1 ]; then
        append_hid_devices "$out_name"
    fi
    if [ "${AUTODOCK_CLI_PERIPHERALS:-0}" -eq 1 ]; then
        append_peripherals "$out_name"
    fi
    if [ "${AUTODOCK_CLI_WEBCAM:-0}" -eq 1 ]; then
        if ! append_video_devices "$out_name"; then
            log_warn "--webcam requested but no /dev/video* devices were found"
        fi
    fi

    if [ "${#AUTODOCK_CLI_EXTRA_DIRS[@]}" -gt 0 ]; then
        _autodock_append_named_dir_mounts "$out_name" "${AUTODOCK_CLI_EXTRA_DIRS[@]}"
    fi

    local spec
    for spec in "${AUTODOCK_CLI_EXTRA_MOUNTS[@]}"; do
        _autodock_append_mount_spec "$out_name" "$spec"
    done

    _autodock_append_dev_convenience_mounts "$out_name"

    local env_kv
    for env_kv in "${AUTODOCK_CLI_ENV_VARS[@]}"; do
        out+=("-e" "$env_kv")
    done

    local env_key
    for env_key in "${AUTODOCK_CLI_ENV_PASS[@]}"; do
        if [ -z "${!env_key-}" ]; then
            log_warn "--env-pass $env_key requested but it is not set in the host environment"
        fi
        out+=("-e" "$env_key")
    done

    local env_file
    for env_file in "${AUTODOCK_CLI_ENV_FILES[@]}"; do
        if [[ "$env_file" != /* ]]; then
            env_file="${AUTODOCK_CALLER_DIR:-$PWD}/$env_file"
            if command -v readlink >/dev/null 2>&1; then
                env_file=$(readlink -f "$env_file" 2>/dev/null || echo "$env_file")
            fi
        fi
        if [ ! -f "$env_file" ]; then
            autodock_die ADK120_ENV_FILE_NOT_FOUND "$env_file"
        fi
        out+=("--env-file" "$env_file")
    done

    if [ "${#AUTODOCK_CLI_PORTS[@]}" -gt 0 ] && [ "${AUTODOCK_NETWORK_MODE}" = "host" ]; then
        log_warn "Ports were requested but network mode is 'host'; -P/--port is typically unnecessary"
    fi
    local port_spec
    for port_spec in "${AUTODOCK_CLI_PORTS[@]}"; do
        out+=("-p" "$port_spec")
    done

    out+=("$image_ref")
    if [ "${#AUTODOCK_CLI_CMD[@]}" -gt 0 ]; then
        out+=("${AUTODOCK_CLI_CMD[@]}")
    fi
}

autodock_run_main() {
    # Apply JSON config defaults (when ENABLED=true), then compute effective defaults.
    autodock_config_apply_default_overrides
    autodock_config_init

    _autodock_print_banner

    require_command docker

    local -a config_args=()
    local -a config_cmd=()
    if autodock_config_is_enabled; then
        readarray -t config_args < <(autodock_config_get_run_args)
        readarray -t config_cmd < <(autodock_config_get_command)
    fi

    local cli_has_cmd=0
    local arg
    for arg in "$@"; do
        if [ "$arg" = "--" ]; then
            cli_has_cmd=1
            break
        fi
    done

    local -a combined_args=()
    combined_args=("${config_args[@]}" "$@")

    if [ "$cli_has_cmd" -eq 0 ] && [ "${#config_cmd[@]}" -gt 0 ]; then
        combined_args=("${config_args[@]}" "$@" "--" "${config_cmd[@]}")
    fi

    if ! autodock_parse_cli "${combined_args[@]}"; then
        autodock_print_help
        return 2
    fi
    if [ "${AUTODOCK_CLI_SHOW_HELP:-0}" -eq 1 ]; then
        autodock_print_help
        return 0
    fi

    local device_type
    device_type=$(detect_hostdevice_type)
    log_info "Detected device type: $device_type"

    local image_ref
    image_ref=$(_autodock_image_ref)

    if [ "${AUTODOCK_CLI_REBUILD:-0}" -eq 1 ]; then
        log_info "--rebuild requested"
        autodock_build_image "$device_type"
    else
        if autodock_image_exists; then
            log_info "Image found: $image_ref"
        else
            if [ "${AUTODOCK_CLI_NO_BUILD:-0}" -eq 1 ]; then
                autodock_die ADK130_IMAGE_MISSING_NO_BUILD "$image_ref"
            fi
            log_warn "Image not found; building it now: $image_ref"
            autodock_build_image "$device_type"
        fi
    fi

    local -a docker_args=()
    _autodock_build_docker_run_args docker_args "$device_type" "$image_ref"

    log_info "Starting container: ${AUTODOCK_CONTAINER_NAME}"
    docker "${docker_args[@]}"
}
