#!/bin/bash
# -------------------------------------------
# Stability VC - Uninstall Script
# -------------------------------------------
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info() { echo -e "${GREEN}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()  { echo -e "${RED}[ERROR]${NC} $*" 1>&2; }

MODE="status"
DRY_RUN="false"

usage(){
  cat <<EOF
Usage: $(basename "$0") [mode] [--dry-run]

Modes:
  complete     Remove hook, config, and logs
  hook         Remove only .git/hooks/post-commit
  config       Remove only stability-vc/config and logs
  status       Show what would be removed

Options:
  --dry-run    Show actions without deleting
EOF
}

case "${1:-}" in
  complete|hook|config|status) MODE="$1"; shift || true ;;
  -h|--help) usage; exit 0 ;;
  *) : ;;
esac

if [[ "${1:-}" == "--dry-run" ]]; then DRY_RUN="true"; fi

GIT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
HOOK_PATH="$GIT_ROOT/.git/hooks/post-commit"
CONF_DIR="$GIT_ROOT/stability-vc"
LOG_DIR="$GIT_ROOT/stability-vc/logs"

info "Repository root: $GIT_ROOT"

remove_path(){
  local path="$1"
  if [[ -e "$path" ]]; then
    if [[ "$DRY_RUN" == "true" ]]; then
      echo "Would remove: $path"
    else
      rm -rf "$path"
      echo "Removed: $path"
    fi
  else
    echo "Not found: $path"
  fi
}

case "$MODE" in
  status)
    echo "Hook:   $HOOK_PATH $( [[ -f "$HOOK_PATH" ]] && echo '[present]' || echo '[missing]' )"
    echo "Config: $CONF_DIR   $( [[ -d "$CONF_DIR" ]] && echo '[present]' || echo '[missing]' )"
    echo "Logs:   $LOG_DIR    $( [[ -d "$LOG_DIR" ]] && echo '[present]' || echo '[missing]' )"
    ;;
  hook)
    remove_path "$HOOK_PATH"
    ;;
  config)
    remove_path "$CONF_DIR"
    ;;
  complete)
    remove_path "$HOOK_PATH"
    remove_path "$CONF_DIR"
    ;;
  *) usage; exit 1 ;;
esac

info "Uninstall '$MODE' finished."
