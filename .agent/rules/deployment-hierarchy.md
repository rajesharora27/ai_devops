# Deployment & Environment Hierarchy

**Status**: CRITICAL for Deployments.

## 1. Environment Definitions

### **dev (Local)**
- **Role**: Primary development environment.
- **Capabilities**: Has full git access, makes all changes.
- **Actions**: Deploys TO remote environments via scripts.

### **daptest (Remote)**
- **Role**: Integration testing.
- **Path**: `/data/dap/app/`
- **Actions**: Deploy via `./scripts/deploy-to-test.sh`.
- **Constraint**: NO git - files are copied from dev.

### **dapstage (Remote)**
- **Role**: Production staging with **PROD DATA**.
- **Path**: `/data/dap/app/`
- **Actions**: Deploy via `./scripts/deploy-to-stage.sh`.
- **Critical**: Verify backward compatibility here before production.

### **dapprod (Remote)**
- **Role**: Production.
- **Path**: `/data/dap/app/`
- **Actions**: Deploy via `./deploy/release-manager.sh --env=prod`.

## 2. Critical Deployment Rules

1. **Uni-directional**: Deployment always flows FROM dev TO remote.
2. **No Remote Git**: Remote environments (test/stage/prod) do NOT have git. Do not attempt git operations there.
3. **Data Safety**: Always test schema changes on `dapstage` first since it contains production data.
4. **Script Automation**: Deployment scripts handle file copying; no manual `scp` or `git pull` needed on remotes.
