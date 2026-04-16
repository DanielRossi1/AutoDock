#!/bin/bash

# ADK101_MOUNT_HOST_PATH_NOT_FOUND

autodock_error_ADK101_MOUNT_HOST_PATH_NOT_FOUND() {
    local host_path="${1:-}"
    local spec="${2:-}"

    cat <<EOF
Mount host path does not exist

Host path:
  $host_path

Mount spec:
  $spec

Fix:
  - Check the path on the host (typos / permissions).
  - If you intended a relative path, run AutoDock from the directory where that relative path exists,
    or pass an absolute path.
EOF
}
