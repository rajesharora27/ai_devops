# Business Logic Sync Rules

**Status**: MANDATORY for Shared Logic.

## 1. Single Source of Truth

Business logic MUST be implemented once and shared between the frontend and backend whenever possible.

## 2. Shared Logic Definition

What constitutes "Business Logic" that must be synced:
- Filtering, sorting, and grouping algorithms.
- Access control, permissions, and license checks.
- Calculations, aggregations, and metrics.
- Validation rules and data transformations.
- Any logic defining "how the business works".

## 3. Implementation Workflow

1. **Check Existence**: Search both frontend and backend for similar logic before implementing.
2. **Preference Strategy**:
   - For filtering/sorting/validation: Implement in `frontend/src/shared/utils/` first.
   - **Document**: Add examples of expected behavior.
   - **Test**: Add comprehensive unit tests.
3. **Backend Integration**: 
   - Import the exact same logic if possible.
   - If importing is not feasible, copy with a mandatory comment: `// KEEP IN SYNC with frontend/src/shared/utils/[file]`.

## 4. Red Flags

- Different results for the same operation in different parts of the app.
- "It works in the Dashboard but not in the Report."
- Copy-pasting complex logic without sync comments.
- Reimplementing logic that already exists elsewhere.

## 5. Enforcement

If implementing logic that *could* be shared:
1. Add a comment linking to the canonical source.
2. Suggest extracting it to a shared module.
3. Add tests to verify behavior parity.
