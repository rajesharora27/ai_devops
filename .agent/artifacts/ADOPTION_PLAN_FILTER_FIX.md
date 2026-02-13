# Adoption Plan Task Filtering Fix

## Problem
Task filtering in the Adoption Plans view was not working, while it worked correctly in the Product Tasks view.

## Root Causes

### 1. Incorrect Source for Available Filter Options
**Before:**
```typescript
const availableTags = useMemo(() => plan?.customerProduct?.tags || [], [plan]);
const availableOutcomes = useMemo(() => plan?.selectedOutcomes || [], [plan]);
const availableReleases = useMemo(() => plan?.selectedReleases || [], [plan]);
```

**Issue:** 
- `plan.customerProduct.tags` might be empty or incomplete (doesn't represent all tags used in tasks)
- Dropdowns showed no options or incomplete options, so users couldn't select filters

**After:**
```typescript
const availableTags = useMemo(() => {
    if (!plan?.tasks) return [];
    const tagMap = new Map();
    plan.tasks.forEach((task: any) => {
        task.tags?.forEach((tag: any) => {
            if (!tagMap.has(tag.id)) {
                tagMap.set(tag.id, tag);
            }
        });
    });
    return Array.from(tagMap.values());
}, [plan?.tasks]);
```

**Solution:** Extract available options directly from the actual tasks (outcomes and releases too), matching the Product view approach.

### 2. Inconsistent Filter Logic
**Before:**
```typescript
if (filterOutcomes.length > 0 && !filterOutcomes.includes(ALL_OUTCOMES_ID)) {
    tasks = tasks.filter((task: any) => {
        const taskOutcomeIds = task.outcomes?.map((o: any) => o.id) || [];
        // Tasks with no outcomes apply to ALL outcomes
        if (taskOutcomeIds.length === 0) return true;
        return taskOutcomeIds.some((id: string) => filterOutcomes.includes(id));
    });
}
```

**Issue:** Used a different structure than Product view, making it harder to maintain consistency.

**After:**
```typescript
if (filterOutcomes.length > 0 && !filterOutcomes.includes(ALL_OUTCOMES_ID)) {
    const hasSpecificOutcomes = task.outcomes && task.outcomes.length > 0;
    if (hasSpecificOutcomes) {
        if (!task.outcomes.some((o: any) => filterOutcomes.includes(o.id))) {
            return false;
        }
    } else {
        // Task has no outcomes - include it (applies to all outcomes)
        return true;
    }
}
```

**Solution:** Matched the exact filtering logic from Product view for consistency.

## Changes Made

**File:** `frontend/src/features/adoption-plans/components/ProductAdoptionPlanView.tsx`

1. **Lines 77-113** (was 77-79): Extract available filter options from actual tasks
   - Tags extracted from `plan.tasks[].tags`
   - Outcomes extracted from `plan.tasks[].outcomes`
   - Releases extracted from `plan.tasks[].releases`

2. **Lines 115-159** (was 82-115): Updated filter logic to match Product view
   - Tags: Must have at least one matching tag
   - Outcomes: Tasks with no outcomes apply to all (included by default)
   - Releases: Tasks with no releases apply to all (included by default)

## Testing
After this fix, adoption plan filtering should:
1. ✅ Show all available tags/outcomes/releases in filter dropdowns
2. ✅ Filter tasks correctly when specific options are selected
3. ✅ Include tasks with no specific outcomes/releases (they apply to ALL)
4. ✅ Behave identically to Product view filtering

## Notes
- The fix ensures adoption plan filtering matches the working Product view filtering behavior
- Tasks without specific outcomes or releases are treated as "applies to all" and included in filtered results
- Filter options are dynamically extracted from the actual tasks in the plan, not from potentially incomplete metadata
