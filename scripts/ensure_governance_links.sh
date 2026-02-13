#!/usr/bin/env bash
set -euo pipefail

QUIET="${AI_GOVERNANCE_QUIET:-0}"

log() {
  if [[ "$QUIET" != "1" ]]; then
    echo "$@"
  fi
}

warn() {
  if [[ "$QUIET" != "1" ]]; then
    echo "$@" >&2
  fi
}

ROOT=""
FORCE="${AI_GOVERNANCE_FORCE:-1}"
FORCE_FLAG=""
if git config --get ai.governanceRoot >/dev/null 2>&1; then
  ROOT="$(git config --get ai.governanceRoot)"
fi

if [[ -z "$ROOT" && -n "${AI_GOVERNANCE_ROOT:-}" ]]; then
  ROOT="$AI_GOVERNANCE_ROOT"
fi

if [[ -z "$ROOT" ]]; then
  warn "ai-governance: set AI_GOVERNANCE_ROOT or git config ai.governanceRoot to enable auto-linking."
  exit 0
fi

if [[ ! -d "$ROOT" ]]; then
  warn "ai-governance: governance root not found: $ROOT"
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

log "ai-governance: linking from $ROOT into $REPO_ROOT"
if [[ "$FORCE" == "1" ]]; then
  FORCE_FLAG="--force"
fi

if [[ ! -x "$REPO_ROOT/scripts/link_ai_governance.sh" ]]; then
  warn "ai-governance: link script not found: $REPO_ROOT/scripts/link_ai_governance.sh"
  exit 0
fi

"$REPO_ROOT/scripts/link_ai_governance.sh" --source "$ROOT" --env "$REPO_ROOT" $FORCE_FLAG
