#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/bootstrap_link.sh [--project-source PATH] /path/to/project/repo [more repos...]

Bootstraps layered AI ops for each project repo:
- sets ai.opsRoot and ai.governanceRoot git config keys
- optionally sets ai.projectSource for cross-clone project override sync
- installs auto-sync git hooks (.githooks/post-checkout|post-merge|post-rewrite)
- links global baseline from central_ai_ops
- scaffolds project-local override files, or links them from project-source
USAGE
}

PROJECT_SOURCE_INPUT="${AI_PROJECT_SOURCE:-}"
TARGETS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-source)
      PROJECT_SOURCE_INPUT="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      TARGETS+=("$1")
      shift
      ;;
  esac
done

if [[ ${#TARGETS[@]} -lt 1 ]]; then
  usage
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LINKER="$ROOT/scripts/link_ai_governance.sh"
PROJECT_SOURCE_REAL=""

if [[ -n "$PROJECT_SOURCE_INPUT" ]]; then
  if [[ ! -d "$PROJECT_SOURCE_INPUT" ]]; then
    echo "Project source path not found: $PROJECT_SOURCE_INPUT" >&2
    exit 1
  fi
  PROJECT_SOURCE_REAL="$(cd "$PROJECT_SOURCE_INPUT" && pwd)"
fi

if [[ ! -x "$LINKER" ]]; then
  echo "Missing linker: $LINKER" >&2
  exit 1
fi

install_hook() {
  local target_repo="$1"
  local hook_name="$2"
  local hook_path="$target_repo/.githooks/$hook_name"

  mkdir -p "$target_repo/.githooks"
  cat <<'HOOK' > "$hook_path"
#!/usr/bin/env bash
set -euo pipefail
if [[ -x scripts/ensure_governance_links.sh ]]; then
  AI_OPS_QUIET=1 AI_OPS_FORCE=1 bash scripts/ensure_governance_links.sh || true
fi
HOOK
  chmod +x "$hook_path"
}

for TARGET in "${TARGETS[@]}"; do
  if [[ ! -d "$TARGET" ]]; then
    echo "Skip (not found): $TARGET" >&2
    continue
  fi

  TARGET_REAL="$(cd "$TARGET" && pwd)"
  echo
  echo "Bootstrapping layered AI ops: $TARGET_REAL"

  if git -C "$TARGET_REAL" rev-parse --git-dir >/dev/null 2>&1; then
    git -C "$TARGET_REAL" config ai.opsRoot "$ROOT"
    git -C "$TARGET_REAL" config ai.governanceRoot "$ROOT"
    if [[ -n "$PROJECT_SOURCE_REAL" ]]; then
      git -C "$TARGET_REAL" config ai.projectSource "$PROJECT_SOURCE_REAL"
    fi

    install_hook "$TARGET_REAL" post-checkout
    install_hook "$TARGET_REAL" post-merge
    install_hook "$TARGET_REAL" post-rewrite

    git -C "$TARGET_REAL" config core.hooksPath .githooks
  else
    echo "Warning: $TARGET_REAL is not a git repo (skipping git config)"
  fi

  LINK_ARGS=(--source "$ROOT" --project "$TARGET_REAL" --force)
  if [[ -n "$PROJECT_SOURCE_REAL" ]]; then
    LINK_ARGS+=(--project-source "$PROJECT_SOURCE_REAL")
  fi

  "$LINKER" "${LINK_ARGS[@]}"
done

echo
echo "Bootstrap complete."
