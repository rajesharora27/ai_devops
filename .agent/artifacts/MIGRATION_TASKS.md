# Antigravity Migration Task List

**Status:** Completed
**Started:** January 21, 2026
**Finished:** January 21, 2026

## Phase 1: Context Savings (High Impact, Low Complexity)

- [x] **Externalize Seed Data** (Completed)
    - [x] Create `.agent/rules/seed-data.json`.
    - [x] Refactor `backend/src/scripts/seed.ts`.
    - [x] Fix `package.json` entry.

## Phase 2: Logic Extraction (Rules & Skills)

- [x] **Externalize RBAC Policy** (Completed)
    - [x] Create `.agent/rules/rbac-policy.json`.
    - [x] Refactor `permissions.ts` to use JSON-based hierarchy.
    - [x] Convert logic into `PERMISSION_CHECKER.md` skill.
- [x] **Externalize Telemetry Logic** (Completed)
    - [x] Create `.agent/rules/telemetry-logic.json`.
    - [x] Refactor `EvaluatorRegistry.ts` to use JSON-based normalization.
    - [x] Convert logic into `TELEMETRY_EVALUATOR.md` skill.

## Phase 3: Workflow Automation

- [x] **Automate Database Seeding** (Completed)
    - [x] Create `.agent/workflows/seed-db.md`.
- [x] **Automate Module Creation** (Completed)
    - [x] Create `.agent/workflows/create-module.md`.

---
**Migration Successful.** The agentic brain has been successfully extracted into Rules and Skills, and standard operations are now automated via Workflows.
