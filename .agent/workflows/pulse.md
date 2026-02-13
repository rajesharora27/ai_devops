---
description: 
---

# Workflow: System Pulse & Link Integrity
Trigger: /pulse

## Phase 1: Knowledge Integrity
- **Link Audit:** Verify all internal links in `APPLICATION_BLUEPRINT.md` are Repo-Root Relative (starting with `/`).
- **Path Resolution:** Confirm all `/docs/**/*.md` files resolved by the blueprint actually exist.
- **Ghost Check:** Ensure no `docs/docs/` nested path errors exist.

## Phase 2: Architectural Compliance (SRW)
- **Skill Audit:** Scan `/skills` and `service.ts` files for logic branching (if/for/while).
- **Rule Audit:** Verify that `/rules` contain pure business logic with no direct I/O, DB, or env access.
- **Repo Hygiene:** Verify no runtime env files or generated test/coverage artifacts are tracked in git.
- **Naming:** Check that `.cursor/` and `.vscode/` metadata are whitelisted.

## Phase 3: Resource Audit
- **Token Health:** Report on session weight and recommend `/compact` if necessary.
