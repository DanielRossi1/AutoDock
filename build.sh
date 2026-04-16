#!/bin/bash

set -euo pipefail

AUTODOCK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export AUTODOCK_ROOT

AUTODOCK_REPO_ROOT="$(cd "$AUTODOCK_ROOT/.." && pwd)"
export AUTODOCK_REPO_ROOT

AUTODOCK_CALLER_DIR="$(pwd)"
export AUTODOCK_CALLER_DIR

source "$AUTODOCK_ROOT/libraries/apps/build_app.sh"

autodock_build_main "$@"
