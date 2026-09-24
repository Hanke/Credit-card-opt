# Credit Card Optimizer

Monorepo with a Ruby on Rails JSON API and a React frontend.

```
backend/   Rails 8.1 API-only app (PostgreSQL)
frontend/  React 19 + TypeScript app built with Vite
bin/dev    Runs both dev servers together (foreman + Procfile.dev)
```

## Prerequisites

- Ruby 3.4 (see `backend/.ruby-version`)
- Node 22+
- PostgreSQL running locally
- foreman (`gem install foreman`) for `bin/dev`

## Setup

```sh
cd backend && bundle install && bin/rails db:create db:migrate && cd ..
cd frontend && npm install && cd ..
```

## Running

```sh
bin/dev
```

- API: http://localhost:3000 (health check at `/api/v1/health`)
- Frontend: http://localhost:5173 (proxies `/api/*` to the Rails server)

Or run them separately with `cd backend && bin/rails server` and `cd frontend && npm run dev`.

## Tests

```sh
cd backend && bundle exec rspec
cd frontend && npm run lint && npm run build
cd frontend && npm run test:e2e
```

The end-to-end suite (`frontend/e2e/`, Playwright) boots the Rails API in the `test` environment on port 3000 and the Vite dev server on port 5173, then drives the sign up, login, logout, and protected-route flows in a real browser. Run `npx playwright install chromium` once to download the browser. If a server is already listening on either port it is reused, so stop your dev server first if you want the test database.

## Conventions

- All API routes live under `/api/v1` (`backend/config/routes.rb`).
- The frontend talks to the API through `frontend/src/api/client.ts`. In development the Vite proxy handles the origin; in production set `VITE_API_URL`.
- CORS is configured in `backend/config/initializers/cors.rb` and reads `FRONTEND_ORIGIN`.

## Authentication

The API issues a signed JWT on signup/login. The frontend stores it in `localStorage` (key `auth_token`), sends it as `Authorization: Bearer <token>` on every request, and calls `/api/v1/auth/me` on startup to restore the session across reloads. A 401 from any endpoint other than login, signup, or logout means the session is invalid: the token is cleared and the user is redirected to `/login`. A 401 from login or signup is a credentials error and is shown in the form. If the startup check fails for any other reason (network error, 5xx) the token is kept and the user is asked to log in again, so a valid session survives a temporary outage.

Trade-off: `localStorage` is readable by any script on the page, so an XSS vulnerability would expose the token. This is accepted for the MVP. A hardened version would move the token to an `HttpOnly` cookie with CSRF protection.
