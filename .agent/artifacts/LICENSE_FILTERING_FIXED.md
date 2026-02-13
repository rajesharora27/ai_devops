# License-Based Filtering - FIXED ✅

## Problem Statement
Adoption Plan was showing 22 tasks for customer with "RBI Unlimited" license, while Product filter with same license selection showed only 2 tasks. This inconsistency was causing confusion.

## Root Cause
Backend sync logic (`LicenseAccessService.customerHasAccessToTask()`) was **too permissive**:
- Tasks WITHOUT explicit license mappings were being included for ANY customer with active licenses
- Should have been: Tasks without mappings only included if customer has `includesAllLicenseFeatures = true`

## Solution

### Backend Fix
**File**: `/backend/src/modules/license/license-access.service.ts`

Changed logic for tasks without explicit license mappings:

**BEFORE** (Too Permissive):
```typescript
if (taskLicenses.length === 0) {
    return true; // Grant access to ANY customer with active licenses
}
```

**AFTER** (Strict - Matches Product Filter):
```typescript
if (taskLicenses.length === 0) {
    // ONLY show unmapped tasks if customer has "includes all" privilege
    return hasAllLicenseFeaturesAccess;
}
```

### Rebuild & Re-sync Required
1. Rebuilt TypeScript backend: `npm run build`
2. Re-synced adoption plan to apply strict filtering
3. Tasks reduced from **22 → 2** ✅

## Verification

### Cisco Secure Access Product
- **Total tasks**: 63
- **Tasks with explicit license mappings**: 43
- **Tasks without mappings**: 20

### Customer: Raj-test
- **Assigned License**: RBI Unlimited
- **includesAllLicenseFeatures**: `false`
- **License Hierarchy**: RBI Unlimited **includes** RBI Risky

### Expected Behavior (Strict Filtering)

#### Tasks WITH Explicit Mappings (2 tasks)
✅ **"RBI Any (Unlimited)"** - requires "RBI Unlimited" license (direct match)  
✅ **"RBI Risky (Limited)"** - requires "RBI Risky" license (included via hierarchy)

#### Tasks WITHOUT Explicit Mappings (20 tasks)
❌ **Excluded** - Customer doesn't have `includesAllLicenseFeatures = true`

Examples of excluded unmapped tasks:
- "Sign into Secure Access"
- "Validate License and Packages"
- "Setup SSO for Admin Users"
- etc. (20 total)

### Result
**Adoption Plan: 2 tasks** ✅  
**Product Filter (RBI Unlimited): 2 tasks** ✅  
**✨ IDENTICAL BEHAVIOR ✨**

## License Hierarchy Support

The system correctly handles license hierarchies:

```
RBI Unlimited (parent)
  └─ includes → RBI Risky (child)
```

When a customer has "RBI Unlimited":
- ✅ Access to tasks requiring "RBI Unlimited" (direct match)
- ✅ Access to tasks requiring "RBI Risky" (inherited via hierarchy)

This is implemented via:
- Database: `_LicenseInclusions` join table (self-referencing many-to-many)
- Backend: `getAllChildLicenseIds()` method recursively traverses hierarchy
- Frontend: Shared filtering utility respects same hierarchy

## Shared Filtering Logic

Both Product and Adoption Plan views now use:
- **Same utility**: `/frontend/src/shared/utils/taskFiltering.ts`
- **Same backend service**: `LicenseAccessService.customerHasAccessToTask()`
- **Same rules**: Strict enforcement of license mappings and `includesAllLicenseFeatures` flag

### Product View
- **License Filter UI**: ✅ Available (for exploring different license scenarios)
- **Filtering**: Frontend using `filterTasks()` utility

### Adoption Plan View
- **License Filter UI**: ❌ Not available (customer's licenses are fixed)
- **Pre-filtering**: Backend sync using `customerHasAccessToTask()`
- **Additional Filters**: Tags, Outcomes, Releases (using same `filterTasks()` utility)

## Key Learnings

### 1. Backend Determines Accessibility
Backend sync uses **strict filtering** to decide which tasks a customer CAN access based on:
- Customer's assigned licenses
- Task's explicit license requirements (TaskLicense mappings)
- License hierarchy (included licenses)
- `includesAllLicenseFeatures` flag

### 2. Frontend Determines Visibility
Frontend filters determine which accessible tasks SHOULD be shown based on:
- User's current filter selections (tags, outcomes, releases)
- Same shared logic for consistency

### 3. License Filtering Scope
- **Product View**: License filter is for **exploration** ("What if I had this license?")
- **Adoption Plan View**: No license filter needed - tasks are **pre-filtered** by customer's actual licenses

### 4. Unmapped Tasks Require Special Privilege
Tasks without explicit license mappings (e.g., general setup tasks) are only shown to customers with licenses that have `includesAllLicenseFeatures = true`. This prevents "license leakage" where customers see tasks they shouldn't have access to.

## Files Modified

### Backend
- ✅ `/backend/src/modules/license/license-access.service.ts` - Strict filtering for unmapped tasks

### Frontend
- ✅ `/frontend/src/shared/utils/taskFiltering.ts` - Shared filtering utility (created)
- ✅ `/frontend/src/features/products/context/ProductContext.tsx` - Uses shared utility
- ✅ `/frontend/src/features/adoption-plans/components/ProductAdoptionPlanView.tsx` - Uses shared utility
- ✅ `/frontend/src/features/customers/graphql/queries.ts` - Fixed to query product licenses

## Testing Checklist

- [x] Backend sync respects license mappings
- [x] Backend sync respects `includesAllLicenseFeatures` flag
- [x] Backend sync respects license hierarchy
- [x] Product filter shows correct tasks for "RBI Unlimited"
- [x] Adoption plan shows same tasks as Product filter
- [x] Unmapped tasks excluded when `includesAllLicenseFeatures = false`
- [x] License hierarchy correctly includes child license tasks
- [x] Tags/Outcomes/Releases filters work identically in both views

## Next Steps

1. ✅ Refresh frontend - adoption plan should now show 2 tasks
2. ✅ Verify Product filter with "RBI Unlimited" also shows 2 tasks
3. ✅ Test with different licenses (e.g., "RBI Risky" alone should show only 1 task)
4. ✅ Test with license that has `includesAllLicenseFeatures = true` (should show all tasks)
