#!/usr/bin/env bash
set -euo pipefail

QUIET="${AI_OPS_QUIET:-${AI_GOVERNANCE_QUIET:-0}}"
FORCE="${AI_OPS_FORCE:-${AI_GOVERNANCE_FORCE:-1}}"

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
if git config --get ai.opsRoot >/dev/null 2>&1; then
  ROOT="$(git config --get ai.opsRoot)"
elif git config --get ai.governanceRoot >/dev/null 2>&1; then
  ROOT="$(git config --get ai.governanceRoot)"
fi

if [[ -z "$ROOT" && -n "${AI_OPS_ROOT:-}" ]]; then
  ROOT="$AI_OPS_ROOT"
elif [[ -z "$ROOT" && -n "${AI_GOVERNANCE_ROOT:-}" ]]; then
  ROOT="$AI_GOVERNANCE_ROOT"
fi

if [[ -z "$ROOT" ]]; then
  warn "ai-ops: set AI_OPS_ROOT (or AI_GOVERNANCE_ROOT) or git config ai.opsRoot to enable auto-linking."
  exit 0
fi

if [[ ! -d "$ROOT" ]]; then
  warn "ai-ops: governance root not found: $ROOT"
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FORCE_FLAG=""
if [[ "$FORCE" == "1" ]]; then
  FORCE_FLAG="--force"
fi

if [[ ! -x "$REPO_ROOT/scripts/link_ai_governance.sh" ]]; then
  warn "ai-ops: link script not found: $REPO_ROOT/scripts/link_ai_governance.sh"
  exit 0
fi

log "ai-ops: linking from $ROOT into $REPO_ROOT"
"$REPO_ROOT/scripts/link_ai_governance.sh" --source "$ROOT" --project "$REPO_ROOT" $FORCE_FLAG
