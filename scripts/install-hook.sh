#!/bin/bash

# -------------------------------------------
# Stability VC - Install Git Hook
# Installs post-commit hook and configuration into a Git repository
# -------------------------------------------
set -euo pipefail

# Colors
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
err() { echo -e "${RED}[ERROR]${NC} $*" 1>&2; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_CONFIG="$PROJECT_ROOT/config/stability-config.sh"
SOURCE_HOOK="$PROJECT_ROOT/hooks/post-commit"

# Defaults
TARGET_REPO=""
NETWORK=""
ENDPOINT=""
API_KEY=""
CONTRACT=""
PROJECT_NAME=""
NON_INTERACTIVE="false"

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --target <path>         Target git repository path (defaults to current git repo)
  -n, --network <net>     Network: mainnet | testnet
  -e, --endpoint <url>    ZKT endpoint URL (overrides network default)
  -k, --api-key <key>     Stability API key (optional)
  -c, --contract <addr>   Contract address (0x...)
  -p, --project <name>    Project name label
  --non-interactive       Do not prompt; use defaults/flags
  -h, --help              Show this help
EOF
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET_REPO="$2"; shift 2 ;;
    -n|--network) NETWORK="$2"; shift 2 ;;
    -e|--endpoint) ENDPOINT="$2"; shift 2 ;;
    -k|--api-key) API_KEY="$2"; shift 2 ;;
    -c|--contract) CONTRACT="$2"; shift 2 ;;
    -p|--project) PROJECT_NAME="$2"; shift 2 ;;
    --non-interactive) NON_INTERACTIVE="true"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) err "Unknown option: $1"; usage; exit 1 ;;
  esac
done

# Resolve target repo
if [[ -n "$TARGET_REPO" ]]; then
  GIT_ROOT="$(cd "$TARGET_REPO" && git rev-parse --show-toplevel)"
else
  GIT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
  if [[ -z "$GIT_ROOT" ]]; then
    err "Not inside a git repository. Use --target <path> or run inside a repo."
    exit 1
  fi
fi

log "Target repository: $GIT_ROOT"

# Validate sources
[[ -f "$SOURCE_CONFIG" ]] || { err "Missing template config: $SOURCE_CONFIG"; exit 1; }
[[ -f "$SOURCE_HOOK" ]] || { err "Missing hook file: $SOURCE_HOOK"; exit 1; }

# Prepare target dirs
TARGET_CONFIG_DIR="$GIT_ROOT/stability-vc/config"
TARGET_LOGS_DIR="$GIT_ROOT/stability-vc/logs"
TARGET_HOOK="$GIT_ROOT/.git/hooks/post-commit"
mkdir -p "$TARGET_CONFIG_DIR" "$TARGET_LOGS_DIR"

# Copy config template
cp "$SOURCE_CONFIG" "$TARGET_CONFIG_DIR/stability-config.sh"

# Decide defaults
if [[ -z "$NETWORK" ]]; then
  if [[ "$NON_INTERACTIVE" == "true" ]]; then
    NETWORK="mainnet"
  else
    read -rp "Stability Network [mainnet/testnet] (mainnet): " NETWORK
    NETWORK=${NETWORK:-mainnet}
  fi
fi

if [[ -z "$ENDPOINT" ]]; then
  if [[ "$NETWORK" == "testnet" ]]; then
    ENDPOINT="https://rpc.testnet.stabilityprotocol.com/zkt"
  else
    ENDPOINT="https://rpc.stabilityprotocol.com/zkt"
  fi
fi

# Update config safely (sed or fallback)
CONFIG_FILE="$TARGET_CONFIG_DIR/stability-config.sh"
update_config_sed() {
  sed -i.bak \
    -e "s|^export STABILITY_ZKT_ENDPOINT=.*$|export STABILITY_ZKT_ENDPOINT=\"$ENDPOINT\"|" \
    -e "s|^export STABILITY_NETWORK=.*$|export STABILITY_NETWORK=\"$NETWORK\"|" \
    -e "s|^export STABILITY_CONTRACT_ADDRESS=.*$|export STABILITY_CONTRACT_ADDRESS=\"${CONTRACT:-0x0000000000000000000000000000000000000000}\"|" \
    -e "s|^export STABILITY_API_KEY=.*$|export STABILITY_API_KEY=\"$API_KEY\"|" \
    -e "s|^export PROJECT_NAME=.*$|export PROJECT_NAME=\"${PROJECT_NAME:-}\"|" \
    "$CONFIG_FILE" || return 1
  rm -f "$CONFIG_FILE.bak"
}

update_config_fallback() {
  awk -v endpoint="$ENDPOINT" -v net="$NETWORK" -v key="$API_KEY" -v contract="${CONTRACT:-0x0000000000000000000000000000000000000000}" -v project="${PROJECT_NAME:-}" '
    BEGIN{e=endpoint;n=net;k=key;c=contract;p=project}
    /^export STABILITY_ZKT_ENDPOINT=/{print "export STABILITY_ZKT_ENDPOINT=\"" e "\""; next}
    /^export STABILITY_NETWORK=/{print "export STABILITY_NETWORK=\"" n "\""; next}
    /^export STABILITY_CONTRACT_ADDRESS=/{print "export STABILITY_CONTRACT_ADDRESS=\"" c "\""; next}
    /^export STABILITY_API_KEY=/{print "export STABILITY_API_KEY=\"" k "\""; next}
    /^export PROJECT_NAME=/{print "export PROJECT_NAME=\"" p "\""; next}
    {print}
  ' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
}

if command -v sed >/dev/null 2>&1; then
  update_config_sed || update_config_fallback
else
  update_config_fallback
fi

# Install hook
cp "$SOURCE_HOOK" "$TARGET_HOOK"
chmod +x "$TARGET_HOOK" || true

# Rewrite paths inside hook to point at repo-local stability-vc dirs
if command -v sed >/dev/null 2>&1; then
  sed -i.bak \
    -e 's|../config/stability-config.sh|../../stability-vc/config/stability-config.sh|g' \
    -e 's|../logs/stability-hook.log|../../stability-vc/logs/stability-hook.log|g' \
    "$TARGET_HOOK" || true
  rm -f "$TARGET_HOOK.bak"
fi

log "Hook installed: $TARGET_HOOK"
log "Config written: $CONFIG_FILE"
log "Logs directory: $TARGET_LOGS_DIR"

# Summary
cat <<EOF

Installation complete.
- Network:    $NETWORK
- Endpoint:   $ENDPOINT
- Contract:   ${CONTRACT:-0x0000000000000000000000000000000000000000}
- Project:    ${PROJECT_NAME:-}

Next steps:
- Make a commit in $GIT_ROOT to trigger blockchain submission
- View logs: stability-vc/logs/stability-hook.log
EOF
