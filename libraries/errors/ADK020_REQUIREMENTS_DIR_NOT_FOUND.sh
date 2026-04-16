#!/bin/bash

# ADK020_REQUIREMENTS_DIR_NOT_FOUND

autodock_error_ADK020_REQUIREMENTS_DIR_NOT_FOUND() {
    local requirements_dir="${1:-}"

    cat <<EOF
Requirements directory not found

Expected path:
  $requirements_dir

Why this happens:
  AutoDock assumes your repository layout includes: src/requirements/

Fix:
  - Check that your project has a src/requirements directory.
  - Or set AUTODOCK_REPO_ROOT to the repository root that contains src/.
EOF
}
