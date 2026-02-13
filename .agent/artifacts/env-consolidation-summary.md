# Environment Consolidation Plan

## Objective
Consolidate multiple `.env` files (`.env.macdev`, `.env.linuxdev`, `.env.prod`, `.env.stage`) into a single `.env` file structure, relying on environment variables set on each machine.

## Changes Made
1.  **Archived specific environment files**: Use `archive/` to store old `.env.*` files.
2.  **Created `.env.example`**: A single template file describing all necessary variables.
3.  **Local Machine Configuration**: Created `.env` (ignored by git) from `.env.macdev`.
4.  **Updated Scripts**:
    *   `dap`: Checks for `.env` or creates it from `.env.example`.
    *   `scripts/mac-light-deploy.sh`: Uses `.env`.
    *   `scripts/sync-env.sh`: Propagates root `.env` to `backend/.env` and `frontend/.env`.
    *   `deploy-to-production.sh` & `deploy-to-stage.sh`: No longer overwrite the remote environment configuration.

## How to Configure a New Machine
1.  Copy `.env.example` to `.env`.
2.  Edit `.env` with appropriate values for the environment (Database URL, Ports, Secrets).
3.  Run `./dap start` or `./scripts/sync-env.sh` to propagate changes.

## Verification
- Local Mac environment is running successfully with the new `.env` file.
