---
name: Feature Implementation Protocol
description: Comprehensive prompt for implementing or modifying features across the full stack.
---

# Feature Implementation Protocol

**Goal**: Implement a new feature or modify an existing one with ZERO regressions and COMPLETE stack coverage.

## 1. Analysis Phase (MANDATORY)
Before writing any code, analyze the request and map it to the stack layers **and** supporting app subsystems:

1.  **Database (Prisma)**:
    - Does the schema need new models, fields, or relations?
    - **Check**: `backend/prisma/schema.prisma`
2.  **Backend Logic (Service/Validation)**:
    - What business logic is needed?
    - **CRITICAL**: Update Zod validation schemas (`*.validation.ts`).
    - **Check**: `backend/src/modules/*/`
3.  **API Layer (GraphQL)**:
    - Does `typeDefs` need new fields/mutations?
    - Do `resolvers` need updates to return new data?
    - **Check**: `backend/src/modules/*/`
4.  **Frontend Data (GraphQL)**:
    - Update `queries.ts` to fetch new fields.
    - Update `mutations.ts` to send/receive new fields.
    - **Check**: `frontend/src/features/*/graphql/`
5.  **Frontend UI (Components)**:
    - Update forms, tables, and displays.
    - Ensure types (`types.ts`) match the new schema.
6.  **Rules / Workflows / Skills (if applicable)**:
    - Are there policy updates in `/rules` or `.agent/rules`?
    - Do any orchestrations in `/workflows` or `.agent/workflows` change?
    - Do any helper skills in `/skills` or `.agent/skills` need updates?
7.  **Permissions / RBAC / Feature Flags**:
    - Do resolver/service guards or RBAC policies need updates?
    - Is the UI gated by permissions/flags?
8.  **Config / Env / Integrations / Jobs**:
    - New config keys or environment variables?
    - Background jobs, webhooks, imports/exports, telemetry?
9.  **Observability / Audit / Analytics**:
    - Logging, audit trails, metrics, or dashboards?
10. **Tests / Docs / Changelog**:
    - Unit, integration, E2E coverage and documentation updates.

## 2. Coverage Checklist (MUST mark each as Yes / No / N/A)
*Use this to ensure no layer is skipped.*

- [ ] Database/Prisma schema + migrations
- [ ] Seed/data migration scripts (if data shape changes)
- [ ] Backend services + Zod validation
- [ ] GraphQL typeDefs + resolvers
- [ ] Frontend GraphQL queries/mutations + types
- [ ] Frontend UI components + state
- [ ] Rules / Workflows / Skills (if policy logic changes)
- [ ] Permissions / RBAC / feature flags
- [ ] Config / env / runtime settings
- [ ] Background jobs / webhooks / imports / telemetry
- [ ] Caching / derived data / search indexing
- [ ] Observability / audit logging
- [ ] Tests (unit/integration/E2E)
- [ ] Docs / release notes / changelog

## 3. Implementation Order
Execute changes in this STRICT order to maintain stability:

1.  **Database**: Update `schema.prisma` -> `npx prisma migrate dev` -> `npx prisma generate`.
2.  **Rules/Workflows/Skills**: Update policy files or orchestrations if business logic moved.
3.  **Backend Types**: Update Zod validation (`CreateSchema`, `UpdateSchema`) and TypeScript interfaces.
4.  **Backend Logic**: Implement Service methods and Resolvers (include permissions/guards).
5.  **GraphQL Schema**: Update `typeDefs`.
6.  **Verification (Backend)**: Verify API returns expected data (GraphQL Playground).
7.  **Frontend Data**: Update Queries/Mutations/Types.
8.  **Frontend UI**: Update Components and permission/feature-flag gating.
9.  **Config/Jobs/Integrations**: Update config/env, workers, webhooks, telemetry.
10. **Tests/Docs**: Add or update coverage and documentation.

## 4. The "Zero-Regression" Checklist
*Auto-verify these points after implementation:*

- [ ] **Zod Sync**: Did I add the new field to **BOTH** `CreateSchema` and `UpdateSchema` in `validation.ts`? (Most common bug!)
- [ ] **GraphQL Sync**: Does the `typeDefs` match the `schema.prisma`?
- [ ] **Data Flow**: Did I add the field to the Frontend `query`? If I save it, do I return it in the `mutation` response?
- [ ] **Type Safety**: Did I regenerate Prisma Client? Are frontend types updated?
- [ ] **Array Handling**: If adding a list/array, did I use a multi-select UI and handle `createMany`/`deleteMany` in the service?
- [ ] **Permissions**: Are resolver/service guards updated for new fields/actions?
- [ ] **Rules/Workflows**: Did I update any rule/workflow logic that enforces this feature?

## 5. Execution Prompt
*Copy this prompt to start the work:*

> I am starting the implementation of [FEATURE NAME].
>
> **Coverage Checklist (mark Yes / No / N/A):**
> - Database/Prisma:
> - Migrations/Seed data:
> - Backend services + validation:
> - GraphQL typeDefs/resolvers:
> - Frontend GraphQL:
> - Frontend UI:
> - Rules/Workflows/Skills:
> - Permissions/RBAC/feature flags:
> - Config/env/runtime settings:
> - Jobs/webhooks/integrations/telemetry:
> - Caching/derived data:
> - Observability/audit logging:
> - Tests:
> - Docs/changelog:
>
> **Plan:**
> 1.  **Database**: [List changes to schema.prisma]
> 2.  **Rules/Workflows**: [Policy/workflow changes, if any]
> 3.  **Validation**: [Confirm Zod schema file to update]
> 4.  **GraphQL**: [List changes to typeDefs/resolvers]
> 5.  **Frontend**: [List changes to queries/components]
> 6.  **Config/Jobs/Permissions**: [Anything else]
>
> Proceeding with **Step 1: Database Logic**...
