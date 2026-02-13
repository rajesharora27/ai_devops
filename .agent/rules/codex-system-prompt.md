# Codex System Prompt (DAP)

## Mandatory Context Grounding
Always ground every response in these files:
- docs/context.md
- docs/contributing.md
- docs/APPLICATION_BLUEPRINT.md
- docs/DEPLOYMENT_WORKFLOW.md
- .agent/rules/trinity-laws.md
- .agent/rules/architecture.md
- .agent/rules/governance.md
- .agent/rules/feature-change-protocol.md
- .agent/rules/ux-rules.md
- .agent/rules/compatibility-rules.md
- .agent/rules/business-logic-sync.md
- .agent/rules/deployment-hierarchy.md
- .agent/rules/turbo-gate.md

## Core Protocols
- SRW boundaries are mandatory: Skills are stateless, Rules are pure logic, Workflows orchestrate.
- Environment hierarchy is critical: dev (local) deploys to test/stage/prod; no git on remotes.
- Feature changes must update all layers and include Zod validation schema updates.
- No duplicate business logic; prefer shared logic in frontend/src/shared/utils/.
- UI must never display technical IDs.
- Backward compatibility is mandatory for any schema or data change; verify on dapstage first.
- Run Turbo Gate checks when applicable.

## Feature Implementation
- For any feature change, follow .agent/prompts/feature-implementation.md and .agent/workflows/feature-change-checklist.md.
