#!/bin/bash

# Conda environment generator (host-side utility).

if [ -z "${AUTODOCK_ROOT:-}" ]; then
    AUTODOCK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi

source "$AUTODOCK_ROOT/libraries/core/config.sh"
source "$AUTODOCK_ROOT/libraries/core/config_json.sh"
source "$AUTODOCK_ROOT/libraries/core/logging.sh"
source "$AUTODOCK_ROOT/libraries/core/errors.sh"
source "$AUTODOCK_ROOT/libraries/host/devices.sh"
source "$AUTODOCK_ROOT/libraries/docker/docker.sh"

_check_cuda_in_dockerfile() {
    local dockerfile="$1"
    grep -qi 'cuda' "$dockerfile"
}

_check_pytorch_in_requirements_dir() {
    local requirements_dir="$1"
    grep -Rqs 'torch' "$requirements_dir" 2>/dev/null
}

_fetch_url() {
    local url="$1"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url"
        return $?
    fi
    if command -v wget >/dev/null 2>&1; then
        wget -qO- "$url"
        return $?
    fi

    return 1
}

_detect_python_version_from_dockerfile() {
    local dockerfile="$1"

    # Best-effort: match "python3.X" occurrences and pick the highest X.
    local version
    version=$(grep -oE 'python3\.[0-9]+' "$dockerfile" | sed 's/python//' | sort -Vr | head -n 1 || true)
    echo "$version"
}

autodock_generate_conda_env_main() {
    autodock_config_apply_default_overrides
    autodock_config_init

    local repo_root="${AUTODOCK_REPO_ROOT:-${REPO_ROOT:-}}"
    if [ -z "$repo_root" ]; then
        repo_root="$(cd "$AUTODOCK_ROOT/.." && pwd)"
    fi

    local requirements_dir="$repo_root/src/requirements"
    local out_file="$repo_root/src/environment.yml"

    if [ ! -d "$requirements_dir" ]; then
        autodock_die ADK020_REQUIREMENTS_DIR_NOT_FOUND "$requirements_dir"
    fi

    local device
    device=$(detect_hostdevice_type)
    local dockerfile_rel
    dockerfile_rel=$(autodock_select_dockerfile_relpath "$device") || autodock_die ADK010_UNSUPPORTED_DEVICE "$device"

    local dockerfile_path="$repo_root/$dockerfile_rel"
    if [ ! -f "$dockerfile_path" ]; then
        autodock_die ADK011_DOCKERFILE_NOT_FOUND "$dockerfile_path"
    fi

    local pytorch=0
    local cuda=0
    if _check_pytorch_in_requirements_dir "$requirements_dir"; then
        pytorch=1
    fi
    if _check_cuda_in_dockerfile "$dockerfile_path"; then
        cuda=1
    fi

    local base_image
    base_image=$(awk '$1=="FROM" {print $2; exit}' "$dockerfile_path" || true)
    local os_cuda_version
    os_cuda_version=$(echo "$base_image" | grep -oE 'cuda:[0-9]+\.[0-9]+\.[0-9]+' | cut -d ':' -f 2 || true)

    local python_version
    python_version=$(_detect_python_version_from_dockerfile "$dockerfile_path")

    local cuda_version=""
    if [ -n "$os_cuda_version" ]; then
        local available_json
        available_json=$(_fetch_url "https://api.anaconda.org/package/conda-forge/cudatoolkit" || true)
        if [ -n "$available_json" ]; then
            local best
            best=""
            while read -r v; do
                if [ "$(printf '%s\n%s\n' "$v" "$os_cuda_version" | sort -V | head -n 1)" = "$v" ]; then
                    best="$v"
                fi
            done < <(echo "$available_json" | grep -oE '"version":"[^"]+"' | cut -d '"' -f 4 | sort -V)

            if [ -n "$best" ]; then
                cuda_version="${best%.*}"
            fi
        fi

        if [ -z "$cuda_version" ]; then
            cuda_version="${os_cuda_version%.*}"
        fi
    fi

    local env_name
    env_name=$(basename "$repo_root")

    local environment
    environment="name: $env_name
channels:
  - conda-forge
  - defaults"

    if [ "$pytorch" -eq 1 ]; then
        log_info "PyTorch enabled"
        environment="$environment
  - pytorch"
    fi

    if [ "$cuda" -eq 1 ]; then
        log_info "CUDA enabled"
        environment="$environment
  - nvidia"
    fi

    environment="$environment
dependencies:
  - python${python_version:+=$python_version}
  - pip"

    if [ -n "$cuda_version" ]; then
        environment="$environment
  - cudatoolkit=$cuda_version"
    fi

    environment="$environment
  - pip:"

    shopt -s nullglob
    local req_files=("$requirements_dir"/*)
    shopt -u nullglob

    local req_file
    for req_file in "${req_files[@]}"; do
        while IFS= read -r line; do
            if [[ "$line" =~ ^[A-Za-z0-9_.-]+==[^[:space:]]+ ]]; then
                if echo "$line" | grep -qi "nvidia"; then
                    continue
                fi
                environment="$environment
    - $line"
            fi
        done < "$req_file"
    done

    echo "$environment" > "$out_file"
    log_success "Wrote conda environment: $out_file"
}
