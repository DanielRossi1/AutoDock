#!/bin/bash

# Docker helpers (build + image presence)
#
# Expects these to be available:
# - AUTODOCK_IMAGE_NAME / AUTODOCK_IMAGE_TAG / AUTODOCK_BUILD_USER_NAME
# - log_info / log_warn / die / require_command

_autodock_docker__image_ref() {
    echo "${AUTODOCK_IMAGE_NAME}:${AUTODOCK_IMAGE_TAG}"
}

_autodock_docker__repo_root() {
    if [ -n "${AUTODOCK_REPO_ROOT:-}" ]; then
        echo "$AUTODOCK_REPO_ROOT"
        return 0
    fi
    if [ -n "${REPO_ROOT:-}" ]; then
        echo "$REPO_ROOT"
        return 0
    fi

    local autodock_dir
    autodock_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)" # AutoDock directory
    echo "$(cd "$autodock_dir/.." && pwd)"
}

autodock_image_exists() {
    local image_ref
    image_ref=$(_autodock_docker__image_ref)
    docker image inspect "$image_ref" >/dev/null 2>&1
}

autodock_select_dockerfile_relpath() {
    local device="$1"

    case "$device" in
        RASPBERRY_PI)
            echo "AutoDock/dockerfiles/Dockerfile.raspberrypi"
            ;;
        JETSON_NANO)
            echo "AutoDock/dockerfiles/Dockerfile.jetsonNano"
            ;;
        JETSON_ORIN_NANO)
            echo "AutoDock/dockerfiles/Dockerfile.jetsonOrin"
            ;;
        DESKTOP_COMPUTER)
            echo "AutoDock/dockerfiles/Dockerfile"
            ;;
        *)
            return 1
            ;;
    esac
}

autodock_detect_cuda_arch() {
    if ! command -v nvidia-smi >/dev/null 2>&1; then
        echo ""
        return 0
    fi

    nvidia-smi --query-gpu=compute_cap --format=csv,noheader,nounits 2>/dev/null | head -n 1
}

autodock_build_image() {
    require_command docker

    local repo_root
    repo_root=$(_autodock_docker__repo_root)

    local device="$1"
    local dockerfile_relpath
    dockerfile_relpath=$(autodock_select_dockerfile_relpath "$device") || autodock_die ADK010_UNSUPPORTED_DEVICE "$device"

    local image_ref
    image_ref=$(_autodock_docker__image_ref)

    local total_cores
    total_cores=$(nproc 2>/dev/null || echo 1)

    local cuda_arch=""
    if [ "$device" = "DESKTOP_COMPUTER" ]; then
        cuda_arch=$(autodock_detect_cuda_arch)
        if [ -n "$cuda_arch" ]; then
            log_info "Detected CUDA compute capability: $cuda_arch"
        else
            log_warn "Could not detect CUDA compute capability (nvidia-smi unavailable); building with CUDA_ARCH empty"
        fi
    fi

    local dockerfile_abs="$repo_root/$dockerfile_relpath"
    if [ ! -f "$dockerfile_abs" ]; then
        autodock_die ADK011_DOCKERFILE_NOT_FOUND "$dockerfile_abs"
    fi

    log_info "Building image: $image_ref"
    log_info "Using Dockerfile: $dockerfile_relpath"

    docker build \
        -t "$image_ref" \
        -f "$dockerfile_abs" \
        "$repo_root" \
        --build-arg UID="$(id -u)" \
        --build-arg GID="$(id -g)" \
        --build-arg USER_NAME="${AUTODOCK_BUILD_USER_NAME:-user}" \
        --build-arg CUDA_ARCH="$cuda_arch" \
        --build-arg MAX_JOBS="$total_cores"

    log_success "Build completed: $image_ref"
}
