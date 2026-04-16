#!/bin/bash

# ADK011_DOCKERFILE_NOT_FOUND

autodock_error_ADK011_DOCKERFILE_NOT_FOUND() {
    local dockerfile_path="${1:-}"

    cat <<EOF
Dockerfile not found

Expected path:
  $dockerfile_path

Fix:
  - Ensure you're running AutoDock from the correct repository (AUTODOCK_REPO_ROOT).
  - Ensure the AutoDock folder (and its dockerfiles/) is present.
  - If AutoDock was added as a git submodule, initialize it:
      git submodule update --init --recursive
EOF
}
