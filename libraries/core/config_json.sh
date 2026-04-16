#!/bin/bash

# Structured JSON config loader for AutoDock.
#
# Config file is always read. If top-level "ENABLED" is true, its values are
# applied as defaults (lower priority than env/CLI).

autodock_config_file_path() {
    if [ -n "${AUTODOCK_CONFIG_FILE:-}" ]; then
        echo "$AUTODOCK_CONFIG_FILE"
        return 0
    fi

    if [ -n "${AUTODOCK_ROOT:-}" ]; then
        echo "$AUTODOCK_ROOT/autodock.config.json"
        return 0
    fi

    local autodock_root
    autodock_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    echo "$autodock_root/autodock.config.json"
}

_autodock_config__file_claims_enabled() {
    local config_file="$1"
    grep -Eq '"ENABLED"[[:space:]]*:[[:space:]]*true' "$config_file" 2>/dev/null
}

_autodock_config__fail() {
    local code="$1"
    shift || true

    if declare -F autodock_die >/dev/null 2>&1; then
        autodock_die "$code" "$@"
    fi
    if declare -F die >/dev/null 2>&1; then
        die "[$code] $*"
    fi
    echo "[$code] $*" >&2
    exit 1
}

autodock_config_is_enabled() {
    local config_file
    config_file=$(autodock_config_file_path)

    [ -f "$config_file" ] || return 1

    if ! command -v python3 >/dev/null 2>&1; then
        if _autodock_config__file_claims_enabled "$config_file"; then
            _autodock_config__fail ADK002_CONFIG_REQUIRES_PYTHON3 "$config_file"
        fi
        return 1
    fi

    local enabled
    enabled=$(python3 - "$config_file" <<'PY'
import json, sys
path = sys.argv[1]
with open(path, 'r', encoding='utf-8') as f:
    cfg = json.load(f)
print('1' if cfg.get('ENABLED') is True else '0')
PY
) || _autodock_config__fail ADK003_CONFIG_JSON_INVALID "$config_file"

    [ "$enabled" = "1" ]
}

autodock_config_apply_default_overrides() {
    local config_file
    config_file=$(autodock_config_file_path)

    if ! autodock_config_is_enabled; then
        return 0
    fi

    # Update only known keys to avoid unintended side effects.
    local overrides
    overrides=$(python3 - "$config_file" <<'PY'
import json, os, shlex, sys

path = sys.argv[1]
base_dir = os.path.dirname(path)

with open(path, 'r', encoding='utf-8') as f:
    cfg = json.load(f)

if cfg.get('ENABLED') is not True:
    sys.exit(0)

allowed = {
    'AUTODOCK_IMAGE_NAME_DEFAULT',
    'AUTODOCK_IMAGE_TAG_DEFAULT',
    'AUTODOCK_CONTAINER_NAME_DEFAULT',
    'AUTODOCK_BUILD_USER_NAME_DEFAULT',
    'AUTODOCK_SHM_SIZE_DEFAULT',
    'AUTODOCK_WORKDIR_DEFAULT',
    'AUTODOCK_NETWORK_MODE_DEFAULT',
    'AUTODOCK_LOG_LEVEL',
    'AUTODOCK_LOG_FILE',
}

for key in allowed:
    if key not in cfg or cfg[key] is None:
        continue
    val = cfg[key]

    if key == 'AUTODOCK_LOG_FILE' and isinstance(val, str) and not os.path.isabs(val):
        val = os.path.normpath(os.path.join(base_dir, val))

    if isinstance(val, bool):
        val = 'true' if val else 'false'
    else:
        val = str(val)

    print(f"{key}={shlex.quote(val)}")
PY
) || _autodock_config__fail ADK003_CONFIG_JSON_INVALID "$config_file"

    eval "$overrides"
}

autodock_config_get_run_args() {
    local config_file
    config_file=$(autodock_config_file_path)

    if ! autodock_config_is_enabled; then
        return 0
    fi

    local out
    out=$(python3 - "$config_file" <<'PY'
import json, os, sys

path = sys.argv[1]
base_dir = os.path.dirname(path)

with open(path, 'r', encoding='utf-8') as f:
    cfg = json.load(f)

if cfg.get('ENABLED') is not True:
    sys.exit(0)

run = cfg.get('RUN') or {}

def norm_path(p: str) -> str:
    if os.path.isabs(p):
        return p
    return os.path.normpath(os.path.join(base_dir, p))

def emit(*args):
    for a in args:
        if '\n' in a:
            raise SystemExit(f"Config produced an invalid argument containing a newline: {a!r}")
        print(a)

# Optional run-time overrides
if run.get('image'):
    emit('--image', str(run['image']))
if run.get('tag'):
    emit('--tag', str(run['tag']))
if run.get('name'):
    emit('--name', str(run['name']))
if run.get('run_user'):
    emit('--user', str(run['run_user']))
if run.get('build_user_name'):
    emit('--build-user-name', str(run['build_user_name']))
if run.get('workdir'):
    emit('--workdir', str(run['workdir']))
if run.get('shm_size'):
    emit('--shm-size', str(run['shm_size']))
if run.get('network'):
    emit('--network', str(run['network']))

# Core toggles
if run.get('rebuild'):
    emit('--rebuild')
if run.get('no_build'):
    emit('--no-build')
if run.get('no_rm'):
    emit('--no-rm')
if run.get('detach'):
    emit('--detach')
if run.get('no_gpu'):
    emit('--no-gpu')

# Devices
if run.get('audio'):
    emit('--audio')
if run.get('hid'):
    emit('--hid')
if run.get('peripherals'):
    emit('--peripherals')
if run.get('webcam'):
    emit('--webcam')

# Mounts
for d in run.get('dirs') or []:
    emit('--dir', norm_path(str(d)))

if run.get('data'):
    emit('--data', norm_path(str(run['data'])))

for m in run.get('mounts') or []:
    m = str(m)
    if ':' not in m:
        raise SystemExit(f"Invalid mount spec in config (expected HOST:CONTAINER[:ro]): {m}")
    host, rest = m.split(':', 1)
    if not os.path.isabs(host):
        host = norm_path(host)
        m = f"{host}:{rest}"
    emit('--mount', m)

if run.get('ssh'):
    emit('--ssh')
if run.get('ssh_agent'):
    emit('--ssh-agent')
if run.get('gitconfig'):
    emit('--gitconfig')
if run.get('cache'):
    emit('--cache')

# Environment
env = run.get('env') or {}
for kv in env.get('set') or []:
    emit('--env', str(kv))
for key in env.get('pass') or []:
    emit('--env-pass', str(key))
for fpath in env.get('files') or []:
    emit('--env-file', norm_path(str(fpath)))

# Ports
for p in run.get('ports') or []:
    emit('--port', str(p))
PY
) || _autodock_config__fail ADK003_CONFIG_JSON_INVALID "$config_file"

    if [ -n "$out" ]; then
        printf '%s\n' "$out"
    fi
}

autodock_config_get_command() {
    local config_file
    config_file=$(autodock_config_file_path)

    if ! autodock_config_is_enabled; then
        return 0
    fi

    local out
    out=$(python3 - "$config_file" <<'PY'
import json, sys

path = sys.argv[1]
with open(path, 'r', encoding='utf-8') as f:
    cfg = json.load(f)

if cfg.get('ENABLED') is not True:
    sys.exit(0)

run = cfg.get('RUN') or {}
cmd = run.get('command') or []

if not isinstance(cmd, list):
    raise SystemExit('RUN.command must be an array of strings')

for a in cmd:
    a = str(a)
    if '\n' in a:
        raise SystemExit(f"Config produced an invalid command argument containing a newline: {a!r}")
    print(a)
PY
) || _autodock_config__fail ADK003_CONFIG_JSON_INVALID "$config_file"

    if [ -n "$out" ]; then
        printf '%s\n' "$out"
    fi
}
