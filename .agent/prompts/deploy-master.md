# Role: DevSecOps, Release Engineer, and Governance Lead
# Task: Consolidated Deployment + Release Workflow (Safe, Documented, Auto-Rollback)

**MANDATORY:** All deployments require explicit deployment mode (patch | full)

**Target Environment:** {{ENVIRONMENT}} (test | stage | prod)
**Deployment Mode:** {{MODE}} (patch | full) - REQUIRED
**Release Version (prod full only):** {{VERSION}}
**Release Notes (prod full only):** {{DESCRIPTION}}

Your objective is to deploy the current `dev` state to **{{ENVIRONMENT}}** with the specified mode, ensuring data integrity, identity preservation, and documentation alignment. If **{{ENVIRONMENT}} = prod** and **{{MODE}} = full**, build a release package and deploy with auto-rollback enabled.

---

## 1. Analysis & Documentation Sync (Release-Gated)
- **Scan Codebase:** Review recent changes.
- **Update docs if needed:** `docs/CONTEXT.md`, `docs/CONTRIBUTING.md`, `docs/APPLICATION_BLUEPRINT.md` only when new capabilities or governance changes are introduced.
- **Confirm versioning in dev:** Ensure package versions/changelog align to the target release before packaging.
- **Verify Deployment Script:** Read `deploy/release-manager.sh` (and `deploy/release-to-prod.sh` if used). Confirm auto-backups and auto-rollback behavior. Note: production targets `dapoc`.

## 2. Pre-Flight Check (Local)
- **Branch Sync**: Ensure you are on the correct branch and pushed to `origin`.
- **SRW Compliance**: Run `npm run lint` and `npm run build` in both `frontend` and `backend`.
- **Blueprint Version**: Check `docs/APPLICATION_BLUEPRINT.md` for the latest version bump.

## 3. Multi-Layer Data Protection (Mandatory)
Before touching the code, secure the data:
- **Remote DB Backup**:
  ```bash
  ssh {{ENVIRONMENT}} "docker exec supabase_db_DAP pg_dump -U postgres -d postgres --schema=public --no-owner --no-acl | gzip > /data/dap/backups/pre-deploy-{{VERSION}}-$(date +%Y%m%d).sql.gz"
  ```
- **Code Snapshot**: Deployment scripts should auto-backup code to `/data/dap/backups/code-*.tar.gz`.

## 4. Deployment Mode & Execution (MANDATORY)

### Deployment Modes
**FULL Deployment** (Use when):
- New features with UI changes
- Database schema changes
- Dependency updates
- Major bug fixes
- First deployment of the day
- Takes ~5-10 minutes

**PATCH Deployment** (Use when):
- Backend logic fixes (no schema changes)
- Configuration updates
- Script updates
- Documentation changes
- Small backend-only changes
- Takes ~1-2 minutes

### Execution Paths

**Non-Production (test/stage):**
```bash
./scripts/deploy.sh <mode> <environment>

# Examples:
./scripts/deploy.sh full test
./scripts/deploy.sh patch test
./scripts/deploy.sh full stage
./scripts/deploy.sh patch stage
```

**Production (prod):**
- **Full release (REQUIRED for prod full):**
  ```bash
  VERSION={{VERSION}} DESCRIPTION="{{DESCRIPTION}}" ./deploy/create-release.sh
  ./deploy/release-manager.sh deploy releases/<package>.tar.gz --auto-rollback
  # Or wrapper (auto-rollback default):
  ./deploy/release-to-prod.sh releases/<package>.tar.gz
  ```
- **Patch release (prod patch):**
  ```bash
  ./deploy/release-manager.sh patch --env=prod
  ```

**Version Synchronization:**
- Full deployments automatically bump version
- Patch deployments preserve current version
- Manual sync: `./scripts/sync-versions.sh` (if needed)

## 5. Database Schema Sync (Prisma Guardrails)
- The deployment script executes `npx prisma migrate deploy`.
- **Drift Protection**: If migration fails:
  1. Check `npx prisma migrate status`.
  2. Use `npx prisma migrate resolve --applied <MIGRATION_NAME>` ONLY if schema already matches.
  3. **NEVER** use `migrate reset` on non-local environments.

## 6. Verification & Health Audit
- **Service Verification**: `ssh {{ENVIRONMENT}} "/usr/local/bin/pm2 list"` (all `online`).
- **Connectivity**: `curl -s http://{{ENVIRONMENT_URL}}/health`.
- **Functional Check**: Confirm the deployed feature works in the UI.
- **Prod Quick Verification**: `./scripts/verify-production.sh --quick`.

## 7. Rollback & Recovery
- **Quick Rollback**: `ssh {{ENVIRONMENT}} "/usr/local/bin/pm2 rollback dap-backend"`.
- **Full Code Restore**: Restore latest `/data/dap/backups/code-*.tar.gz`.
- **DB Restore**:
  ```bash
  ssh {{ENVIRONMENT}} "gunzip -c /data/dap/backups/pre-deploy-*.sql.gz | docker exec -i supabase_db_DAP psql -U postgres -d postgres"
  ```

---

## Output Requirements
1. **Deployment Readiness Report**:
   - Doc changes (if any)
   - Release preview (current + target version)
   - Safety confirmation (backups + auto-rollback armed)
   - Blueprint alignment notes
2. **Revised docs** (full content only if updated).
3. **Final Execution Block** (commands executed, including auto-rollback invocation for prod full).
4. **Deployment Success Log**.
5. **Database Migration Status Report**.
6. **Verification Results**.
