# Global OpenCode Instructions

Use global rules as baseline and project files as overrides.

Load order:
1. `.ai_ops/global/rules/*.md`
2. `.ai_ops/global/workflows/*.md`
3. `.ai_ops/project/project-opencode.md`
4. `.agent/rules/project/*.md`
5. `.agent/workflows/project/*.md`
6. `.agent/skills/project/**/SKILL.md`

Project-local policy overrides global policy on conflict.
