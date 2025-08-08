#!/bin/bash
# -------------------------------------------
# Stability VC - Verify Commits Helper
# -------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$PROJECT_ROOT/config/stability-config.sh"

if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
else
  echo "[ERROR] Config not found: $CONFIG_FILE" >&2
  exit 1
fi

COMMIT="${1:-}" # optional commit hash

if [[ -z "$COMMIT" ]]; then
  COMMIT=$(git rev-parse HEAD)
fi

echo "Verifying commit on Stability blockchain"
echo "Network: ${STABILITY_NETWORK:-unknown}"
echo "Endpoint: ${STABILITY_ZKT_ENDPOINT:-unknown}"
echo "Contract: ${STABILITY_CONTRACT_ADDRESS:-unset}"
echo "Commit:   $COMMIT"

# Compute repository snapshot hash to compare with on-chain record
if command -v sha256sum >/dev/null 2>&1; then
  CODEBASE_HASH=$(git archive "$COMMIT" | sha256sum | awk '{print $1}')
elif command -v shasum >/dev/null 2>&1; then
  CODEBASE_HASH=$(git archive "$COMMIT" | shasum -a 256 | awk '{print $1}')
else
  echo "[WARN] No sha256 tool available. Skipping local hash calculation."
  CODEBASE_HASH=""
fi

echo "Local codebase hash: ${CODEBASE_HASH:-<unavailable>}"

echo
echo "Attempting on-chain check (requires contract test helper)..."
if bash "$SCRIPT_DIR/deploy-contract.sh" test "${STABILITY_CONTRACT_ADDRESS:-0x0000000000000000000000000000000000000000}" "${STABILITY_NETWORK:-mainnet}" | cat; then
  echo "[INFO] Contract test completed."
else
  echo "[WARN] Contract test failed or unavailable."
fi

echo
echo "Next steps:"
echo "- Inspect logs: stability-vc/logs/stability-hook.log"
echo "- Query contract using your preferred tool to fetch stored commit by hash"
