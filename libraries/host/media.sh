#!/bin/bash

import_directory() {
    if [ -z "${1:-}" ]; then
        return 1
    fi

    if [ ! -d "$1" ]; then
        return 1
    fi

    echo "$1"
}
