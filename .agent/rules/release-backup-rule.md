# Release Backup & Version Tracking Rule

**Status**: MANDATORY for all production releases and patches.

## 1. Policy

- **Every release and every patch** MUST create a pre-deploy backup (database + schema/code snapshot) and MUST record the deployed version and backup path in the database.
- Backups are **versioned**: each snapshot is tagged with the version being deployed and the deployment type (`release` or `patch`).
- **Retention** is configurable; a fixed number of release backups are kept. Older snapshots are pruned automatically so disk does not grow unbounded.

## 2. Requirements

### 2.1 Backup on Deploy

- Before deploying (full release or patch), create a snapshot under `backups/releases/<timestamp>` containing:
  - Database dump (passwords excluded)
  - Backend and frontend code snapshots
  - Environment info (Node/npm versions, PM2 status)
  - Current Prisma migration state
- Tag each snapshot with:
  - `VERSION.txt` – version being deployed (e.g. `4.0.84`)
  - `DEPLOYMENT_TYPE.txt` – `release` or `patch`
- Record in DB: insert a row into `ReleaseRecord` (version, deploymentType, backupPath, schemaRevision, recordedAt) after a successful deploy so that:
  - We know which backup belongs to which release/patch
  - We can check schema compatibility (e.g. before restore) using `schemaRevision`

### 2.2 Retention (Configurable)

- **Default**: Keep the **30** most recent release snapshots. Older snapshots are deleted automatically after each new snapshot is created.
- **Configuration**: The retention count MUST be configurable so it can be changed without editing code.
  - **Mechanism**: Environment or script variable `RELEASE_BACKUP_RETENTION_COUNT` (integer).
  - **Default**: `30` if not set.
  - **Where**: Set in the deployment environment (e.g. `~/.bashrc` on the deploy runner, or in the CI/deploy script) or pass into the release-manager script. Document in deployment docs.
- Pruning runs on the server after creating a new snapshot: list snapshot directories by modification time (newest first), keep the first `RELEASE_BACKUP_RETENTION_COUNT`, remove the rest.

### 2.3 Schema Compatibility

- At deploy time, store the current schema revision (last Prisma migration name) in `ReleaseRecord.schemaRevision`.
- Before restoring a backup, check that the target app’s migrations are compatible with the backup’s schema (e.g. compare migration history or `schemaRevision`). Document the restore procedure in deployment/disaster-recovery docs.

## 3. Recommendations (Best Practices)

1. **Test restores**: Periodically restore from a release-tagged backup to a non-production environment to validate the backup and restore path.
2. **Retention policy**: Start with 30; increase if you need longer history or decrease to save disk. Keep retention configurable.
3. **Monitoring**: Optionally alert if backup creation fails or if pruning fails (e.g. disk full).
4. **Off-site copies**: For critical environments, consider copying the latest N release snapshots to off-site or object storage; this rule does not require it but recommends considering it for disaster recovery.
5. **No manual deletion of recent backups**: Avoid manually deleting snapshots that are within the retention window; let the automated prune step manage cleanup so that retention is predictable.

## 4. Implementation

- **Script**: `deploy/release-manager.sh` – creates snapshot, tags with version/type, records in `ReleaseRecord`, and prunes old snapshots using `RELEASE_BACKUP_RETENTION_COUNT`.
- **Table**: `ReleaseRecord` (see Prisma schema and migration `20260130180000_add_release_record`).
- **Docs**: `docs/deployment/RELEASE_BACKUP_AND_VERSION.md` – describes the flow, table, and configuration (including retention).

## 5. Compliance

- New deployment scripts or pipelines that perform production releases MUST follow this rule (create versioned backup, record in DB, respect configurable retention).
- Changing the retention count MUST be done via configuration (`RELEASE_BACKUP_RETENTION_COUNT`), not by hardcoding a new number in the script.
