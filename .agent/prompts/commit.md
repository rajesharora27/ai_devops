# Role: Governance Lead
# Task: Sync, Document, and Commit Changes

Your objective is to reconcile the current state of the codebase with our core documentation and finalize the change-cycle with a clean Git commit.

### 1. Context & Scope Anchor
- **Scan Files:** Analyze the recent changes
- **Read `docs/CONTEXT.md`**: Identify what needs to be updated to reflect the current feature set.
- **Read `docs/CONTRIBUTING.md`**: Ensure the standards still align with our "Zero Logic Leak" policy.
- **Read `docs/APPLICATION_BLUEPRINT.md`**: Ensure architecture requirements reflect any new patterns, constraints, or governance changes introduced in the codebase.

### 2. Documentation Hardening (Skills/Rules/Workflows)
Refactor and clean the documentation based on the following:
- **Clean `docs/CONTEXT.md`**: Consolidate the "Current State" section. Remove deprecated features and ensure every new feature is listed as a system capability.
- **Update `docs/CONTRIBUTING.md`**: If new patterns or specific library restrictions (e.g., ZTNA-specific security rules) have emerged during development, update them.
- **Update `docs/APPLICATION_BLUEPRINT.md`**: Reflect any new architecture rules, workflow constraints, settings deprecations, telemetry template formats, or governance checks added since the last update.

### 3. Verification & Gap Audit
Before committing, provide a **"Sync Summary"**:
- **Consolidation Report:** What legacy text was removed?
- **New Features:** Which features are now officially "Live" in context.md?
- **Compliance Check:** Confirm whether any errors or misconfigurations were introduced in the code that the documentation now needs to govern.
- **Blueprint Alignment:** Call out any architecture changes that required updates to `docs/APPLICATION_BLUEPRINT.md`.

### 4. Git Execution Protocol
Execute the Git workflow directly (do not output commands):
- Stage `docs/CONTEXT.md`, `docs/CONTRIBUTING.md`, `docs/APPLICATION_BLUEPRINT.md`, and any relevant code/doc files touched in this cycle.
- Create a professional, conventional commit (e.g., "feat(arch): sync governance docs with new ZTNA workflows").
- Push to `origin` on the current branch.

### 5. Grounding & Hallucination Guardrail
- **No Guessing:** If you see a file in the repo that is not mapped in `context.md`, ASK if it should be documented or deleted.
- If the `git push` destination is unclear, default to the current active branch.

### Output Requirement
1. **Revised `docs/CONTEXT.md`** (Full content).
2. **Revised `docs/CONTRIBUTING.md`** (Full content).
3. **Revised `docs/APPLICATION_BLUEPRINT.md`** (Full content).
4. **Commit Result** (commit hash + push status).
