#!/bin/bash

# ADK002_CONFIG_REQUIRES_PYTHON3

autodock_error_ADK002_CONFIG_REQUIRES_PYTHON3() {
    local config_file="${1:-AutoDock/autodock.config.json}"

    cat <<EOF
AutoDock structured config requires python3

Config file:
  $config_file

Why this happens:
  AutoDock reads its JSON config via a small python3 helper.

Fix:
  - Install python3, then re-run.
  - Or disable the config by setting "ENABLED": false in the config file.
EOF
}
