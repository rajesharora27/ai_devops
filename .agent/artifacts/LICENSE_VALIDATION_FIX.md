# License Selection Validation Fix

## Problem
Users could save customer product/solution assignments without selecting any licenses, which caused:
1. **Prisma Validation Error**: Empty string `""` for `licenseLevel` is not a valid enum value
2. **Invalid State**: Customer assignments with no licenses should not be allowed

Error:
```
Invalid value for argument `licenseLevel`. Expected LicenseLevel.
```

## Root Causes

### 1. Empty String Instead of Null
When no licenses were selected, the code set `licenseLevel` to empty string `""`:
```typescript
} else {
    // No licenses selected, clear the level
    setLicenseLevel('');  // ❌ Invalid enum value
}
```

**Issue:** Prisma expects either a valid `LicenseLevel` enum (`ESSENTIAL`, `ADVANTAGE`, `SIGNATURE`) or `null`, not an empty string.

### 2. No Validation
The UI didn't prevent users from saving without selecting any licenses.

## Solution

### Changes to Both Files
- `EditLicensesDialog.tsx` 
- `EditSolutionLicensesDialog.tsx`

### 1. Fixed Empty String Issue
**Before:**
```typescript
} else {
    setLicenseLevel('');  // ❌ Causes Prisma error
}
```

**After:**
```typescript
} else {
    // No licenses selected - keep current level (will validate on save)
    // Don't set to empty string as that causes Prisma validation error
}
```

### 2. Added Frontend Validation

**Visual Indicator:**
```typescript
<Typography variant="subtitle1" gutterBottom>
    Licenses <Typography component="span" color="error">*</Typography>
</Typography>
{selectedLicenseIds.length === 0 && (
    <Alert severity="error" sx={{ mb: 2 }}>
        At least one license must be selected.
    </Alert>
)}
```

**Disable Save Button:**
```typescript
<Button
    onClick={handleSave}
    variant="contained"
    disabled={!hasChanges || selectedLicenseIds.length === 0}  // ✅ Disabled when no licenses
>
    Save Changes
</Button>
```

**Alert on Save Attempt:**
```typescript
const handleSave = () => {
    // Validate: at least one license must be selected
    if (selectedLicenseIds.length === 0) {
        alert('Please select at least one license before saving.');
        return;
    }
    // ... rest of save logic
};
```

### 3. Updated Form Validation (Solutions Only)
```typescript
// Before
const isFormValid = name.trim() !== '';

// After
const isFormValid = name.trim() !== '' && selectedLicenseIds.length > 0;
```

## Files Modified

1. **frontend/src/features/customers/components/EditLicensesDialog.tsx**
   - Fixed empty string issue (line ~203)
   - Added validation in `handleSave` (line ~209)
   - Added visual error indicator (line ~230)
   - Disabled save button when no licenses (line ~417)

2. **frontend/src/features/customers/components/EditSolutionLicensesDialog.tsx**
   - Fixed empty string issue (line ~191)
   - Updated `isFormValid` to check licenses (line ~275)
   - Added validation in `handleSave` (line ~238)
   - Added visual error indicator (line ~307)

## User Experience

### Before Fix
- ❌ Could deselect all licenses and click save
- ❌ Got cryptic Prisma validation error
- ❌ No indication that licenses are required

### After Fix
- ✅ Required indicator (*) shown on Licenses label
- ✅ Red error alert when no licenses selected
- ✅ Save button disabled when no licenses selected
- ✅ Alert message if user somehow tries to save without licenses
- ✅ No Prisma errors

## Testing Checklist
- [x] Cannot save with zero licenses selected
- [x] Save button is disabled when no licenses
- [x] Error alert appears when no licenses
- [x] Selecting a license enables save button and removes error
- [x] Deselecting all licenses shows error again
- [x] No Prisma validation errors
- [x] Works in both EditLicensesDialog and EditSolutionLicensesDialog
