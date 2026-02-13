# Global Conflict Resolution

Precedence order (lowest to highest):
1. Global rules in `.ai_ops/global/*`
2. Project overlays in `.ai_ops/project/*`
3. Project local runtime rules in `.agent/rules/project/*`

When conflict is detected, apply the higher-precedence project rule.
