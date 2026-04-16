#!/bin/bash

# ADK010_UNSUPPORTED_DEVICE

autodock_error_ADK010_UNSUPPORTED_DEVICE() {
    local device="${1:-<unknown>}"

    cat <<EOF
Unsupported device type: $device

Why this happens:
  AutoDock selects a Dockerfile based on a small set of supported device types.

Supported device types:
  - DESKTOP_COMPUTER
  - RASPBERRY_PI
  - JETSON_NANO
  - JETSON_ORIN_NANO

Fix:
  - If you're on a new/unsupported board, add a detection rule in AutoDock/libraries/host/devices.sh
  - Or build using the desktop Dockerfile (AutoDock/dockerfiles/Dockerfile) on a compatible host
EOF
}
