#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/link_ai_governance.sh [--source PATH] [--project PATH ...] [--project-source PATH] [--force]

Sets up a layered AI governance model:
- Global baseline from central repo (`.ai_ops/global`)
- Project overrides stored in project repo (`.ai_ops/project/<project>` + `.agent/*/project`)

Options:
  --source, -s   Path to central_ai_ops repo root (defaults to this script's repo)
  --project, -p  Target project repo path (repeatable)
  --env, -e      Backward-compatible alias for --project
  --project-source
                 Optional canonical project repo for project-local overrides.
                 When set, project-local files are linked from this source so
                 local overrides are edited in one place across IDE clones.
  --force        Replace conflicting links/files where safe (does not overwrite project override files)
  --help, -h     Show this help

Examples:
  scripts/link_ai_governance.sh --source ~/dev/central_ai_ops --project ~/dev/dap --force
  scripts/link_ai_governance.sh --project ~/dev/cursor/dap --project-source ~/dev/dap
  scripts/link_ai_governance.sh --project ~/dev/my-app
USAGE
}

SOURCE_ROOT="${AI_OPS_ROOT:-${AI_GOVERNANCE_ROOT:-}}"
PROJECT_SOURCE_ROOT="${AI_PROJECT_SOURCE:-}"
FORCE=0
TARGETS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source|-s)
      SOURCE_ROOT="$2"
      shift 2
      ;;
    --project|-p|--env|-e)
      TARGETS+=("$2")
      shift 2
      ;;
    --project-source)
      PROJECT_SOURCE_ROOT="$2"
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
  TARGETS=("$(pwd)")
fi

SOURCE_ROOT_REAL="$(cd "$SOURCE_ROOT" && pwd)"
if [[ ! -d "$SOURCE_ROOT_REAL/global" ]]; then
  echo "Missing global directory in source root: $SOURCE_ROOT_REAL/global" >&2
  exit 1
fi

PROJECT_SOURCE_REAL=""
if [[ -n "$PROJECT_SOURCE_ROOT" ]]; then
  if [[ ! -d "$PROJECT_SOURCE_ROOT" ]]; then
    echo "Project source path not found: $PROJECT_SOURCE_ROOT" >&2
    exit 1
  fi
  PROJECT_SOURCE_REAL="$(cd "$PROJECT_SOURCE_ROOT" && pwd)"
fi

TIMESTAMP="$(date +%Y%m%d%H%M%S)"

cleanup_legacy_governance() {
  local env_path="$1"

  rm -rf "$env_path/.agents" "$env_path/.skillshare"

  rm -rf \
    "$env_path/.agent.bak."* \
    "$env_path/.cursor.bak."* \
    "$env_path/.cursorrules.bak."* \
    "$env_path/AGENTS.md.bak."* \
    "$env_path/CLAUDE.md.bak."* \
    "$env_path/opencode.json.bak."* \
    "$env_path/.vscode/settings.json.bak."* \
    "$env_path/.ai_ops/global.bak."* \
    "$env_path/scripts/link_ai_governance.sh.bak."* \
    "$env_path/scripts/ensure_governance_links.sh.bak."*

  if [[ -d "$env_path/.cursor" ]]; then
    rm -rf "$env_path/.cursor/"*.bak* 2>/dev/null || true
  fi

  for path in \
    "$env_path/.agent" \
    "$env_path/.cursor" \
    "$env_path/.cursorrules" \
    "$env_path/AGENTS.md" \
    "$env_path/CLAUDE.md" \
    "$env_path/opencode.json"; do
    if [[ -L "$path" ]]; then
      rm "$path"
    fi
  done
}

link_path() {
  local target="$1"
  local source="$2"

  if [[ -L "$target" ]]; then
    local current
    current="$(readlink "$target")"
    if [[ "$current" == "$source" ]]; then
      echo "OK linked: $target -> $source"
      return
    fi
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    if [[ "$FORCE" -eq 1 ]]; then
      rm -rf "$target"
    else
      mv "$target" "${target}.bak.${TIMESTAMP}"
      echo "Backed up: $target -> ${target}.bak.${TIMESTAMP}"
    fi
  fi

  mkdir -p "$(dirname "$target")"
  ln -s "$source" "$target"
  echo "Linked: $target -> $source"
}

write_if_missing() {
  local file_path="$1"
  local content="$2"

  if [[ -e "$file_path" ]]; then
    return
  fi

  mkdir -p "$(dirname "$file_path")"
  printf '%s\n' "$content" > "$file_path"
  echo "Created: $file_path"
}

ensure_project_override_scaffold() {
  local repo_root="$1"
  local project_id="$2"
  local project_dir="$repo_root/.ai_ops/project/$project_id"
  local project_cursor_mdc="$repo_root/.cursor/rules/${project_id}-cursor-overrides.mdc"

  mkdir -p \
    "$repo_root/.ai_ops/project/$project_id" \
    "$repo_root/.agent/rules/project" \
    "$repo_root/.agent/workflows/project" \
    "$repo_root/.agent/skills/project" \
    "$repo_root/.cursor/rules"

  if [[ -f "$repo_root/.cursor/rules/project-overrides.mdc" && ! -f "$project_cursor_mdc" ]]; then
    mv "$repo_root/.cursor/rules/project-overrides.mdc" "$project_cursor_mdc"
    echo "Renamed: $repo_root/.cursor/rules/project-overrides.mdc -> $repo_root/.cursor/rules/${project_id}-cursor-overrides.mdc"
  fi

  write_if_missing "$project_cursor_mdc" "---
description: ${project_id} project overrides
globs: **/*
---
# ${project_id} Project Overrides
- Apply @.ai_ops/project/${project_id}/${project_id}-cursor.md after global rules.
- If conflict exists, project overrides take precedence."

  write_if_missing "$project_dir/${project_id}-AGENTS.md" "# ${project_id} Project AI Instructions

List project-specific instructions here.
These instructions override global instructions when conflict exists."

  write_if_missing "$project_dir/${project_id}-CLAUDE.md" "# ${project_id} Project Claude Instructions

@.agent/rules/project/${project_id}-project-rules.md
@.agent/workflows/project/${project_id}-project-workflow.md

Project instructions override global instructions on conflict."

  write_if_missing "$project_dir/${project_id}-cursor.md" "# ${project_id} Cursor Overrides

Reference project-specific docs and constraints here.
Project-specific constraints override global cursor constraints."

  write_if_missing "$project_dir/${project_id}-opencode.md" "# ${project_id} OpenCode Overrides

Add project-specific OpenCode instructions here.
Project instructions override global instructions when conflict exists."

  write_if_missing "$repo_root/.agent/rules/project/${project_id}-project-rules.md" "# ${project_id} Project Rules

Add project-specific rule logic here.
These rules override global rules on conflict."

  write_if_missing "$repo_root/.agent/workflows/project/${project_id}-project-workflow.md" "# ${project_id} Project Workflow

Add project-specific workflow steps here."
}

for ENV_PATH in "${TARGETS[@]}"; do
  if [[ ! -d "$ENV_PATH" ]]; then
    echo "Skip (not found): $ENV_PATH"
    continue
  fi

  ENV_REAL="$(cd "$ENV_PATH" && pwd)"
  PROJECT_ID="$(basename "$ENV_REAL")"
  PROJECT_SOURCE_FOR_TARGET=""
  USE_PROJECT_SOURCE_LINKS=0

  if [[ -n "$PROJECT_SOURCE_REAL" ]]; then
    PROJECT_ID="$(basename "$PROJECT_SOURCE_REAL")"
    PROJECT_SOURCE_FOR_TARGET="$PROJECT_SOURCE_REAL"
    if [[ "$ENV_REAL" != "$PROJECT_SOURCE_FOR_TARGET" ]]; then
      USE_PROJECT_SOURCE_LINKS=1
    fi
  fi

  PROJECT_DIR="$ENV_REAL/.ai_ops/project/$PROJECT_ID"
  PROJECT_CURSOR_MDC="$ENV_REAL/.cursor/rules/${PROJECT_ID}-cursor-overrides.mdc"

  if [[ "$ENV_REAL" == "$SOURCE_ROOT_REAL" ]]; then
    echo "Skip source repo: $ENV_PATH"
    continue
  fi

  echo
  echo "Configuring layered AI ops in: $ENV_REAL"

  cleanup_legacy_governance "$ENV_REAL"

  mkdir -p \
    "$ENV_REAL/.ai_ops/project" \
    "$ENV_REAL/.agent/rules" \
    "$ENV_REAL/.agent/workflows" \
    "$ENV_REAL/.agent/skills" \
    "$ENV_REAL/.cursor/rules" \
    "$ENV_REAL/.vscode" \
    "$ENV_REAL/scripts"

  link_path "$ENV_REAL/.ai_ops/global" "$SOURCE_ROOT_REAL/global"
  link_path "$ENV_REAL/.agent/rules/global" "$SOURCE_ROOT_REAL/global/rules"
  link_path "$ENV_REAL/.agent/workflows/global" "$SOURCE_ROOT_REAL/global/workflows"
  link_path "$ENV_REAL/.agent/skills/global" "$SOURCE_ROOT_REAL/global/skills"
  link_path "$ENV_REAL/.cursor/rules/global-cursor-rule.mdc" "$SOURCE_ROOT_REAL/global/cursor/global-cursor-rule.mdc"
  link_path "$ENV_REAL/scripts/link_ai_governance.sh" "$SOURCE_ROOT_REAL/scripts/link_ai_governance.sh"
  link_path "$ENV_REAL/scripts/ensure_governance_links.sh" "$SOURCE_ROOT_REAL/scripts/ensure_governance_links.sh"

  write_if_missing "$ENV_REAL/AGENTS.md" "# AI Instructions for ${PROJECT_ID}

Apply instructions in this order:
1. Global baseline: .ai_ops/global/global-AGENTS.md
2. Project overrides: .ai_ops/project/${PROJECT_ID}/${PROJECT_ID}-AGENTS.md

Conflict policy: project overrides win over global instructions.

Also apply policy files from:
- .agent/rules/global/*.md
- .agent/rules/project/*.md
- .agent/workflows/global/*.md
- .agent/workflows/project/*.md
- .agent/skills/global/**/SKILL.md
- .agent/skills/project/**/SKILL.md"

  write_if_missing "$ENV_REAL/CLAUDE.md" "# AI Instructions for ${PROJECT_ID}

@.ai_ops/global/global-CLAUDE.md
@.ai_ops/project/${PROJECT_ID}/${PROJECT_ID}-CLAUDE.md

Project instructions override global instructions on conflict."

  write_if_missing "$ENV_REAL/.cursorrules" "# Cursor Global Baseline
@.ai_ops/global/cursor/global-cursor-reference.md

# Cursor Project Overrides
@.ai_ops/project/${PROJECT_ID}/${PROJECT_ID}-cursor.md

If global and project rules conflict, project rules win."

  write_if_missing "$ENV_REAL/opencode.json" "{
  \"instructions\": [
    \".ai_ops/global/global-opencode.md\",
    \".ai_ops/project/${PROJECT_ID}/${PROJECT_ID}-opencode.md\",
    \".agent/rules/global/*.md\",
    \".agent/rules/project/*.md\",
    \".agent/workflows/global/*.md\",
    \".agent/workflows/project/*.md\",
    \".agent/skills/global/**/SKILL.md\",
    \".agent/skills/project/**/SKILL.md\"
  ]
}"

  write_if_missing "$ENV_REAL/.vscode/settings.json" "{
  \"codex.instructions.path\": \"AGENTS.md\",
  \"codex.context.include\": [
    \".ai_ops/global/global-AGENTS.md\",
    \".ai_ops/project/${PROJECT_ID}/${PROJECT_ID}-AGENTS.md\",
    \".agent/rules/global\",
    \".agent/rules/project\"
  ],
  \"files.exclude\": {
    \"**/node_modules\": true,
    \"**/.git\": true
  }
}"

  if [[ "$USE_PROJECT_SOURCE_LINKS" -eq 1 ]]; then
    ensure_project_override_scaffold "$PROJECT_SOURCE_FOR_TARGET" "$PROJECT_ID"

    link_path "$PROJECT_DIR" "$PROJECT_SOURCE_FOR_TARGET/.ai_ops/project/$PROJECT_ID"
    link_path "$ENV_REAL/.agent/rules/project" "$PROJECT_SOURCE_FOR_TARGET/.agent/rules/project"
    link_path "$ENV_REAL/.agent/workflows/project" "$PROJECT_SOURCE_FOR_TARGET/.agent/workflows/project"
    link_path "$ENV_REAL/.agent/skills/project" "$PROJECT_SOURCE_FOR_TARGET/.agent/skills/project"
    link_path "$PROJECT_CURSOR_MDC" "$PROJECT_SOURCE_FOR_TARGET/.cursor/rules/${PROJECT_ID}-cursor-overrides.mdc"

    echo "Project overrides linked from canonical source: $PROJECT_SOURCE_FOR_TARGET"
  else
    ensure_project_override_scaffold "$ENV_REAL" "$PROJECT_ID"
  fi

done

echo
echo "Layered AI ops linking complete."
