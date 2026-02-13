# License Level Bug Fix

## Problem
Frontend was sending license **names** (e.g., "SECURE INTERNET ACCESS ADVANTAGE") to the `updateCustomerProduct` mutation's `licenseLevel` field, but Prisma expected a valid `LicenseLevel` enum value (`ESSENTIAL`, `ADVANTAGE`, or `SIGNATURE`).

## Root Cause
In `EditLicensesDialog.tsx` and `EditSolutionLicensesDialog.tsx`, when users selected licenses, the code was setting:
```typescript
setLicenseLevel(highestLevelLicense.name);  // ❌ License NAME, not enum value
```

This caused errors like:
```
Invalid value for argument `licenseLevel`. Expected LicenseLevel.
```

## Solution
Created a `mapLevelToEnum()` function that maps the license's numeric `level` field to valid enum values:
- `level >= 3` → `"SIGNATURE"`
- `level >= 2` → `"ADVANTAGE"`
- `level < 2` → `"ESSENTIAL"`

## Files Fixed
1. `frontend/src/features/customers/components/EditLicensesDialog.tsx` (line 181-205)
2. `frontend/src/features/customers/components/EditSolutionLicensesDialog.tsx` (line 168-190)

## Changes
**Before:**
```typescript
if (highestLevelLicense && highestLevelLicense.level > 0) {
  setLicenseLevel(highestLevelLicense.name);  // ❌ License name
}
```

**After:**
```typescript
const mapLevelToEnum = (level: number): string => {
  if (level >= 3) return 'SIGNATURE';
  if (level >= 2) return 'ADVANTAGE';
  return 'ESSENTIAL';
};

if (highestLevelLicense && highestLevelLicense.level > 0) {
  setLicenseLevel(mapLevelToEnum(highestLevelLicense.level));  // ✅ Valid enum
} else {
  setLicenseLevel('');  // Clear when no licenses selected
}
```

## Testing
After this fix, the license dialog should:
1. ✅ Allow users to select multiple licenses
2. ✅ Automatically set the legacy `licenseLevel` to the highest license level enum value
3. ✅ Successfully save without Prisma validation errors
4. ✅ Send both `licenseIds` (multi-license) and `licenseLevel` (legacy) to backend

## Notes
- The `licenseLevel` field is maintained for backward compatibility
- The new multi-license architecture uses `licenseIds` as the primary field
- Backend resolver (line 478) converts `licenseLevel` to uppercase before saving
