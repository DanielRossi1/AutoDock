#!/bin/bash

# ADK001_MISSING_COMMAND

autodock_error_ADK001_MISSING_COMMAND() {
    local cmd="${1:-}"

    if [ -z "$cmd" ]; then
        cmd="<unknown>"
    fi

    # Keep guidance Linux-first (AutoDock is Linux-centric).
    if [ "$cmd" = "docker" ]; then
        cat <<EOF
Required command not found: docker

Fix:
  - Install Docker Engine.
  - Ensure the Docker daemon is running.
  - Ensure your user can run docker (e.g., add it to the docker group or use sudo).
EOF
        return 0
    fi

    if [ "$cmd" = "python3" ]; then
        cat <<EOF
Required command not found: python3

Fix:
  - Install Python 3 (package name is often 'python3').
  - Or disable AutoDock structured config (set "ENABLED": false in autodock.config.json).
EOF
        return 0
    fi

    if [ "$cmd" = "getopt" ]; then
        cat <<EOF
Required command not found: getopt

Fix:
  - Install the system package that provides 'getopt' (often 'util-linux' on Debian/Ubuntu).
EOF
        return 0
    fi

    cat <<EOF
Required command not found: $cmd

Fix:
  - Install '$cmd' and ensure it is available in your PATH.
EOF
}
