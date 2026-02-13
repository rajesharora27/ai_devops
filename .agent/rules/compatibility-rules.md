# Backward Compatibility Rules

**Status**: CRITICAL - Blocking for all Schema/Data changes.

## 1. Data Integrity Principle

NEVER break existing data. All schema changes MUST be backward compatible to ensure zero-downtime deployments and support existing records.

## 2. Prisma Schema Modifications

When modifying `schema.prisma`:

1. **No New NOT NULL**: NEVER add `NOT NULL` constraints to existing tables without a default value or a backfill plan.
2. **No Column Drops**: NEVER drop columns that are still being used by any deployed version of the code.
3. **No Renames**: NEVER rename columns without a proper migration path (Add new -> Copy data -> Update code -> Drop old).
4. **Safety First**: ALWAYS add new columns as nullable or with default values.
5. **Review**: ALWAYS review the generated `migration.sql` before applying it.
6. **Staging Verification**: ALWAYS test on `dapstage` (which holds production data) before applying to `dapprod`.

## 3. Data Migrations

If creating tables or fields that replace existing data:

1. **Migration Scripts**: Create a data migration script in `scripts/` (e.g., `scripts/migrate-[feature]-data.ts`).
2. **Local Test**: Test migration locally with a subset of dev data.
3. **Dapstage Test**: Run migration on `dapstage` BEFORE deploying the new application code.
4. **Verify Integrity**: Verify data integrity on `dapstage` (check record counts, ensure no orphaned records).
5. **Atomic Deploy**: Deploy new code only after data is ready.

## 4. Pre-Change Checklist

Before ANY schema change, verify:
- [ ] Will existing records remain valid?
- [ ] Will existing code handle the new schema without crashing?
- [ ] Does this need a data migration script?
- [ ] Can we rollback safely?
- [ ] Have we backed up the database?

If unsure, ASK for clarification before proceeding.
