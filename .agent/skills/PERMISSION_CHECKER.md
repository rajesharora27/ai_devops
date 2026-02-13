# Permission Checker Skill

Stateless tool for verifying Role-Based Access Control (RBAC) permissions across the Dynamic Adoption Plan (DAP) platform.

## Description
This skill implements the core logic for DAP's hybrid permission model, including system roles, resource-level permissions, and bidirectional inheritance (Product ↔ Solution).

## Interface
- **Tool Name:** `check_permission`
- **Inputs:**
    - `userId`: string - Unique identifier of the user.
    - `resourceType`: string - Type of resource (`PRODUCT`, `SOLUTION`, `CUSTOMER`).
    - `resourceId`: string | null - Precise resource ID or null for type-level access.
    - `requiredLevel`: string - Minimum level required (`READ`, `WRITE`, `ADMIN`).
- **Logic Rule:** Inherits logic from `.agent/rules/rbac-policy.json`.

## Usage
Used by resolvers and middlewares to enforce security boundaries without hardcoding hierarchy logic in every module.
