---
description: Business Logic Invariants & Constraints
---

# Business Rules

> **Purpose:** Define inviolable business logic constraints.

## 1. Data Integrity

- **Soft Deletes:** All primary entities (Product, Task, etc.) used `deletedAt` timestamp. NEVER hard delete from DB unless explicitly authorized by `SuperAdmin`.
- **Audit Trails:** All mutations MUST record an audit log entry via `logAudit`.

## 2. Telemetry & Scoring

- **V2 Schema:** All new telemetry MUST use the `ProductTelemetrySchema` (or Solution equivalent) with strict typing.
- **Scoring:** Success expressions MUST evaluate to a BOOLEAN.
- **Attributes:** Attribute names are case-insensitive but stored preserving case.

## 3. Licensing

- **Levels:** 'Essential' < 'Advantage' < 'Signature'.
- **Inheritance:** Higher license levels include all features of lower levels.

## 4. Import/Export

- **Atomicity:** Imports MUST use interactive transactions. Either all records succeed or all fail (rollback).
- **Validation:** All imports MUST pass strict `zod` validation before DB attempt.
- **Fallback:** Legacy unquoted attributes in expressions MUST be supported via string matching fallback (Regressed fixed Jan 2026).
