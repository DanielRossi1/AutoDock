#!/bin/bash

# ADK102_INVALID_DIR_ARG

autodock_error_ADK102_INVALID_DIR_ARG() {
    local raw="${1:-}"

    cat <<EOF
Invalid -d/--dir argument

Got:
  $raw

Why this happens:
  AutoDock only accepts existing host directories for -d/--dir.

Fix:
  - Ensure the directory exists on the host.
  - Prefer passing an absolute path.
EOF
}
