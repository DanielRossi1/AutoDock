#!/bin/bash

################################################################################
# Script filename: remote.sh
# 
# Description: creates a ssh connection to a remote host and creates a docker context to run docker on the remote host
#
# Author: Daniel Rossi
# Date: 24/05/24
# Version: 1.0
#
# Notes: takes as input: email, remote host username, remote host address, remote host password
#
# Dependencies: 
#   - Docker installed on the remote host and on the local machine
#   - ssh-keygen
#   - ssh server running on the remote host
#
################################################################################
set -euo pipefail

if [ $# -ne 3 ]; then
  echo "Usage: $0 <remote_connection_name> <remote_username> <remote_host_address>"
  exit 1
fi

remote_name="$1"    # es. "prod", "staging", "edge01"
remote_user="$2"    # es. "ubuntu"
remote_host="$3"    # es. "192.168.1.10"

key_base="$HOME/.ssh/${remote_name}_key"

echo "🔑 Generating SSH keypair for '$remote_name'..."
ssh-keygen -t rsa -b 4096 -f "$key_base" -N "" -C "${remote_name}_docker"

echo "🚀 Installing public key on ${remote_user}@${remote_host}..."
cat "${key_base}.pub" | ssh "${remote_user}@${remote_host}" \
  'mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'

echo "📝 Updating SSH config for host alias '$remote_name'..."
ssh_config="$HOME/.ssh/config"

mkdir -p "$(dirname "$ssh_config")"
touch "$ssh_config"

# Rimuovo eventuali vecchi blocchi per questo host
awk -v host="$remote_name" '
  $1=="Host" && $2==host { in_block=1; next }
  in_block && /^Host/     { in_block=0 }
  !in_block               { print }
' "$ssh_config" > "${ssh_config}.tmp" && mv "${ssh_config}.tmp" "$ssh_config"

# Aggiungo il nuovo blocco
cat >> "$ssh_config" <<EOF

Host ${remote_name}
    HostName ${remote_host}
    User ${remote_user}
    IdentityFile ${key_base}
    IdentitiesOnly yes
EOF

chmod 600 "$ssh_config"
chmod 600 "$key_base"

echo "🐳 Creating Docker context '$remote_name'..."
docker context use default
docker context rm "$remote_name" -f 2>/dev/null || true
docker context create "$remote_name" --docker "host=ssh://${remote_name}"
docker context use "$remote_name"

echo "✅ Context '${remote_name}' ready: $(docker --context "$remote_name" ps)"
