# Pre-Production Verification Protocol

**Purpose:** MANDATORY checks before ANY production deployment  
**Status:** BLOCKING - Cannot deploy to prod without passing ALL checks  
**Rationale:** Production data is irreplaceable. Zero tolerance for data loss.

---

## CRITICAL: Production Deployment Rules

### Rule #1: NEVER Deploy to Production First
- ✅ ALWAYS deploy to test first
- ✅ ALWAYS deploy to stage second
- ✅ ONLY deploy to prod after both pass verification
- ❌ NEVER skip staging validation

### Rule #2: ALWAYS Have Recent Backup
- Database backup < 24 hours old
- Code snapshot before deployment
- Verified restore procedure tested recently

### Rule #3: ALWAYS Verify on Stage First
- Stage must mirror production exactly
- Test with production data copy (anonymized)
- All critical features must be manually verified

---

## Pre-Production Checklist (MANDATORY)

Before deploying to production, ALL items must be checked:

### Phase 1: Schema Compatibility (BLOCKING)

- [ ] Run `./scripts/check-migration-safety.sh`
  - Must return exit code 0 (no errors, no warnings)
  - If warnings exist, must be manually reviewed and approved

- [ ] Review ALL migration SQL files
  ```bash
  ls -lt backend/prisma/migrations | head -5
  cat backend/prisma/migrations/*/migration.sql
  ```
  - [ ] No DROP COLUMN statements
  - [ ] No DROP TABLE statements
  - [ ] No RENAME COLUMN statements
  - [ ] No SET NOT NULL without backfill
  - [ ] No ALTER TYPE DROP statements
  - [ ] All new columns are nullable OR have defaults
  - [ ] All UNIQUE constraints verified safe

- [ ] Verify code handles nullable fields
  ```bash
  # Search for direct field access without null checks
  rg "task\.(statusNotes|newField)\." frontend/src/ backend/src/
  # Should use: task.statusNotes?.
  ```

- [ ] Check for enum value usage
  - [ ] No code references removed enum values
  - [ ] All new enum values are additive only

### Phase 2: Test Environment Validation (BLOCKING)

- [ ] Deploy to test successfully
  ```bash
  ./scripts/deploy-to-test.sh
  ```

- [ ] Verify data integrity on test
  ```bash
  ssh daptest "docker exec supabase_db_DAP psql -U postgres -d postgres -c \"
    SELECT 
      'Customer' as entity, COUNT(*) as count FROM \\\"Customer\\\"
    UNION ALL
    SELECT 'CustomerProduct', COUNT(*) FROM \\\"CustomerProduct\\\" WHERE \\\"deletedAt\\\" IS NULL
    UNION ALL
    SELECT 'AdoptionPlan', COUNT(*) FROM \\\"AdoptionPlan\\\"
    UNION ALL
    SELECT 'CustomerTask', COUNT(*) FROM \\\"CustomerTask\\\" WHERE \\\"deletedAt\\\" IS NULL;
  \""
  ```
  - [ ] Counts match pre-deployment
  - [ ] No unexpected data loss

- [ ] Manual feature testing on test
  - [ ] Login works
  - [ ] Customer list loads
  - [ ] Existing adoption plans display correctly
  - [ ] Can view existing customer products
  - [ ] Can edit existing adoption plans
  - [ ] Can update existing task statuses
  - [ ] All historical data displays (notes, audit trails)
  - [ ] Create new adoption plan works
  - [ ] License filtering works correctly

### Phase 3: Staging Environment Validation (BLOCKING)

- [ ] Deploy to staging
  ```bash
  ./scripts/deploy-to-stage.sh
  ```

- [ ] Copy production database to staging (anonymized)
  ```bash
  # Backup prod, sanitize, restore to stage
  ssh stage "restore-from-prod-anonymized.sh"
  ```

- [ ] Full feature verification on staging with PROD data
  - [ ] All existing customers load
  - [ ] All existing products load
  - [ ] All existing adoption plans load
  - [ ] All existing tasks display with correct data
  - [ ] Historical notes/audit trails intact
  - [ ] Can perform all CRUD operations
  - [ ] License filtering matches expectations
  - [ ] No GraphQL errors in console
  - [ ] No React errors in console

- [ ] Performance verification
  - [ ] Page load times acceptable
  - [ ] GraphQL query response times < 2s
  - [ ] No N+1 query issues
  - [ ] Database connection pool stable

### Phase 4: Rollback Preparation (MANDATORY)

- [ ] Create production backup
  ```bash
  ssh prod "docker exec supabase_db_DAP pg_dump -U postgres -d postgres | gzip > /data/dap/backups/pre-deploy-$(date +%Y%m%d-%H%M%S).sql.gz"
  ```

- [ ] Verify backup is valid
  ```bash
  ssh prod "gunzip -c /data/dap/backups/pre-deploy-*.sql.gz | head -100"
  # Should show SQL statements, not errors
  ```

- [ ] Document current production state
  - Record data counts for all critical tables
  - Note current version number
  - Save PM2 process list

- [ ] Test rollback procedure on staging
  ```bash
  # Verify we can restore backup if needed
  ssh stage "test-restore-from-backup.sh"
  ```

### Phase 5: Production Deployment (EXECUTE)

- [ ] Double-check all previous phases are complete

- [ ] Notify team (if applicable)
  - Deployment window
  - Expected downtime (if any)
  - Rollback contact person

- [ ] Deploy to production
  ```bash
  ./deploy/scripts/release.sh deploy
  ```

- [ ] Monitor deployment logs in real-time
  - Watch for any errors
  - Verify migrations complete
  - Check PM2 process restart

### Phase 6: Post-Deployment Verification (CRITICAL)

- [ ] Verify all services are online
  ```bash
  ssh prod "pm2 list"
  # All should show "online" status
  ```

- [ ] Check health endpoint
  ```bash
  curl -s https://dap.cisco.com/health
  # Should return 200 OK with health status
  ```

- [ ] Verify data integrity
  ```bash
  ssh prod "docker exec supabase_db_DAP psql -U postgres -d postgres -c \"
    SELECT 
      'Customer' as entity, COUNT(*) as count FROM \\\"Customer\\\"
    UNION ALL
    SELECT 'CustomerProduct', COUNT(*) FROM \\\"CustomerProduct\\\" WHERE \\\"deletedAt\\\" IS NULL
    UNION ALL
    SELECT 'AdoptionPlan', COUNT(*) FROM \\\"AdoptionPlan\\\"
    UNION ALL
    SELECT 'CustomerTask', COUNT(*) FROM \\\"CustomerTask\\\" WHERE \\\"deletedAt\\\" IS NULL;
  \""
  ```
  - [ ] **CRITICAL**: Counts MUST match pre-deployment numbers
  - [ ] If ANY count is lower: ROLLBACK IMMEDIATELY

- [ ] Manual smoke testing on production
  - [ ] Login with real user account
  - [ ] Load existing customer (verify data intact)
  - [ ] View existing adoption plan (verify tasks intact)
  - [ ] Check task notes/audit trail visible
  - [ ] Perform one edit operation (verify saves)
  - [ ] Verify license filtering works

- [ ] Monitor for errors (15 minutes)
  ```bash
  ssh prod "pm2 logs dap-backend --lines 100"
  # Watch for any errors or exceptions
  ```

- [ ] Check browser console (no errors)
  - Open production URL in browser
  - Check DevTools console for errors
  - Verify no GraphQL errors

### Phase 7: Rollback Decision Point

**IF ANY OF THESE OCCUR - ROLLBACK IMMEDIATELY:**

❌ Data count decreased (ANY table)  
❌ Adoption plans not loading  
❌ Customer products not loading  
❌ GraphQL errors on existing data  
❌ Frontend errors in console  
❌ Users report missing data  
❌ Application crashes or errors  

**Rollback Procedure:**
```bash
# 1. Stop services
ssh prod "pm2 stop all"

# 2. Restore database
ssh prod "gunzip -c /data/dap/backups/pre-deploy-*.sql.gz | docker exec -i supabase_db_DAP psql -U postgres -d postgres"

# 3. Revert code
ssh prod "cd /data/dap/app && git reset --hard <previous_commit>"

# 4. Restart services
ssh prod "pm2 restart all"

# 5. Verify restoration
ssh prod "docker exec supabase_db_DAP psql -U postgres -d postgres -c \"SELECT COUNT(*) FROM \\\"AdoptionPlan\\\";\""
```

---

## Additional Production Safeguards

### 1. Read-Only Dry Run (Recommended)

Before actual deployment, run a simulation:

```bash
# On staging with prod data
ssh stage "cd /data/dap/app && npx prisma migrate deploy --dry-run"
```

### 2. Gradual Rollout (For High-Risk Changes)

If schema changes are significant:
1. Deploy to 1 backend instance only (canary)
2. Monitor for 30 minutes
3. If stable, deploy to remaining instances
4. If issues, rollback is easier (only 1 instance)

### 3. Maintenance Window (For Breaking Changes)

If absolutely must make breaking change:
1. Schedule maintenance window
2. Notify all users
3. Take full backup
4. Put application in read-only mode
5. Apply changes
6. Verify thoroughly before restoring write access

---

## Production Data Protection Layers

### Layer 1: Prevention (Before Deployment)
- Automated migration safety checker
- Code review for schema changes
- Staging validation with prod data copy
- This checklist

### Layer 2: Protection (During Deployment)
- Automatic database backup before deployment
- Code snapshot before deployment
- Monitored deployment process
- Immediate verification after deployment

### Layer 3: Recovery (After Issues)
- Recent backup < 24 hours
- Documented rollback procedure
- Tested restore process
- Emergency contact list

---

## Commitment

**ZERO TOLERANCE FOR PRODUCTION DATA LOSS**

If we are not 100% certain that existing production data will remain intact and accessible, we DO NOT deploy.

When in doubt:
1. Test more on staging
2. Add more safety checks
3. Create migration plan
4. Ask for review
5. Wait for another deployment cycle

**Better to delay a release than to lose customer data.**

---

## Sign-Off Requirements

Before deploying to production, the following must sign off:

- [ ] **Developer**: All checks passed, confident in changes
- [ ] **QA/Tester**: Verified on staging with prod data
- [ ] **DevOps**: Backup verified, rollback tested
- [ ] **Tech Lead**: Reviewed schema changes, approved deployment

(Adjust based on your team structure)

---

## Emergency Contacts

If deployment goes wrong:

1. **Immediate**: Stop deployment, assess impact
2. **If data loss detected**: Execute rollback immediately
3. **Document**: What went wrong, root cause, how to prevent
4. **Post-mortem**: Review and improve this checklist

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-05 | Initial pre-production verification protocol |
