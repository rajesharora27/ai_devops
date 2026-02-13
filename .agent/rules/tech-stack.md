---
description: Technical Stack & Version Constraints
---

# Tech Stack Rules

> **Purpose:** Ensure all code adheres to the defined technology stack and version constraints to prevent regressions and incompatibility.

## 1. Core Frameworks (MANDATORY)

- **Frontend:** React 18+ (SPA) with Vite
- **Backend:** Node.js (v18+)
- **API:** GraphQL (Apollo Server / Client) with TypeGraphQL (Backend)
- **Database:** PostgreSQL with Prisma ORM
- **Language:** TypeScript 5.x (Strict Mode)

## 2. Style & UI (MANDATORY)

- **CSS:** Plain CSS / CSS Modules (primary), TailwindCSS (ALLOWED but verify version)
- **Component Library:** Material UI (MUI) v5
- **Icons:** FontAwesome (via shared wrapper)

## 3. Architecture Constraints

- **Modules:** All new backend logic MUST be placed in `src/modules/[domain]`.
- **Features:** All new frontend logic MUST be placed in `src/features/[feature]`.
- **Imports:** NO relative imports for features/modules (use `@features/`, `@modules/`).
- **Telemetry:** MUST use V2 Telemetry Expression Engine for all new logic.

## 4. Forbidden patterns

- ❌ `any` type in TypeScript (use `unknown` or specific types)
- ❌ Direct SQL queries (ALWAYS use Prisma)
- ❌ Client-side filtering/sorting for paginated data (ALWAYS server-side)
- ❌ Hardcoded secrets (ALWAYS use environment variables)
