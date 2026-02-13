---
description: Scaffolds a new backend module with Resolver, Service, Schema, and Types.
---

1. Create a new directory in `backend/src/modules/[module-name]`.
2. Generate `schema.ts` using standard GraphQL type definitions for the entity.
3. Generate `service.ts` with basic CRUD operations using Prisma.
4. Generate `resolver.ts` mapping GraphQL queries/mutations to the service.
5. Generate `types.ts` for internal DTOs and interfaces.
6. Generate `index.ts` to export the module components.
7. Register the new module in the main `backend/src/shared/graphql/schema.ts` (or equivalent).

// turbo
8. Run typecheck to ensure the new module is correctly wired.
```bash
cd backend && npm run typecheck
```
