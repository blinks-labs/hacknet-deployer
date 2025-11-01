#!/bin/bash

# Simple YAML in-place setter for config_p2p/config_p2p.yml (macOS/BSD sed compatible)
# Usage examples:
#   ./scripts/set_config.sh mesh_degree_target 12
#   ./scripts/set_config.sh rlnc_shard_factor 8
#   ./scripts/set_config.sh forward_shard_threshold 0.6
#   ./scripts/set_config.sh node_mode gossipsub
# Then:
#   make upload_config && make deploy

set -euo pipefail

KEY="$1" || { echo "Missing KEY"; exit 1; }
VAL="$2" || { echo "Missing VAL"; exit 1; }

CFG="config_p2p/config_p2p.yml"

case "$KEY" in
  node_mode)
    # under sidecar.node_mode (preserve trailing comments) - use Python for better regex
    python3 -c "
import re
with open('${CFG}', 'r') as f:
    content = f.read()
content = re.sub(r'^(  node_mode:)\s*\"?[a-zA-Z]+\"?(.*)$', r'\1 \"${VAL}\"\2', content, flags=re.MULTILINE)
with open('${CFG}', 'w') as f:
    f.write(content)
"
    ;;
  mesh_degree_target|mesh_degree_min|mesh_degree_max|rlnc_shard_factor)
    sed -E -i '' "s#^(\s*${KEY}:)\s*[0-9]+#\\1 ${VAL}#" "$CFG"
    ;;
  forward_shard_threshold|publisher_shard_multiplier)
    sed -E -i '' "s#^(\s*${KEY}:)\s*[0-9]+(\.[0-9]+)?#\\1 ${VAL}#" "$CFG"
    ;;
  max_message_size_bytes|random_message_size_bytes)
    sed -E -i '' "s#^(\s*${KEY}:)\s*[0-9]+#\\1 ${VAL}#" "$CFG"
    ;;
  *)
    echo "Unsupported key: ${KEY}" >&2
    exit 2
    ;;
esac

echo "Updated ${KEY} -> ${VAL} in ${CFG}"


