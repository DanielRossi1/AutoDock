#!/bin/bash

# ADK003_CONFIG_JSON_INVALID

autodock_error_ADK003_CONFIG_JSON_INVALID() {
    local config_file="${1:-AutoDock/autodock.config.json}"

    cat <<EOF
AutoDock config is not valid JSON

Config file:
  $config_file

Fix:
  - Ensure the file is valid JSON (no trailing commas / comments).
  - You can validate with:
      python3 -m json.tool "$config_file" >/dev/null
EOF
}
