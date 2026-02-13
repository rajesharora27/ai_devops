---
description: SRW Refactor
---

# Workflow: SRW Refactor
Trigger: /refactor

## Mission
Extract 'fat' logic from Skills (services) into Pure Rules.

## Steps
1. **Audit:** Scan `service.ts` files for complex `if/else` or data transformations.
2. **Extract:** Move that logic into a corresponding `logic.ts` or `rules/` file.
3. **Simplify:** Refactor the `service.ts` to be a pure Prisma wrapper (Stateless Skill).
4. **Test:** Run `npm test` to ensure the logic still holds after the move.