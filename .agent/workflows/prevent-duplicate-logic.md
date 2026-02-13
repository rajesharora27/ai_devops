# Workflow: Prevent Duplicate Business Logic

## Problem This Solves
Prevents spending 2+ hours reimplementing logic that already works perfectly elsewhere (like task filtering).

## Quick Detection

Before implementing any logic, ask:
1. "Does similar logic exist in the codebase?"
2. "Could this logic be needed in multiple places?"
3. "Is this 'business logic' (not just UI/data fetching)?"

If ANY answer is yes → Use this workflow

## Immediate Action (Current State)

Since we don't have a shared module yet, use this pattern:

### 1. Implement in Frontend First
```typescript
// frontend/src/shared/utils/[feature]-logic.ts

/**
 * CANONICAL IMPLEMENTATION
 * Used by: [list all current and planned consumers]
 * 
 * If you need this logic in backend:
 * 1. Import this file if possible
 * 2. Copy and add comment: "KEEP IN SYNC with frontend/src/shared/utils/[file]"
 * 3. Create adapter to normalize data structures
 */

export function businessLogic(data: Input): Output {
  // Implementation
}
```

### 2. Add Comprehensive Tests
```typescript
// frontend/src/shared/utils/__tests__/[feature]-logic.test.ts

describe('[Feature] Logic - Canonical Implementation', () => {
  it('scenario 1: expected behavior', () => {
    // Test documents expected behavior
  });
  
  it('scenario 2: edge case', () => {
    // All edge cases documented
  });
});
```

### 3. When Implementing in Backend
```typescript
// backend/src/modules/[feature]/[feature].service.ts

/**
 * Backend adapter for frontend business logic
 * CANONICAL SOURCE: frontend/src/shared/utils/[feature]-logic.ts
 * 
 * This file:
 * 1. Fetches data from Prisma
 * 2. Normalizes to match frontend data structure
 * 3. Calls the SAME logic (copied with comments)
 */

// KEEP IN SYNC with frontend/src/shared/utils/taskFiltering.ts
function coreLogic(normalizedData) {
  // Copy of frontend logic
  // Update this when frontend updates
}

export class FeatureService {
  static async performOperation(params) {
    // Fetch data
    const rawData = await prisma.[model].findMany(...);
    
    // Normalize to frontend structure
    const normalized = this.normalize(rawData);
    
    // Call shared logic
    return coreLogic(normalized);
  }
}
```

### 4. Add Tests That Match Frontend
```typescript
// backend/src/__tests__/integration/[feature].test.ts

/**
 * These tests MUST match frontend test scenarios
 * If frontend behavior changes, these MUST change too
 */

describe('[Feature] - Backend Adapter', () => {
  it('scenario 1: matches frontend behavior', async () => {
    // Same test case as frontend
  });
});
```

## Long-term Solution (Recommended)

### Step 1: Create Shared Package (30 min)

```bash
# In workspace root
mkdir -p shared/src
cd shared

# Initialize package
cat > package.json << 'EOF'
{
  "name": "@dap/shared",
  "version": "1.0.0",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "test": "jest",
    "watch": "tsc --watch"
  },
  "devDependencies": {
    "typescript": "^5.0.0",
    "@types/jest": "^29.0.0",
    "jest": "^29.0.0"
  }
}
EOF

# Create tsconfig
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "declaration": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
EOF

npm install
```

### Step 2: Extract First Logic (15 min)

```bash
# Move filtering logic
mkdir -p shared/src/filtering
cp frontend/src/shared/utils/taskFiltering.ts shared/src/filtering/task-filtering.ts

# Create index
cat > shared/src/index.ts << 'EOF'
export * from './filtering/task-filtering';
EOF

# Build
npm run build
```

### Step 3: Update Workspace (15 min)

```json
// Root package.json
{
  "workspaces": [
    "frontend",
    "backend",
    "shared"
  ]
}
```

```bash
# Link shared package
cd frontend && npm install @dap/shared@workspace:*
cd ../backend && npm install @dap/shared@workspace:*
```

### Step 4: Update Consumers (30 min each)

Frontend:
```typescript
// frontend/src/shared/utils/taskFiltering.ts
import { filterTasks } from '@dap/shared';
export { filterTasks };
// Re-export for backward compatibility
```

Backend:
```typescript
// backend/src/modules/license/task-filtering.service.ts
import { filterTasks, License, Task } from '@dap/shared';

export class TaskFilteringService {
  static async shouldIncludeTask(...) {
    // Normalize Prisma → shared types
    const normalized = this.normalize(...);
    
    // Use shared logic
    return filterTasks([normalized], options).length > 0;
  }
}
```

## Checklist for Any New Business Logic

- [ ] Searched codebase for existing implementation
- [ ] If exists: Linked to canonical source in comments
- [ ] If new: Implemented in shared location first
- [ ] Added comprehensive tests
- [ ] Documented expected behavior
- [ ] If copied: Added "KEEP IN SYNC" comment with file path
- [ ] Verified behavior matches across all consumers

## Examples from Codebase

### ✅ Good: Task Filtering (After Fix)
- Frontend: `frontend/src/shared/utils/taskFiltering.ts` (canonical)
- Backend: `backend/src/modules/license/task-filtering.service.ts` (adapter)
- Comment: "KEEP IN SYNC with frontend/src/shared/utils/taskFiltering.ts"
- Tests in both places verify same behavior

### ❌ Bad: License Access (Before Fix)
- Frontend: Complex filtering in `ProductContext.tsx`
- Backend: Different implementation in `LicenseAccessService.ts`
- Result: Inconsistent behavior, 2+ hours to debug

## When to Use This Workflow

**Always use for:**
- Filtering algorithms
- Access control logic
- Calculations/aggregations
- Validation rules
- Data transformations
- Business rules

**Not needed for:**
- UI component logic
- API route handlers (unless they contain business logic)
- Pure data fetching
- Framework-specific code

## Red Flags

If you see these, apply this workflow:
- "It works in Product view but not in Adoption Plans"
- "Let me reimplement this filtering logic"
- Copy-pasting complex logic between files
- Different results for same input in different places

## Cost vs. Benefit

**Current (No Shared Module):**
- Setup: 0 hours
- Per duplicate: 1-2 hours debugging
- Risk: High (logic drift)

**With Shared Module:**
- Setup: 2-3 hours (one time)
- Per feature: 0 hours (reuse)
- Risk: None (single source of truth)

**Break-even:** After 2 features

## Questions?

1. "Should I extract this to shared?"
   → If it defines business behavior: YES
   → If it's just UI presentation: NO

2. "How do I handle framework-specific code?"
   → Extract pure logic to shared, create thin adapters in each framework

3. "What if data structures are different?"
   → Normalize in adapters before calling shared logic (see TaskFilteringService)

4. "What about performance?"
   → Shared logic is TypeScript, compiles to same JavaScript
   → Zero overhead, may actually improve (single implementation to optimize)
