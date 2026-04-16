#!/bin/bash

# ADK110_REPO_SRC_DIR_MISSING

autodock_error_ADK110_REPO_SRC_DIR_MISSING() {
    local repo_root="${1:-}"

    cat <<EOF
Repository src/ directory not found

Expected path:
  ${repo_root%/}/src

Why this happens:
  AutoDock assumes a repository layout with a top-level src/ directory and mounts it to /home/user/src.

Fix:
  - Run AutoDock from the correct repository (so AUTODOCK_REPO_ROOT points to the repo that contains src/)
  - Or export AUTODOCK_REPO_ROOT=/absolute/path/to/your/repo
  - Or adapt your repository layout to include src/
EOF
}
