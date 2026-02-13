#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/link_ai_governance.sh [--source PATH] [--env PATH ...] [--force]

Links governance files from a single source repo into multiple environment clones.

Options:
  --source, -s   Path to the governance repo root (defaults to this repo)
  --env, -e      Target environment repo path (repeatable)
  --force        Replace existing paths instead of backing them up
  --help, -h     Show this help

Examples:
  scripts/link_ai_governance.sh --source ~/dev/dap-governance \
    --env ~/dev/codex/dap --env ~/dev/cursor/dap

  AI_GOVERNANCE_ROOT=~/dev/dap-governance scripts/link_ai_governance.sh
USAGE
}

SOURCE_ROOT="${AI_GOVERNANCE_ROOT:-}" 
FORCE=0
TARGETS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source|-s)
      SOURCE_ROOT="$2"
      shift 2
      ;;
    --env|-e)
      TARGETS+=("$2")
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "${SOURCE_ROOT}" ]]; then
  SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

if [[ ${#TARGETS[@]} -eq 0 ]]; then
  TARGETS=(
    "$HOME/dev/antigravity/dap"
    "$HOME/dev/cursor/dap"
    "$HOME/dev/codex/dap"
    "$HOME/dev/opencode/dap"
    "$HOME/dev/claude/dap"
  )
fi

SOURCE_ROOT_REAL="$(cd "$SOURCE_ROOT" && pwd)"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

link_path() {
  local target="$1"
  local source="$2"

  if [[ -L "$target" ]]; then
    local current
    current="$(readlink "$target")"
    if [[ "$current" == "$source" ]]; then
      echo "✅ Already linked: $target -> $source"
      return
    fi
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    if [[ "$FORCE" -eq 1 ]]; then
      rm -r "$target"
    else
      mv "$target" "${target}.bak.${TIMESTAMP}"
      echo "🧷 Backed up: $target -> ${target}.bak.${TIMESTAMP}"
    fi
  fi

  mkdir -p "$(dirname "$target")"
  ln -s "$source" "$target"
  echo "🔗 Linked: $target -> $source"
}

for ENV_PATH in "${TARGETS[@]}"; do
  if [[ ! -d "$ENV_PATH" ]]; then
    echo "⚠️  Skip (not found): $ENV_PATH"
    continue
  fi

  ENV_REAL="$(cd "$ENV_PATH" && pwd)"
  if [[ "$ENV_REAL" == "$SOURCE_ROOT_REAL" ]]; then
    echo "ℹ️  Skip source repo: $ENV_PATH"
    continue
  fi

  echo "\n🏗️  Linking governance into: $ENV_PATH"

  link_path "$ENV_PATH/.agent" "$SOURCE_ROOT/.agent"
  link_path "$ENV_PATH/.cursorrules" "$SOURCE_ROOT/.cursorrules"
  link_path "$ENV_PATH/.cursor/rules" "$SOURCE_ROOT/.cursor/rules"
  link_path "$ENV_PATH/.cursor/skills" "$SOURCE_ROOT/.agent/skills"
  link_path "$ENV_PATH/.vscode/settings.json" "$SOURCE_ROOT/.vscode/settings.json"
  link_path "$ENV_PATH/AGENTS.md" "$SOURCE_ROOT/AGENTS.md"
  link_path "$ENV_PATH/opencode.json" "$SOURCE_ROOT/opencode.json"
  link_path "$ENV_PATH/CLAUDE.md" "$SOURCE_ROOT/CLAUDE.md"
  link_path "$ENV_PATH/scripts/link_ai_governance.sh" "$SOURCE_ROOT/scripts/link_ai_governance.sh"
  link_path "$ENV_PATH/scripts/ensure_governance_links.sh" "$SOURCE_ROOT/scripts/ensure_governance_links.sh"

done

echo "\n✅ Governance linking complete."
