#1. **Use Prompt**: `@.agent/prompts/feature-implementation.md`

**Use this checklist for EVERY feature addition or modification to ensure all components are updated.**

---

## 📋 Pre-Implementation Checklist

- [ ] **Understand the full scope**: What entities/models are affected?
- [ ] **Identify all layers**: Which layers need changes? (Database → Backend → GraphQL → Frontend)
- [ ] **Mark coverage**: For each layer/subsystem, explicitly mark **Yes / No / N/A**
- [ ] **Check dependencies**: What existing features might be affected?
- [ ] **Review existing patterns**: How are similar features implemented?

---

## 🗄️ Database Layer (If data model changes)

### Prisma Schema (`backend/prisma/schema.prisma`)
- [ ] Update or add model definitions
- [ ] Add new fields to existing models
- [ ] Create join tables for many-to-many relationships
- [ ] Add indexes for performance
- [ ] Update enums if needed
- [ ] Check cascade delete behavior

### Migrations
- [ ] Run `npx prisma migrate dev --name descriptive_name` (development)
- [ ] OR run `npx prisma db push` (for quick iteration)
- [ ] Run `npx prisma generate` to update Prisma Client
- [ ] Test rollback if needed
- [ ] Create data migration script if existing data needs transformation

### Verification
- [ ] Check that Prisma Client types are regenerated
- [ ] Verify foreign key constraints
- [ ] Test with sample data

---

## 🔧 Backend Layer

### 1. Service Layer (`backend/src/modules/*/?.service.ts`)
- [ ] Add/update service methods (create, update, delete, query)
- [ ] Handle new field extraction and processing
- [ ] Add business logic for new feature
- [ ] Handle associations/relationships (create/delete related records)
- [ ] Add proper error handling
- [ ] Add logging for critical operations

### 2. Validation Schema (`backend/src/modules/*/?.validation.ts`)
- [ ] ⚠️ **CRITICAL**: Add new fields to Zod schemas
  - [ ] `CreateSchema` - for creation mutations
  - [ ] `UpdateSchema` - for update mutations
  - [ ] Add `.optional()` where appropriate
  - [ ] Add validation rules (min, max, regex, etc.)
- [ ] Export new schemas if needed

### 3. GraphQL Type Definitions (`backend/src/modules/*/?.typeDefs.ts`)
- [ ] Add new types or extend existing types
- [ ] Add new fields to existing types
- [ ] Add field resolvers if needed
- [ ] Add new queries
- [ ] Add new mutations
- [ ] Add new input types
- [ ] Mark deprecated fields with `@deprecated(reason: "...")`
- [ ] Update return types

### 4. GraphQL Resolvers (`backend/src/modules/*/?.resolver.ts`)
- [ ] Add field resolvers for computed/related data
- [ ] Add query resolvers
- [ ] Add mutation resolvers
- [ ] Add permission checks (`requirePermission`, `ensureRole`)
- [ ] Add audit logging where needed
- [ ] Handle pagination if applicable
- [ ] Return complete data including new fields

### 5. Types (`backend/src/modules/*/types.ts`)
- [ ] Add/update TypeScript interfaces
- [ ] Export new types
- [ ] Update existing types

---

## 🌐 GraphQL API Layer

### Schema Consistency
- [ ] Ensure field names match between:
  - Prisma schema (database)
  - GraphQL typeDefs
  - Zod validation schemas
  - Frontend queries
- [ ] Test queries in GraphQL Playground

### Testing GraphQL
- [ ] Test queries return new fields
- [ ] Test mutations accept new fields
- [ ] Test mutations return updated objects with new fields
- [ ] Verify error handling

---

## 🧠 Rules / Workflows / Skills (If Policy Logic Changes)

- [ ] Update rules in `/rules` or `.agent/rules` (source of truth)
- [ ] Sync governance rules to `backend/config` if required
- [ ] Update workflow orchestration in `/workflows` or `.agent/workflows`
- [ ] Update any skill helpers in `/skills` or `.agent/skills`
- [ ] Verify rule/workflow coverage in tests (if applicable)

---

## 🔐 Permissions / Config / Integrations (If Applicable)

### Permissions & RBAC
- [ ] Add/adjust permission guards in resolvers/services
- [ ] Update RBAC policies if new actions are introduced
- [ ] Gate UI actions with permission checks

### Config / Env / Feature Flags
- [ ] Add new config keys or env vars (document defaults)
- [ ] Wire feature flags in backend + frontend (if used)
- [ ] Ensure config is wired in dev/test/prod

### Jobs / Webhooks / Telemetry
- [ ] Update background jobs/cron tasks if affected
- [ ] Update webhooks/integrations (payloads, handlers, retries)
- [ ] Update telemetry/events/analytics for the new feature

---

## 💻 Frontend Layer

### 1. GraphQL Operations (`frontend/src/features/*/graphql/`)

#### Queries (`queries.ts`)
- [ ] Add new fields to existing queries
- [ ] Add new query definitions
- [ ] Include related data (nested objects)
- [ ] Test query returns expected data

#### Mutations (`mutations.ts`)
- [ ] Add new fields to mutation input
- [ ] Add new fields to mutation response
- [ ] Add new mutation definitions
- [ ] Test mutation succeeds

### 2. TypeScript Types (`frontend/src/features/*/types.ts`)
- [ ] Add/update interfaces matching GraphQL types
- [ ] Add new types for components
- [ ] Update existing types

### 3. UI Components

#### Form/Dialog Components
- [ ] Add form fields for new data
- [ ] Add state management (`useState`)
- [ ] Add form validation
- [ ] Handle loading/saving states
- [ ] Add multi-select if array field (Autocomplete, Chip, Select multiple)
- [ ] Initialize with existing data (`useEffect`)
- [ ] Send new fields in save handler
- [ ] Display new fields in view mode

#### Display Components
- [ ] Display new fields in lists/tables
- [ ] Add columns to tables if needed
- [ ] Add filters for new fields
- [ ] Add tooltips/help text
- [ ] Handle empty states

#### Context/State Management
- [ ] Update context providers if needed
- [ ] Update state shape
- [ ] Add actions/reducers

### 4. Styling
- [ ] Add responsive design
- [ ] Match existing UI patterns
- [ ] Add loading indicators
- [ ] Add error states

---

## 🧪 Testing

### Backend Tests
- [ ] Unit tests for service methods
- [ ] Integration tests for GraphQL resolvers
- [ ] E2E tests for complete workflows
- [ ] Test validation schemas
- [ ] Test error cases
- [ ] Test edge cases (empty arrays, null values, etc.)

### Frontend Tests
- [ ] Component tests
- [ ] Integration tests
- [ ] E2E tests
- [ ] Test form validation
- [ ] Test error handling

### Manual Testing
- [ ] Test create operation
- [ ] Test update operation
- [ ] Test delete operation
- [ ] Test with existing data
- [ ] Test with empty data
- [ ] Test error scenarios
- [ ] Test on different browsers
- [ ] Test responsive design
- [ ] Verify permissions/feature flags gating

---

## 📚 Documentation

- [ ] Update API documentation
- [ ] Update README if needed
- [ ] Add code comments for complex logic
- [ ] Update user guide if UI changed
- [ ] Document breaking changes
- [ ] Update CHANGELOG

---

## 🔍 Code Review Checklist

### Before Committing
- [ ] Run linter: `npm run lint`
- [ ] Fix linter errors: `npm run lint:fix`
- [ ] Run type check: `npm run type-check`
- [ ] Build succeeds: `npm run build`
- [ ] Tests pass: `npm test`
- [ ] App runs in dev mode: `./dap dev`

### Data Flow Verification
- [ ] Frontend sends correct data structure
- [ ] GraphQL mutation receives data
- [ ] Validation schema allows data through
- [ ] Service layer processes data correctly
- [ ] Database stores data correctly
- [ ] Query returns data with new fields
- [ ] Frontend displays data correctly
- [ ] Permissions/RBAC allow the new action where intended
- [ ] Rules/workflows (if any) produce expected outcomes

### Common Pitfalls to Check
- [ ] ⚠️ **Zod validation schemas include all new fields**
- [ ] ⚠️ GraphQL queries include new fields in response
- [ ] ⚠️ GraphQL mutations include new fields in response
- [ ] ⚠️ Frontend components read new fields from GraphQL response
- [ ] ⚠️ Prisma Client is regenerated after schema changes
- [ ] ⚠️ Array fields use multi-select UI (not single-select)
- [ ] ⚠️ Associations are created/deleted in service layer
- [ ] ⚠️ Frontend sends arrays for multi-value fields
- [ ] ⚠️ Backend handles empty arrays correctly
- [ ] ⚠️ Permission guards updated for new actions/fields
- [ ] ⚠️ Rules/workflows updated if business logic changed
- [ ] ⚠️ New config/env keys are wired in all environments

---

## 🚀 Deployment Checklist

- [ ] Database migrations tested
- [ ] Rollback plan prepared
- [ ] Environment variables updated if needed
- [ ] Breaking changes communicated
- [ ] Release notes updated
- [ ] Monitoring/alerts configured

---

## 📝 Example: Adding a Multi-Value Field

**Scenario**: Add `categoryIds` array to Task

### Database
```prisma
model Task {
  // ...
  categories TaskCategory[]
}

model TaskCategory {
  id         String   @id @default(cuid())
  taskId     String
  categoryId String
  task       Task     @relation(fields: [taskId], references: [id])
  category   Category @relation(fields: [categoryId], references: [id])
  @@unique([taskId, categoryId])
}
```

### Backend - Validation
```typescript
// task.validation.ts
export const UpdateTaskSchema = z.object({
  // ...
  categoryIds: z.array(z.string()).optional(), // ⚠️ CRITICAL!
});
```

### Backend - Service
```typescript
// task.service.ts - in updateTask method
if (categoryIds !== undefined) {
  await prisma.taskCategory.deleteMany({ where: { taskId: id } });
  if (categoryIds.length > 0) {
    await prisma.taskCategory.createMany({
      data: categoryIds.map(categoryId => ({ taskId: id, categoryId }))
    });
  }
}
```

### Backend - GraphQL
```graphql
# task.typeDefs.ts
type Task {
  categories: [Category!]!
}

input TaskUpdateInput {
  categoryIds: [ID!]
}
```

```typescript
// task.resolver.ts
categories: async (parent: any) => {
  const taskCategories = await prisma.taskCategory.findMany({
    where: { taskId: parent.id },
    include: { category: true }
  });
  return taskCategories.map(tc => tc.category);
}
```

### Frontend - GraphQL
```graphql
# queries.ts
query Tasks {
  tasks {
    id
    categories {  # ⚠️ Add to query
      id
      name
    }
  }
}

# mutations.ts
mutation UpdateTask($id: ID!, $input: TaskUpdateInput!) {
  updateTask(id: $id, input: $input) {
    id
    categories {  # ⚠️ Add to mutation response
      id
      name
    }
  }
}
```

### Frontend - UI
```typescript
// TaskDialog.tsx
const [selectedCategories, setSelectedCategories] = useState<string[]>([]);

// Load existing data
useEffect(() => {
  if (task) {
    const categoryIds = task.categories?.map(c => c.id) || [];
    setSelectedCategories(categoryIds);
  }
}, [task]);

// Save handler
const handleSave = () => {
  const taskData = {
    // ...
    categoryIds: selectedCategories,  // Send array
  };
  await onSave(taskData);
};

// Multi-select UI
<Autocomplete
  multiple
  value={selectedCategories}
  onChange={(e, newValue) => setSelectedCategories(newValue)}
  options={availableCategories}
  renderInput={(params) => <TextField {...params} label="Categories" />}
  renderTags={(value, getTagProps) =>
    value.map((option, index) => (
      <Chip label={option.name} {...getTagProps({ index })} />
    ))
  }
/>
```

---

## 🎯 Quick Reference

**Every feature change touches AT MINIMUM:**
1. ✅ Database: Prisma schema + migration
2. ✅ Backend: Service + **Validation** + TypeDefs + Resolver
3. ✅ Frontend: GraphQL queries/mutations + UI component
4. ✅ Testing: Unit + E2E tests
5. ✅ Permissions/Rules/Config: Update if applicable

**The #1 mistake:** Forgetting to update Zod validation schemas! 🚨

---

**Save this checklist and review it before every PR!**
