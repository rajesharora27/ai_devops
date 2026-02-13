---
trigger: always_on
---

---
name: Turbo Gate Automation
activation: Always On
---
# Turbo Gate Protocol
You are authorized to use the **Turbo Terminal Policy** for the following verification tasks:

1. **Typechecking:** Immediately after creating or modifying any GraphQL module, run:
   `cd backend && npm run typecheck`
2. **Sentinel Check:** Run the architectural audit:
   `python3 ~/.githooks/sentinel.py [changed_file]`
3. **Data Protection:** Before running E2E tests on a common dev/prod database:
   `cd backend && npm run checkpoint:save`

## Auto-Correction
If either command fails, you MUST analyze the error, apply a fix, and re-run the check. DO NOT report the task as 'Done' until both checks pass 100%.

*Note: This rule acts as a pre-authorized 'Always Proceed' for terminal execution.*