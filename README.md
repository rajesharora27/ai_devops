# central_ai_ops

Central AI operations framework with a layered model:
- Global baseline in this repo (`global/*`)
- Project-specific overrides in each project repo (`.ai_ops/project/<project>/*`, `.agent/*/project/*`)

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

## Bootstrap a Project
```bash
cd ~/dev/central_ai_ops
scripts/bootstrap_link.sh /path/to/project/repo
```

## Ongoing Sync
Client repos auto-sync via git hooks. Manual sync is also available:
```bash
cd /path/to/project/repo
bash scripts/ensure_governance_links.sh
```
