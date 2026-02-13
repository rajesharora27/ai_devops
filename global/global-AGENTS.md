# Global AI Instructions

Apply this global baseline to all projects.

## Global Priorities
- Keep changes small, testable, and reversible.
- Prefer primary sources and project-local evidence over assumptions.
- Preserve existing architecture unless a change request explicitly authorizes redesign.
- Avoid duplicating business logic across layers.

## Global Policy Sources
- `.ai_ops/global/rules/global-core-governance.md`
- `.ai_ops/global/rules/global-change-safety.md`
- `.ai_ops/global/rules/global-quality-gates.md`
- `.ai_ops/global/rules/global-conflict-resolution.md`
- `.ai_ops/global/workflows/global-implementation-checklist.md`

## Precedence Model
Project overrides are loaded after global rules and win on conflict.
- Project overlay entrypoint: `.ai_ops/project/project-AGENTS.md`
- Project local rules: `.agent/rules/project/*.md`
- Project local workflows: `.agent/workflows/project/*.md`
- Project local skills: `.agent/skills/project/*`
