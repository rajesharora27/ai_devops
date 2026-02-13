# Unified Task Filtering Implementation

## Problem
License-based filtering was inconsistent between Product and Adoption Plan views:
- **Product view**: Had complex frontend filtering logic with license hierarchy and `includesAllLicenseFeatures` support
- **Adoption Plan view**: Used backend filtering during sync + different frontend filtering logic
- **Result**: Same license selection showed different tasks in different views

## Solution
Created a **shared task filtering utility** that both views use for consistent filtering behavior.

## Changes Made

### 1. Created Shared Filtering Utility
**File**: `/frontend/src/shared/utils/taskFiltering.ts`

Extracted all filtering logic into reusable functions:
- `filterTasks()` - Main filtering function for tags, outcomes, releases, and licenses
- `isLicenseHierarchyMatch()` - Checks license hierarchy relationships
- `getAllIncludedLicenses()` - Recursively gets all licenses included by selected ones
- `checkLegacyLicenseMatch()` - Handles legacy license field compatibility

**Key filtering rules**:
- **Tags**: OR logic - task must have at least one selected tag
- **Outcomes**: OR logic - tasks with no outcomes apply to all; tasks with specific outcomes must match selection
- **Releases**: OR logic - tasks with no releases apply to all; tasks with specific releases must match selection
- **Licenses**: Complex hierarchical matching:
  - Tasks with explicit license mappings MUST match the selected license (or be in its hierarchy)
  - Tasks without explicit mappings are only shown if selected license has `includesAllLicenseFeatures = true`
  - Supports license hierarchy (e.g., "RBI Unlimited" includes "RBI Risky" tasks)

### 2. Updated Product Context
**File**: `/frontend/src/features/products/context/ProductContext.tsx`

**Changes**:
- Imported `filterTasks` from shared utility
- Replaced inline filtering logic (100+ lines) with single call to `filterTasks()`
- Removed duplicate helper functions (`isLicenseHierarchyMatch`, `checkLegacyLicenseMatch`)

**Before**:
```typescript
const filteredTasks = tasks.filter((task: any) => {
    // 100+ lines of inline filtering logic
});
```

**After**:
```typescript
const filteredTasks = useMemo(() => {
    return filterTasks(tasks, {
        tagFilter: taskTagFilter,
        outcomeFilter: taskOutcomeFilter,
        releaseFilter: taskReleaseFilter,
        licenseFilter: taskLicenseFilter,
        productLicenses: selectedProduct?.licenses || []
    });
}, [tasks, taskTagFilter, taskOutcomeFilter, taskReleaseFilter, taskLicenseFilter, selectedProduct?.licenses]);
```

### 3. Updated Adoption Plan View
**File**: `/frontend/src/features/adoption-plans/components/ProductAdoptionPlanView.tsx`

**Changes**:
- Imported `filterTasks` from shared utility
- Replaced custom filtering logic with call to `filterTasks()`
- **Omitted license filtering** (see note below)

**Key changes**:
```typescript
// Use shared filterTasks utility (without license filter)
const filteredTasks = useMemo(() => {
    if (!plan?.tasks) return [];
    
    // Note: License filtering is omitted for adoption plans since:
    // 1. Customer already has specific licenses assigned
    // 2. Tasks are pre-filtered during sync based on customer's licenses
    // 3. CustomerTask doesn't have license relations (no way to filter them)
    const filtered = filterTasks(plan.tasks, {
        tagFilter: filterTags,
        outcomeFilter: filterOutcomes,
        releaseFilter: filterReleases,
        licenseFilter: [], // No license filtering for adoption plans
        productLicenses: plan.customerProduct?.product?.licenses || []
    });
    
    return filtered.sort((a: any, b: any) => (a.sequenceNumber || 0) - (b.sequenceNumber || 0));
}, [plan?.tasks, filterReleases, filterOutcomes, filterTags, plan?.customerProduct?.product?.licenses]);
```

### 4. Adoption Plan Filter UI (No Changes Needed)
**File**: `/frontend/src/features/adoption-plans/components/AdoptionPlanFilterSection.tsx`

**No license filter added** - Adoption plans don't need license filtering since:
1. Tasks are already filtered by the customer's assigned licenses during sync
2. `CustomerTask` doesn't have license relations in the database schema
3. Users can't explore different license scenarios in adoption plans (they're fixed)

Adoption plan filters remain: **Tags, Outcomes, Releases** (using the same shared logic as Product view)

### 5. Backend Sync Logic Update
**File**: `/backend/src/modules/license/license-access.service.ts`

**Changes**:
- **Backend now includes ALL accessible tasks** (not just those matching specific licenses)
- Tasks without explicit license mappings are included if customer has ANY active license
- **Frontend handles precise filtering** using the shared utility
- Removed debug logging

**Logic**:
- If task has NO explicit license requirements → Include (frontend will filter)
- If task has explicit license requirements → Check if customer has matching license
- If customer has `includesAllLicenseFeatures` license → Include ALL tasks

**Rationale**: Backend determines accessibility (which tasks CAN be shown), frontend determines visibility (which tasks SHOULD be shown based on filters).

## Result

✅ **Product and Adoption Plan views use the same filtering logic from `taskFiltering.ts`**  
✅ **Tags, Outcomes, and Releases filters behave identically in both views**  
✅ **License filtering available in Product view** (for exploring "what-if" scenarios)  
✅ **License filtering omitted in Adoption Plan view** (tasks already filtered by customer's assigned licenses)  
✅ **Single source of truth for filtering rules** (`taskFiltering.ts`)  
✅ **Easier to maintain and update** - change filtering logic in one place

### Why No License Filter in Adoption Plans?

1. **Database Schema**: `CustomerTask` doesn't have a `licenses` relation (no `CustomerTaskLicense` join table)
2. **Pre-filtered**: Backend sync already includes only tasks the customer has access to based on their assigned licenses
3. **Not Applicable**: Users can't change licenses in adoption plan view - they're exploring their specific plan, not different license options
4. **Product View Use Case**: License filtering makes sense when browsing a product catalog to see "what tasks come with this license?"
5. **Adoption Plan Use Case**: You're managing tasks you already have access to - license filtering would be confusing  

## Testing

1. Create a product with multiple licenses (e.g., "RBI Risky", "RBI Unlimited")
2. Assign specific tasks to each license using TaskLicense mappings
3. Create a customer adoption plan with "RBI Unlimited" license
4. **Product View**: Select "RBI Unlimited" in license filter → Shows only tasks mapped to that license + tasks with `includesAllLicenseFeatures`
5. **Adoption Plan View**: Shows the same tasks (already filtered during sync based on customer's "RBI Unlimited" license)
6. **Both Views**: Apply Outcome/Release filters → Should show identical results for the same filter selection

## Files Modified

### Frontend
- ✅ `/frontend/src/shared/utils/taskFiltering.ts` (NEW)
- ✅ `/frontend/src/features/products/context/ProductContext.tsx`
- ✅ `/frontend/src/features/adoption-plans/components/ProductAdoptionPlanView.tsx`
- ✅ `/frontend/src/features/adoption-plans/components/AdoptionPlanFilterSection.tsx`

### Backend
- ✅ `/backend/src/modules/license/license-access.service.ts`
- ✅ `/backend/src/modules/customer/workflows/CustomerAdoptionWorkflow.ts`

## GraphQL
Already had `includesAllLicenseFeatures` field in license queries (added previously):
- ✅ `ADOPTION_PLAN` query
- ✅ `GET_PRODUCT_DETAILS` query
- ✅ All license fragments

## Benefits

1. **Consistency**: Identical behavior across views
2. **Maintainability**: Single location for filtering logic
3. **Testability**: Can unit test filtering logic independently
4. **Reusability**: Can use in future views (Solutions, Reports, etc.)
5. **Performance**: Frontend filtering is fast and doesn't require server round-trips
6. **Flexibility**: Users can see all accessible tasks and filter as needed

## Future Enhancements

- [ ] Add unit tests for `taskFiltering.ts`
- [ ] Consider adding filter presets (e.g., "Show all accessible", "Show only assigned")
- [ ] Add filter state persistence to localStorage
- [ ] Add "License Level" quick filter (Essential/Advantage/Signature)
