# Feature Change Protocol

**This rule is MANDATORY for all feature additions and modifications.**

---

## Core Principle

**Every feature change must update ALL related layers in the stack.**

The DAP application is a full-stack TypeScript application with:
- **Database**: PostgreSQL via Prisma ORM
- **Backend**: Node.js + GraphQL + Apollo Server
- **Frontend**: React + TypeScript + Apollo Client

Changes propagate through this stack: Database → Backend Service → GraphQL → Frontend

---

## Mandatory Checks

When adding or modifying ANY feature, you MUST verify:

### 1. ✅ Prisma Schema Updated
- Fields added to models in `backend/prisma/schema.prisma`
- Join tables created for many-to-many relationships
- `npx prisma generate` run to update Prisma Client

### 2. ✅ Zod Validation Schemas Updated
**⚠️ THIS IS THE #1 SOURCE OF BUGS**

Location: `backend/src/modules/*/?.validation.ts`

- [ ] New fields added to `CreateSchema`
- [ ] New fields added to `UpdateSchema`
- [ ] Correct type: `z.string()`, `z.array(z.string())`, `z.number()`, etc.
- [ ] Optional fields marked: `.optional()`

**Without this, fields are silently stripped during validation!**

### 3. ✅ GraphQL Schema Updated
Location: `backend/src/modules/*/?.typeDefs.ts`

- [ ] Fields added to types
- [ ] Fields added to input types
- [ ] Resolvers added for computed/relational fields

### 4. ✅ Service Layer Updated
Location: `backend/src/modules/*/?.service.ts`

- [ ] Create methods handle new fields
- [ ] Update methods handle new fields
- [ ] Associations created/deleted (for array fields)
- [ ] Field extraction includes new fields

### 5. ✅ Frontend GraphQL Updated
Location: `frontend/src/features/*/graphql/`

- [ ] **Queries** include new fields in response
- [ ] **Mutations** include new fields in input
- [ ] **Mutations** include new fields in response
- [ ] Types match backend schema

### 6. ✅ Frontend UI Updated
Location: `frontend/src/features/*/components/`

- [ ] Form fields added for new data
- [ ] State management includes new fields
- [ ] Data sent to mutation includes new fields
- [ ] Data loaded from query includes new fields
- [ ] Multi-select used for array fields

### 7. ✅ Rules / Workflows / Skills Updated (If Policy Logic Changes)
- [ ] Update rules in `/rules` or `.agent/rules` (source of truth)
- [ ] Sync governance rules to `backend/config` if required
- [ ] Update workflow orchestration in `/workflows` or `.agent/workflows`
- [ ] Update any skill helpers in `/skills` or `.agent/skills`

### 8. ✅ Permissions / RBAC / Feature Flags Updated
- [ ] Add/adjust resolver/service permission guards
- [ ] Update RBAC policies if new actions are introduced
- [ ] Gate UI actions with permissions or feature flags

### 9. ✅ Config / Env / Integrations / Jobs Updated (If Applicable)
- [ ] Add new config keys or env vars (document defaults)
- [ ] Update background jobs/cron tasks if affected
- [ ] Update webhooks/integrations/telemetry payloads

### 10. ✅ Observability / Tests / Docs Updated (If Applicable)
- [ ] Add/adjust audit logging where needed
- [ ] Update unit/integration/E2E tests
- [ ] Update `./dap-test` to include any new test suites/commands and refresh its help text
- [ ] Update documentation/changelog for feature impact

---

## Red Flags - Common Mistakes

### 🚨 Missing Zod Validation Field
**Problem**: Field in GraphQL schema but not in Zod schema
**Result**: Data silently stripped, not saved to database
**Fix**: Add field to both `CreateSchema` and `UpdateSchema`

### 🚨 Query Doesn't Fetch New Field
**Problem**: Added field to database but not to GraphQL query
**Result**: Frontend shows old/empty data
**Fix**: Add field to query fragment

### 🚨 Mutation Doesn't Return New Field
**Problem**: Mutation saves data but doesn't return updated field
**Result**: Frontend cache stale, shows old data
**Fix**: Add field to mutation response

### 🚨 Single-Select for Array Field
**Problem**: Using single-select dropdown for multi-value field
**Result**: User can only select one item when multiple allowed
**Fix**: Use multi-select (Autocomplete, Chip, Select multiple)

### 🚨 Not Creating Join Table Records
**Problem**: Many-to-many field added but service doesn't create associations
**Result**: Data not linked, queries return empty
**Fix**: Add `createMany` logic in service layer

### 🚨 Prisma Client Not Regenerated
**Problem**: Schema changed but `npx prisma generate` not run
**Result**: TypeScript errors, missing types
**Fix**: Always run `npx prisma generate` after schema changes

---

## Verification Steps

After making changes, verify the complete data flow:

1. **Frontend sends data** → Check browser console/network tab
2. **GraphQL receives data** → Check GraphQL Playground
3. **Validation passes data** → Check backend logs
4. **Service processes data** → Check backend logs
5. **Database stores data** → Check with SQL query
6. **Query returns data** → Check GraphQL Playground
7. **Frontend displays data** → Check browser UI

---

## AI Agent Instructions

When implementing a feature change, follow this workflow:

1. **Read** `@.agent/workflows/feature-change-checklist.md`
2. **List** all components that need changes
3. **Make changes** in order: Database → Backend → GraphQL → Frontend
4. **Verify** each layer before moving to next
5. **Test** end-to-end data flow
6. **Review** common pitfalls checklist

**NEVER** skip the Zod validation schema update!

For a step-by-step AI Prompt, see: `@.agent/prompts/feature-implementation.md`

---

## Example Workflow

```typescript
// 1. Database (Prisma)
model Task {
  licenses TaskLicense[]  // Add relation
}

model TaskLicense {       // Add join table
  taskId    String
  licenseId String
  task      Task    @relation(...)
  license   License @relation(...)
}

// 2. Run migration
// $ npx prisma generate

// 3. Backend Validation (⚠️ CRITICAL)
export const UpdateTaskSchema = z.object({
  licenseIds: z.array(z.string()).optional()  // ADD THIS!
});

// 4. Backend Service
if (licenseIds !== undefined) {
  await prisma.taskLicense.deleteMany({ where: { taskId: id } });
  await prisma.taskLicense.createMany({
    data: licenseIds.map(lid => ({ taskId: id, licenseId: lid }))
  });
}

// 5. GraphQL Schema
type Task {
  licenses: [License!]!  // Add field
}

input TaskUpdateInput {
  licenseIds: [ID!]       // Add input
}

// 6. GraphQL Resolver
licenses: async (parent) => {
  const tl = await prisma.taskLicense.findMany({
    where: { taskId: parent.id },
    include: { license: true }
  });
  return tl.map(x => x.license);
}

// 7. Frontend Query
query Tasks {
  tasks {
    licenses { id name }  // ADD THIS!
  }
}

// 8. Frontend Mutation
mutation UpdateTask($input: TaskUpdateInput!) {
  updateTask(input: $input) {
    licenses { id name }  // ADD THIS!
  }
}

// 9. Frontend UI
const [selectedLicenses, setSelectedLicenses] = useState([]);
// Load: task.licenses.map(l => l.id)
// Save: { licenseIds: selectedLicenses }
// UI: <Autocomplete multiple ... />
```

---

## Enforcement

This rule must be followed for:
- ✅ All feature additions
- ✅ All feature modifications
- ✅ All data model changes
- ✅ All GraphQL schema changes
- ✅ All UI changes that affect data

**No exceptions.**

---

**See**: `@.agent/workflows/feature-change-checklist.md` for detailed checklist
