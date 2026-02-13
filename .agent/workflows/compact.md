---
description: Reduce token footprint while maintaining 100% SRW compliance.
---

# Workflow: Context Compaction
Trigger: /compact

## Mission
Reduce token footprint while maintaining 100% SRW compliance.

## Steps
1. **Identify Essentials:** Retain @/docs/APPLICATION_BLUEPRINT.md and @/docs/CONTRIBUTING.md.
2. **Filter Active Files:** Identify all open files in the current workspace.
3. **Execution:** - Close all files NOT explicitly required for the current domain.
   - Summarize the 'Current State' of the DAP module in 3 bullet points.
   - **Reset Session:** Instruct the IDE to clear non-essential conversation history.
4. **Verification:** Report the 'New Context Weight' and estimated token savings.