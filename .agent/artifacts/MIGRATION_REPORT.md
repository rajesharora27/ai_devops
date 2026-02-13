# Antigravity Migration Report

**Logic Analysis & Refactoring Plan**

---

## 1. Rule Discovery (The Brain Extraction)
*Identifying repetitive logic to externalize.*

### Rule 1: RBAC Permission Hierarchy
**Current State:** Hard-coded in `backend/src/shared/auth/permissions.ts`.
**Analysis:** The hierarchy (`ADMIN=3`, `WRITE=2`, `READ=1`) and bidirectional inheritance logic (Product ↔ Solution) is static typescript code.
**Proposed Rule:** `.agent/rules/rbac-policy.json`
```json
{
  "hierarchy": { "ADMIN": 3, "WRITE": 2, "READ": 1 },
  "inheritance": [
    { "source": "SOLUTION", "target": "PRODUCT", "condition": "CONTAINS" },
    { "source": "product", "target": "solution", "condition": "PARENT" }
  ],
  "defaultUserPolicy": "READ_ALL"
}
```

### Rule 2: Seed Configuration & Sample Data
**Current State:** Massive hard-coded arrays in `backend/src/scripts/seed.ts` (e.g., `prod-cisco-duo` with specific attributes/licenses).
**Analysis:** This is data masquerading as code. It consumes ~1000 lines of context.
**Proposed Rule:** `.agent/rules/seed-data.json`
```json
{
  "products": [
    {
      "id": "prod-cisco-duo",
      "attributes": { "vendor": "Cisco", "category": "Identity" },
      "licenses": ["Essential", "Advantage", "Signature"]
    }
  ]
}
```

### Rule 3: Telemetry Evaluation Logic
**Current State:** Hard-coded `switch` statements and `if/else` criteria parsing in `backend/src/modules/telemetry/evaluation-engine.ts`.
**Analysis:** The logic for `NumberThresholdCriteria` vs `BooleanFlagCriteria` is static code.
**Proposed Rule:** `.agent/rules/telemetry-logic.json`
```json
{
  "evaluators": {
    "NumberThreshold": { "operator": "numeric_comparison", "safe_cast": true },
    "BooleanFlag": { "operator": "boolean_match" }
  }
}
```

---

## 2. Skill Identification (The Tool Extraction)
*Encapsulating heavy functions into Agent Tools.*

### Skill 1: `evaluate_telemetry`
**Heavy Function:** `TelemetryEvaluationEngine.evaluateCriteria`
**Context Impact:** ~600 tokens
**Description:** Complex recursive logic for AND/OR/Threshold evaluation.
**New Tool Interface:**
```markdown
# Evaluate Telemetry Skill
Call this tool to evaluate a set of telemetry data against success criteria.
Args:
- criteria (JSON): The logic rule.
- data (JSON): The telemetry values.
Returns: { success: boolean, reason: string }
```

### Skill 2: `check_permission`
**Heavy Function:** `checkUserPermission` in `permissions.ts`
**Context Impact:** ~1000 tokens
**Description:** The bidirectional logic checks are massive and repetitive.
**New Tool Interface:**
```markdown
# Check Permission Skill
Call this tool to verify RBAC access.
Args:
- userId, resourceType, resourceId, requiredLevel
Returns: boolean
```

---

## 3. Workflow Opportunities (The Automation)
*Sequences to automate.*

### Workflow 1: `/seed-db`
**Current:** Running `npx ts-node src/scripts/seed.ts`.
**Automation:**
1.  Read `.agent/rules/seed-data.json`.
2.  Clean Audit Logs.
3.  Upsert Users.
4.  Upsert Products/Solutions.
5.  Generate Report.

### Workflow 2: `/create-entity-module`
**Current:** Manually creating `service`, `resolver`, `schema`, `types`.
**Automation:**
1.  Input: Entity Name (e.g., "Report").
2.  Skill: Scaffold Directory Structure.
3.  Skill: Generate 5 standard files (Service, Resolver, Schema, Types, Index).
4.  Skill: Wired into `index.ts`.

---

## 4. The "Context Savings" Roadmap

| Rank | Refactor Item | Token Savings | Complexity | Action |
| :--- | :--- | :--- | :--- | :--- |
| 🥇 | **Externalize Seed Data** | ~4000+ | Low | Move `seed.ts` data to JSON. |
| 🥈 | **RBAC Rules Engine** | ~1000 | High | Refactor `permissions.ts` to read Policy JSON. |
| 🥉 | **Telemetry Logic** | ~600 | Medium | Move evaluation logic to Rules. |
| 4 | **Static Icons/Assets** | ~500 | Low | Move standard SVG definitions to shared assets. |

**Immediate Recommendation:**
Start with **Rank 1 (Seed Data)**. It is essentially dead weight in the codebase context and prevents effective reasoning about actual logic.
