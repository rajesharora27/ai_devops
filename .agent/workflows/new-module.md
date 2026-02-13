---
description: Create DAP GraphQL Module
---

# Workflow: Create DAP GraphQL Module
Trigger: /new-module

## Steps
1. **Scaffold:** Create `backend/src/modules/[module-name]/`.
2. **Skill (IO):** Generate `service.ts` (Prisma CRUD) and `schema.ts` (GraphQL Types).
3. **Rule (Logic):** Generate `logic.ts` (or a file in `/rules`) for any business validation.
4. **Orchestration:** Generate `resolver.ts` to bridge the Rule and the Skill.
5. **Wiring:** Update the main GraphQL schema and export via `index.ts`.
6. **Verification:** Run `npm run typecheck` and the **Sentinel** AST scan.
