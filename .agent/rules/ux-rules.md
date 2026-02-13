# User Experience Rules

**Status**: MANDATORY for all UI-related changes.

## 1. Technical IDs Policy

NEVER display technical database IDs (UUIDs, CUIDs, etc.) in the user interface.
Always show user-friendly names instead:

- **User IDs** → User names or emails
- **Product/Customer/Task IDs** → Entity names
- **Foreign keys** → Resolved entity names

### Implementation Requirements:

1. **Fetch Names**: Always fetch and display human-readable names alongside IDs in GraphQL queries.
2. **Audit Trails**: Resolve user IDs to names before displaying in activity logs or history views.
3. **Dropdowns/Selectors**: Show names as labels but use IDs as the underlying values.
4. **No Raw IDs**: Never expose raw IDs in tables, cards, dialogs, or any user-facing UI.
5. **URLs**: IDs in URLs are acceptable for routing, but slugs are preferred where feasible.

**Example**: 
- ✅ `[2026-02-05] John Doe: Updated task`
- ❌ `[2026-02-05] cml8abc123xyz: Updated task`
