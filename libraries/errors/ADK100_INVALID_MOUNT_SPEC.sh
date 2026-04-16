#!/bin/bash

# ADK100_INVALID_MOUNT_SPEC

autodock_error_ADK100_INVALID_MOUNT_SPEC() {
    local spec="${1:-}"

    cat <<EOF
Invalid mount spec

Got:
  $spec

Expected format:
  HOST_PATH:CONTAINER_PATH[:ro]

Examples:
  --mount /mnt/data:/home/user/data
  --mount /mnt/weights:/home/user/weights:ro
EOF
}
