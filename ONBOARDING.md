# central_ai_ops Onboarding

## Goal
Use one global AI baseline for all repos, while keeping project-specific overrides in each project repo.
For multiple IDE clones of the same project, you can optionally keep project overrides in one canonical project repo and symlink from clones.

## Naming Convention
- Global files include `global-` prefix.
- Project files include the project name, for example `dap-AGENTS.md`.

## Project Layout (after bootstrap)
- `.ai_ops/global` -> symlink to `central_ai_ops/global`
- `.ai_ops/project/<project>/<project>-AGENTS.md`
- `.ai_ops/project/<project>/<project>-CLAUDE.md`
- `.ai_ops/project/<project>/<project>-cursor.md`
- `.ai_ops/project/<project>/<project>-opencode.md`
- `.agent/rules/project/<project>-project-rules.md`
- `.agent/workflows/project/<project>-project-workflow.md`

## Precedence
1. Global baseline from `.ai_ops/global/*`
2. Project overlays from `.ai_ops/project/<project>/*`
3. Project local runtime rules from `.agent/*/project/*`

Project-specific files override global files on conflict.

## Bootstrap
```bash
cd ~/dev/central_ai_ops
scripts/bootstrap_link.sh /path/to/project/repo
```

## Bootstrap With Canonical Project Source
```bash
cd ~/dev/central_ai_ops
scripts/bootstrap_link.sh --project-source /path/to/canonical/project/repo /path/to/ide/clone/repo
```

When `--project-source` is set, these project-local paths are linked from the canonical repo:
- `.ai_ops/project/<project>`
- `.agent/rules/project`
- `.agent/workflows/project`
- `.agent/skills/project`
- `.cursor/rules/<project>-cursor-overrides.mdc`

## Hook-based Sync
Bootstrap installs:
- `.githooks/post-checkout`
- `.githooks/post-merge`
- `.githooks/post-rewrite`

Each hook runs:
```bash
bash scripts/ensure_governance_links.sh
```

## Manual Sync
```bash
cd /path/to/project/repo
bash scripts/ensure_governance_links.sh
```

`ensure_governance_links.sh` reads these git configs if present:
- `ai.opsRoot` (required for central root)
- `ai.projectSource` (optional for canonical project override source)
