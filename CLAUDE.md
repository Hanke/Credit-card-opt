# Credit Card Optimizer

Monorepo: `backend/` is a Rails 8.1 API-only app (PostgreSQL), `frontend/` is React 19 + TypeScript (Vite). See README.md for setup and run commands.

## Backend architecture rules

Use service objects as much as possible. Keep controllers, models, and jobs skinny.

- **Service objects** live in `backend/app/services/` and hold business logic and multi-step operations. One class per operation, named after the action (e.g. `Cards::RecommendBest`), with a single public entry point (`call`).
- **Controllers** only parse params, call a service, and render a response. No business logic, no direct multi-model orchestration.
- **Models** hold associations, validations, scopes, and simple attribute-level helpers. No workflows or orchestration.
- **Jobs** only unpack their arguments and delegate to a service.

When a controller, model, or job starts accumulating logic, extract it into a service rather than growing it in place.

## Conventions

- All API routes live under `/api/v1`.
- The frontend calls the API through the modules in `frontend/src/api/`, imported from `src/api` (never `client.ts` directly, which lint enforces). `client.ts` holds the shared fetch transport.
