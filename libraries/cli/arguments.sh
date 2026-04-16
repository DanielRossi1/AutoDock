#!/bin/bash

# CLI parsing for AutoDock run script.
# Keeps parsing concerns isolated from docker option construction.

autodock_print_help() {
    cat <<'EOF'
Usage:
  ./run.sh [options] [-- <command> [args...]]

Core options:
  -h, --help                 Show this help
  --rebuild                  Force rebuild of the image before running
  --no-build                 Do not auto-build (error if image is missing)
  --no-rm                    Do not remove the container on exit
  --detach                   Run container in background (no TTY)

Container/image:
  --image NAME               Override image name
  --tag TAG                  Override image tag
  --name NAME                Override container name
  --user USER[:GROUP]        Override docker --user
  --build-user-name NAME     Override build-time USER_NAME build-arg
  --workdir DIR              Override docker --workdir
  --shm-size SIZE            Override --shm-size
  --network MODE             Override network mode

Developer mounts:
  -d, --dir DIR              Mount DIR at /home/user/<basename> (repeatable)
      --data DIR             Mount DIR at /home/user/data
      --mount SPEC           Raw mount spec HOST:CONTAINER[:ro] (repeatable)
      --ssh                  Mount ~/.ssh to /home/user/.ssh (read-only)
      --ssh-agent            Forward SSH agent socket (if available)
      --gitconfig            Mount ~/.gitconfig to /home/user/.gitconfig (read-only)
      --cache                Mount common AI caches under /home/user

Devices:
  -a, --audio                Enable audio device mounts (/dev/snd + PulseAudio if available)
  -i, --hid                  Enable HID devices (/dev/hidraw*)
  -p, --peripherals          Enable embedded peripherals (gpio/i2c/spi)
  -w, --webcam               Enable /dev/video* devices
      --no-gpu               Disable GPU runtime options even if detected

Environment:
  -e, --env KEY=VALUE        Add an environment variable (repeatable)
  -E, --env-pass KEY         Pass through host env var KEY (repeatable)
      --env-file FILE        Pass environment variables from FILE

Ports:
  -P, --port HOST:CONTAINER  Publish a port (repeatable; effective for bridge/networked mode)

Examples:
  ./run.sh
  ./run.sh -d /datasets -d /outputs --cache --ssh
  ./run.sh --rebuild -w -a -- python -m pip install -r /home/user/src/requirements/base.txt
EOF
}

autodock_cli_reset() {
    AUTODOCK_CLI_SHOW_HELP=0

    AUTODOCK_CLI_REBUILD=0
    AUTODOCK_CLI_NO_BUILD=0
    AUTODOCK_CLI_NO_RM=0
    AUTODOCK_CLI_DETACH=0

    AUTODOCK_CLI_AUDIO=0
    AUTODOCK_CLI_HID=0
    AUTODOCK_CLI_PERIPHERALS=0
    AUTODOCK_CLI_WEBCAM=0
    AUTODOCK_CLI_ENABLE_GPU=1

    AUTODOCK_CLI_EXTRA_DIRS=()
    AUTODOCK_CLI_EXTRA_MOUNTS=()

    AUTODOCK_CLI_ENV_VARS=()
    AUTODOCK_CLI_ENV_PASS=()
    AUTODOCK_CLI_ENV_FILES=()

    AUTODOCK_CLI_PORTS=()

    AUTODOCK_CLI_MOUNT_SSH=0
    AUTODOCK_CLI_MOUNT_SSH_AGENT=0
    AUTODOCK_CLI_MOUNT_GITCONFIG=0
    AUTODOCK_CLI_MOUNT_CACHES=0

    AUTODOCK_CLI_CMD=()
}

autodock_parse_cli() {
    autodock_cli_reset

    if ! command -v getopt >/dev/null 2>&1; then
        if declare -F autodock_print_error >/dev/null 2>&1; then
            autodock_print_error ADK001_MISSING_COMMAND getopt
        else
            echo "Error: 'getopt' is required but not found" >&2
        fi
        return 1
    fi

    local parsed
    parsed=$(getopt \
        -o 'had:ipwe:E:P:' \
        --long 'help,audio,dir:,hid,peripherals,webcam,env:,env-pass:,env-file:,port:,data:,mount:,ssh,ssh-agent,gitconfig,cache,rebuild,no-build,no-rm,detach,image:,tag:,name:,user:,build-user-name:,workdir:,shm-size:,network:,no-gpu' \
        -n 'run.sh' -- "$@") || return 1

    eval set -- "$parsed"

    while true; do
        case "$1" in
            -h|--help)
                AUTODOCK_CLI_SHOW_HELP=1
                shift
                ;;
            --rebuild)
                AUTODOCK_CLI_REBUILD=1
                shift
                ;;
            --no-build)
                AUTODOCK_CLI_NO_BUILD=1
                shift
                ;;
            --no-rm)
                AUTODOCK_CLI_NO_RM=1
                shift
                ;;
            --detach)
                AUTODOCK_CLI_DETACH=1
                shift
                ;;

            --image)
                AUTODOCK_IMAGE_NAME="$2"
                shift 2
                ;;
            --tag)
                AUTODOCK_IMAGE_TAG="$2"
                shift 2
                ;;
            --name)
                AUTODOCK_CONTAINER_NAME="$2"
                shift 2
                ;;
            --user)
                AUTODOCK_RUN_USER="$2"
                shift 2
                ;;
            --build-user-name)
                AUTODOCK_BUILD_USER_NAME="$2"
                shift 2
                ;;
            --workdir)
                AUTODOCK_WORKDIR="$2"
                shift 2
                ;;
            --shm-size)
                AUTODOCK_SHM_SIZE="$2"
                shift 2
                ;;
            --network)
                AUTODOCK_NETWORK_MODE="$2"
                shift 2
                ;;

            -a|--audio)
                AUTODOCK_CLI_AUDIO=1
                shift
                ;;
            -d|--dir)
                AUTODOCK_CLI_EXTRA_DIRS+=("$2")
                shift 2
                ;;
            -i|--hid)
                AUTODOCK_CLI_HID=1
                shift
                ;;
            -p|--peripherals)
                AUTODOCK_CLI_PERIPHERALS=1
                shift
                ;;
            -w|--webcam)
                AUTODOCK_CLI_WEBCAM=1
                shift
                ;;
            --no-gpu)
                AUTODOCK_CLI_ENABLE_GPU=0
                shift
                ;;

            --data)
                AUTODOCK_CLI_EXTRA_MOUNTS+=("$2:/home/user/data")
                shift 2
                ;;
            --mount)
                AUTODOCK_CLI_EXTRA_MOUNTS+=("$2")
                shift 2
                ;;
            --ssh)
                AUTODOCK_CLI_MOUNT_SSH=1
                shift
                ;;
            --ssh-agent)
                AUTODOCK_CLI_MOUNT_SSH_AGENT=1
                shift
                ;;
            --gitconfig)
                AUTODOCK_CLI_MOUNT_GITCONFIG=1
                shift
                ;;
            --cache)
                AUTODOCK_CLI_MOUNT_CACHES=1
                shift
                ;;

            -e|--env)
                AUTODOCK_CLI_ENV_VARS+=("$2")
                shift 2
                ;;
            -E|--env-pass)
                AUTODOCK_CLI_ENV_PASS+=("$2")
                shift 2
                ;;
            --env-file)
                AUTODOCK_CLI_ENV_FILES+=("$2")
                shift 2
                ;;

            -P|--port)
                AUTODOCK_CLI_PORTS+=("$2")
                shift 2
                ;;

            --)
                shift
                AUTODOCK_CLI_CMD=("$@")
                break
                ;;
            *)
                echo "Internal parsing error: $1" >&2
                return 1
                ;;
        esac
    done

    return 0
}
