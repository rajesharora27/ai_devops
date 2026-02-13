---
description: Guide for developing and extending Domain Modules (Product, Customer, etc.)
---

# Domain Development Skill

## Overview

This skill guides the Agent in extending the Core Domain Modules of the DAP application.
All development MUST follow the **Modular Architecture**.

## Architecture Layers

1.  **GraphQL Layer** (`*.resolver.ts`)
    *   Handles incoming requests
    *   Performs Authentication (`requireUser`) & Authorization (`requirePermission`)
    *   Delegates business logic to Services
    *   **Rule:** Never put business logic here.

2.  **Service Layer** (`*.service.ts`)
    *   Contains pure business logic
    *   Interacts with Prisma (DB)
    *   Records Audit Logs (`logAudit`)
    *   Manages Side Effects (e.g., Change Tracking)
    *   **Rule:** Must be reusable and framework-agnostic.

3.  **Data Layer** (`prisma.schema`)
    *   Defines the shape of data
    *   **Rule:** All schema changes require a migration (`npx prisma migrate dev`).

## Common Workflows

### 1. Adding a Field to an Entity

1.  **Modify DB:** Edit `prisma/schema.prisma`.
2.  **Migrate:** Run `npx prisma migrate dev --name add_field_x`.
3.  **Update GraphQL Schema:** Edit `modules/[domain]/[domain].schema.graphql`.
4.  **Update Types:** Edit `modules/[domain]/[domain].types.ts` (if manual types exist).
5.  **Update Service:** Add field to `create`/`update` methods in `[domain].service.ts`.
6.  **Update Validator:** Add validation rule in `[domain].validation.ts`.

### 2. Creating a New Module

Use the standard structure:
```
modules/[new-domain]/
├── [new-domain].schema.graphql
├── [new-domain].resolver.ts
├── [new-domain].service.ts
├── [new-domain].types.ts
├── [new-domain].validation.ts
└── index.ts
```

## Pattern: Complex Logic vs. CRUD

*   **Simple CRUD:** Use `Service` methods directly.
*   **Complex Chains:** Use `Workflows` directory (e.g., `modules/solution/workflows/`).
    *   Example: `AssignSolutionWorkflow` handles strict validation, license sync, and multi-entity creation.

## Testing

*   **Unit Tests:** `modules/[domain]/__tests__/*.service.test.ts`
*   **Integration Tests:** `backend/src/__tests__/integration/` for multi-module flows.
