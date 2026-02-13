---
name: Core Governance Rules
description: Mandatory protocols for all AI agents (Codex, Cursor, Antigravity)
---

# 🛡️ Component Consistency Protocol

**Activation**: MANDATORY for every Bug Fix, Refactor, or Feature Change.

## The Rule of "All Layers"
When you modify logic in *any* layer, you MUST verify the impact and consistency across **ALL** other layers before marking the task as complete.

### 1. Database Layer (Constraint Check)
- **If you change data/schema**: Does the migration exist? Is `schema.prisma` synced?
- **If you change logic**: Does the data support this new logic? (e.g., Flags like `includesAllLicenseFeatures`).

### 2. Backend Layer (Source of Truth)
- **Service Logic**: Is the business logic centralized? Is it consistent with the Rule of Truth?
- **Validation**: Did you update Zod schemas?
- **Resolvers**: Did you update the GraphQL return object to map new fields?

### 3. API Layer (Contract)
- **Schema**: Is the new field exposed in `typeDefs`?
- **Consistency**: Do the query returns match the TypeDef?

### 4. Frontend Layer (Consumption)
- **Queries**: Are you fetching the new field?
- **Logic**: Are client-side filters/logic aware of the new flag/rule? **(Crucial Step)**
- **UI**: Is the user interface reflecting the new state?

## 🚫 The "Partial Fix" Prohibition
You are STRICTLY PROHIBITED from fixing a bug in one layer (e.g., Backend) without explicitly verifying the consuming layer (e.g., Frontend).

**Example Violation**:
> "I fixed the backend to send the flag, so it works."
> *...but the Frontend filter ignored the flag and hid the data.*

**Required Workflow**:
1. Fix Backend.
2. Search Frontend codebase for relevant logic (filters, conditions).
3. Verify Frontend handles the new Backend state correctly.
4. Only THEN is the task done.

## SRW + Repo Hygiene Enforcement (MANDATORY)
- Run `bash scripts/srw-audit.sh --staged` before every commit.
- Run `bash scripts/repo-clean-audit.sh --staged` before every commit.
- Keep service files (`*.service.ts`/`*.service.js`) as thin adapters with no branching logic.
- Keep rules (`*/rules/*`) pure: no network/filesystem/database/env reads.
- Never track runtime env files (`.env*`, except `.env.example`) or generated artifacts (`coverage`, `test-results`, `playwright-report`, `tmp/test-logs`, `*.log`, `*.pid`, `.DS_Store`).

These checks are enforced in `.githooks/pre-commit` and `.githooks/pre-push`. Do not bypass unless there is an emergency and documented rollback path.
