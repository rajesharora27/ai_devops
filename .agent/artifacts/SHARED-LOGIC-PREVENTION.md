# Preventing Duplicate Logic Implementation

## Problem
Task filtering logic worked perfectly in Product view (frontend) but took 2+ hours to replicate in Adoption Plans (backend) due to:
1. Code duplication between frontend and backend
2. Different data models (GraphQL vs Prisma)
3. No shared source of truth for business logic
4. Lack of tests documenting expected behavior

## Solution: Shared Business Logic Layer

### Architecture

```
/Users/rajarora/dev/dap/
├── shared/                          # NEW: Shared business logic
│   ├── src/
│   │   ├── filtering/
│   │   │   ├── task-filtering.ts    # Core filtering logic
│   │   │   ├── license-hierarchy.ts # License hierarchy utilities
│   │   │   └── types.ts             # Shared TypeScript interfaces
│   │   ├── validation/
│   │   │   └── schemas.ts           # Shared validation rules
│   │   └── utils/
│   │       └── date-helpers.ts
│   ├── package.json
│   └── tsconfig.json
├── frontend/
│   └── package.json                 # imports: "@dap/shared"
└── backend/
    └── package.json                 # imports: "@dap/shared"
```

### Implementation Steps

#### 1. Create Shared Package
```bash
mkdir -p shared/src/filtering
cd shared
npm init -y
```

#### 2. Extract Core Logic to Shared Module
```typescript
// shared/src/filtering/task-filtering.ts

/**
 * SINGLE SOURCE OF TRUTH for task filtering
 * Used by: Frontend Product view, Backend Adoption Plans, Reports, etc.
 */

export interface License {
  id: string;
  name: string;
  level: number;
  includesAllLicenseFeatures: boolean;
  includedLicenses?: License[];
}

export interface Task {
  id: string;
  name: string;
  licenses?: License[];
  license?: License;
  tags?: Array<{ id: string }>;
  outcomes?: Array<{ id: string }>;
  releases?: Array<{ id: string }>;
}

export interface FilterOptions {
  licenseFilter?: string[];
  tagFilter?: string[];
  outcomeFilter?: string[];
  releaseFilter?: string[];
  productLicenses: License[];
}

/**
 * Core filtering logic - MUST be identical everywhere
 */
export function filterTasks(tasks: Task[], options: FilterOptions): Task[] {
  // ... exact logic from frontend/src/shared/utils/taskFiltering.ts
}

export function isLicenseHierarchyMatch(taskLicense: License, selectedLicense: License): boolean {
  // ... exact logic
}

export function getAllIncludedLicenses(licenseIds: string[], allLicenses: License[]): License[] {
  // ... exact logic
}
```

#### 3. Frontend Adapter
```typescript
// frontend/src/shared/utils/taskFiltering.ts

import { 
  filterTasks as coreFilterTasks,
  FilterOptions,
  Task,
  License
} from '@dap/shared/filtering/task-filtering';

/**
 * Frontend adapter - normalizes GraphQL data to shared types
 */
export function filterTasks(tasks: any[], options: any): any[] {
  // Map GraphQL structure to shared types if needed
  const normalizedTasks: Task[] = tasks.map(task => ({
    ...task,
    licenses: task.licenses || []
  }));
  
  return coreFilterTasks(normalizedTasks, {
    ...options,
    productLicenses: options.productLicenses || []
  });
}
```

#### 4. Backend Adapter
```typescript
// backend/src/modules/license/task-filtering.service.ts

import {
  filterTasks as coreFilterTasks,
  License,
  Task
} from '@dap/shared/filtering/task-filtering';
import { prisma } from '../../shared/graphql/context';

/**
 * Backend adapter - fetches Prisma data and normalizes to shared types
 */
export class TaskFilteringService {
  static async shouldIncludeTask(
    customerId: string,
    task: any,
    productId: string
  ): Promise<boolean> {
    // Fetch data
    const customerLicenses = await this.fetchCustomerLicenses(customerId, productId);
    const productLicenses = await this.fetchProductLicenses(productId);
    const taskLicenses = await this.fetchTaskLicenses(task.id);
    
    // Normalize Prisma structure to shared types
    const normalizedTask: Task = {
      id: task.id,
      name: task.name,
      licenses: taskLicenses.map(tl => this.normalizeLicense(tl.license))
    };
    
    const normalizedLicenses: License[] = productLicenses.map(l => this.normalizeLicense(l));
    
    // Call SHARED logic
    const result = coreFilterTasks([normalizedTask], {
      licenseFilter: customerLicenses.map(cl => cl.licenseId),
      productLicenses: normalizedLicenses
    });
    
    return result.length > 0;
  }
  
  private static normalizeLicense(prismaLicense: any): License {
    return {
      id: prismaLicense.id,
      name: prismaLicense.name,
      level: prismaLicense.level,
      includesAllLicenseFeatures: prismaLicense.includesAllLicenseFeatures,
      includedLicenses: prismaLicense.inclusionsA?.map(l => this.normalizeLicense(l))
    };
  }
}
```

### 5. Add Comprehensive Tests

```typescript
// shared/src/filtering/__tests__/task-filtering.test.ts

import { filterTasks, License, Task } from '../task-filtering';

describe('Task Filtering - Shared Logic', () => {
  const mockLicenses: License[] = [
    {
      id: 'spa-adv',
      name: 'SPA Advantage',
      level: 2,
      includesAllLicenseFeatures: false,
      includedLicenses: [{
        id: 'spa-ess',
        name: 'SPA Essential',
        level: 1,
        includesAllLicenseFeatures: true
      }]
    },
    // ... more licenses
  ];
  
  it('should include mapped tasks for matching license', () => {
    const tasks: Task[] = [{
      id: '1',
      name: 'SPA Task',
      licenses: [{ id: 'spa-adv', name: 'SPA Advantage', level: 2, includesAllLicenseFeatures: false }]
    }];
    
    const result = filterTasks(tasks, {
      licenseFilter: ['spa-adv'],
      productLicenses: mockLicenses
    });
    
    expect(result).toHaveLength(1);
  });
  
  it('should include unmapped tasks only when flag is set', () => {
    const unmappedTask: Task[] = [{
      id: '2',
      name: 'Unmapped Task',
      licenses: []
    }];
    
    // With flag - should show
    const withFlag = filterTasks(unmappedTask, {
      licenseFilter: ['spa-adv'], // Has flag via hierarchy
      productLicenses: mockLicenses
    });
    expect(withFlag).toHaveLength(1);
    
    // Without flag - should NOT show
    const withoutFlag = filterTasks(unmappedTask, {
      licenseFilter: ['rbi-unlimited'], // No flag
      productLicenses: mockLicenses
    });
    expect(withoutFlag).toHaveLength(0);
  });
  
  // ... more tests documenting ALL edge cases
});
```

### 6. Workspace Configuration

```json
// package.json (root)
{
  "name": "dap-monorepo",
  "private": true,
  "workspaces": [
    "frontend",
    "backend",
    "shared"
  ]
}

// shared/package.json
{
  "name": "@dap/shared",
  "version": "1.0.0",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "test": "jest"
  }
}

// frontend/package.json
{
  "dependencies": {
    "@dap/shared": "workspace:*"
  }
}

// backend/package.json
{
  "dependencies": {
    "@dap/shared": "workspace:*"
  }
}
```

## Benefits

### ✅ Prevents This Issue Forever
1. **Single Source of Truth**: One implementation of filtering logic
2. **Type Safety**: Shared TypeScript interfaces prevent data structure mismatches
3. **Tested Once, Works Everywhere**: Tests in shared module validate behavior
4. **Version Controlled**: Changes to logic are tracked and reviewed once
5. **Refactor Safety**: Update in one place, deploy everywhere

### ✅ Additional Benefits
1. **Faster Development**: New features use existing shared logic
2. **Easier Onboarding**: New developers find logic in one place
3. **Better Documentation**: Tests serve as living documentation
4. **Reduced Bugs**: No chance of logic drift between frontend/backend
5. **Code Reviews**: Changes to business logic are obvious in PRs

## Migration Plan

### Phase 1: Create Shared Module (1 hour)
- [ ] Create `shared/` directory
- [ ] Extract filtering logic to shared module
- [ ] Add TypeScript types/interfaces
- [ ] Add comprehensive tests

### Phase 2: Update Frontend (30 min)
- [ ] Install shared package
- [ ] Create adapter layer
- [ ] Update imports
- [ ] Run existing tests to verify

### Phase 3: Update Backend (30 min)
- [ ] Install shared package
- [ ] Create adapter layer (normalize Prisma → shared types)
- [ ] Update imports
- [ ] Run existing tests to verify

### Phase 4: Documentation (30 min)
- [ ] Document architecture in README
- [ ] Add JSDoc comments explaining adapters
- [ ] Create migration guide for future shared logic

## Other Logic to Share

Based on this codebase, consider moving these to shared module:

1. **License Logic**
   - `includesAllLicenseFeatures` flag evaluation
   - License hierarchy traversal
   - Permission checking

2. **Validation Rules**
   - Customer data validation
   - Product configuration validation
   - Task validation schemas

3. **Business Calculations**
   - Progress percentage calculation
   - Status computation
   - Metrics aggregation

4. **Date/Time Logic**
   - Due date calculations
   - Timezone handling
   - Date formatting

5. **Constants**
   - Status values
   - Permission levels
   - Configuration defaults

## Enforcement

### 1. Add to `.cursorrules`
```markdown
# Shared Business Logic Rule

CRITICAL: Before implementing business logic in frontend OR backend:
1. Check if logic exists in `shared/` module
2. If yes: Import and use it (create adapter if needed)
3. If no: Implement in `shared/` first, then import in both places

Examples of "business logic":
- Filtering, sorting, grouping
- Access control, permissions
- Calculations, aggregations
- Validation rules
- Data transformations

Never duplicate business logic between frontend and backend.
```

### 2. Add Pre-commit Hook
```bash
#!/bin/bash
# .githooks/pre-commit

# Check for potential duplicate logic
if git diff --cached --name-only | grep -E "(frontend|backend)" | grep -E "(filter|validation|calculation)" > /dev/null; then
    echo "⚠️  WARNING: Changes to filtering/validation/calculation logic detected"
    echo "   Have you checked if this should be in shared/ module?"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
```

### 3. Code Review Checklist
Add to `.github/PULL_REQUEST_TEMPLATE.md`:
```markdown
## Business Logic Checklist
- [ ] If adding business logic, is it in `shared/` module?
- [ ] If updating existing logic, did you update tests?
- [ ] If logic differs between frontend/backend, is it intentional?
```

## Cost-Benefit

**Time Investment:**
- Initial setup: 2-3 hours
- Per-feature savings: 1-2 hours

**Break-even:** After 2 features (already would have saved time on this issue)

**Long-term ROI:**
- Prevents bugs from logic drift
- Faster feature development
- Easier maintenance
- Better code quality
- Reduced technical debt

## Next Steps

1. Review this proposal
2. Decide on migration timeline
3. Create `shared/` module structure
4. Extract task filtering logic first (proven need)
5. Gradually migrate other shared logic
6. Document pattern for team

## Alternative: Keep Current Approach

If shared module is too heavy:
- ✅ Add comprehensive tests to Product filter
- ✅ Document expected behavior in comments
- ✅ Copy-paste with explicit "KEEP IN SYNC" markers
- ❌ Still prone to drift and bugs
- ❌ No compile-time guarantees
