#!/bin/bash

# AutoDock explicit build workflow.

if [ -z "${AUTODOCK_ROOT:-}" ]; then
    AUTODOCK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi

source "$AUTODOCK_ROOT/libraries/core/config.sh"
source "$AUTODOCK_ROOT/libraries/core/config_json.sh"
source "$AUTODOCK_ROOT/libraries/core/logging.sh"
source "$AUTODOCK_ROOT/libraries/core/errors.sh"
source "$AUTODOCK_ROOT/libraries/host/devices.sh"
source "$AUTODOCK_ROOT/libraries/docker/docker.sh"

autodock_build_main() {
    autodock_config_apply_default_overrides
    autodock_config_init

    require_command docker

    local device
    device=$(detect_hostdevice_type)
    log_info "Detected device: $device"

    autodock_build_image "$device"
}
