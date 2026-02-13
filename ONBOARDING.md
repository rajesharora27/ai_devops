# central_ai_ops Onboarding

## Goal
Use one global AI baseline for all repos, while keeping project-specific overrides in each project repo.

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
