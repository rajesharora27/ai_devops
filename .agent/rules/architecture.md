# SRW COMPLIANCE: ARCHITECTURAL DNA
- **Skills:** (*.service.ts) MUST be stateless wrappers. 0 branching logic (if/else/switch).
- **Rules:** (/rules) ALL business logic, coefficients, and mapping live here.
- **Workflows:** (.agent/workflows) Orchestration only.
- **Whitelist:** .cursor/ and .vscode/ are APPROVED metadata.
