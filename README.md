# central_ai_ops

Central AI operations framework with a layered model:
- Global baseline in this repo (`global/*`)
- Project-specific overrides in each project repo (`.ai_ops/project/<project>/*`, `.agent/*/project/*`)
- Optional canonical project source to sync project overrides across IDE clones

## Directory Structure
- `global/global-AGENTS.md` - Global AGENTS baseline
- `global/global-CLAUDE.md` - Global Claude baseline
- `global/global-opencode.md` - Global OpenCode baseline
- `global/rules/global-*.md` - Global rule set
- `global/workflows/global-*.md` - Global workflow set
- `global/cursor/global-cursor-*.md|*.mdc` - Global Cursor baseline
- `scripts/bootstrap_link.sh` - Bootstraps any project repo
- `scripts/link_ai_governance.sh` - Applies layered links + scaffolding
- `scripts/ensure_governance_links.sh` - Hook-safe sync for client repos

## Precedence
1. Global baseline from `global/*`
2. Project overrides from `.ai_ops/project/<project>/*`
3. Project runtime rules and workflows from `.agent/*/project/*`

Project-level content overrides global content when conflict exists.

## Bootstrap a Project
```bash
cd ~/dev/central_ai_ops
scripts/bootstrap_link.sh /path/to/project/repo
```

## Canonical Project Source (single-place project overrides)
Use this when you have multiple IDE clones of one project and want one canonical place for project-specific edits:
```bash
cd ~/dev/central_ai_ops
scripts/bootstrap_link.sh --project-source /path/to/canonical/project/repo /path/to/ide/clone/repo
```

The target clone keeps local entry files (`AGENTS.md`, `CLAUDE.md`, `.cursorrules`, `opencode.json`) but links project overrides from the canonical repo.

## Ongoing Sync
Client repos auto-sync via git hooks. Manual sync is also available:
```bash
cd /path/to/project/repo
bash scripts/ensure_governance_links.sh
```
