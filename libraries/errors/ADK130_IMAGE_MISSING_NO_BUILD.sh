#!/bin/bash

# ADK130_IMAGE_MISSING_NO_BUILD

autodock_error_ADK130_IMAGE_MISSING_NO_BUILD() {
    local image_ref="${1:-}"

    cat <<EOF
Docker image not found (and --no-build was set)

Image:
  $image_ref

Fix:
  - Run ./build.sh first, or
  - Re-run without --no-build so AutoDock can auto-build the image.
EOF
}
