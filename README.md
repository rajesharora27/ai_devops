# AI Governance Repo

This repository is the single source of truth for all AI governance assets:
- `.agent/` (skills, rules, workflows, prompts)
- `.cursorrules`
- `.cursor/rules/ai-governance.mdc`
- `.vscode/settings.json`
- `AGENTS.md`, `CLAUDE.md`, `opencode.json`
- Linker scripts in `scripts/`

## Quick Start (link a client repo)

```bash
# From the governance repo
scripts/bootstrap_link.sh /path/to/client/repo
```

This will:
- set `ai.governanceRoot` for the client repo
- set `core.hooksPath` to `.githooks` (if present)
- link all governance files into the client repo

## Manual linking

```bash
scripts/link_ai_governance.sh --source ~/dev/ai_governance --env /path/to/client/repo --force
```

## Hooks
Client repos run `scripts/ensure_governance_links.sh` on `post-checkout`, `post-merge`, and `post-rewrite` to keep symlinks current.
