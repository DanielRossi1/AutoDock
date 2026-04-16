#!/bin/bash

# ADK120_ENV_FILE_NOT_FOUND

autodock_error_ADK120_ENV_FILE_NOT_FOUND() {
    local env_file="${1:-}"

    cat <<EOF
--env-file not found

Path:
  $env_file

Fix:
  - Ensure the file exists on the host.
  - If you passed a relative path, it is resolved from your current working directory when running ./run.sh.
EOF
}
