#!/bin/bash

# ADK103_DIR_BASENAME_COLLISION

autodock_error_ADK103_DIR_BASENAME_COLLISION() {
    local target="${1:-/home/user/<name>}"

    cat <<EOF
Two -d/--dir mounts collide inside the container

Collision target:
  $target

Why this happens:
  AutoDock maps each -d/--dir to /home/user/<basename-of-host-dir>.
  Two different host paths with the same basename collide.

Fix:
  - Use --mount to choose distinct container paths, e.g.:
      --mount /path/A/data:$target-A
      --mount /path/B/data:$target-B
EOF
}
