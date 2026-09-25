

https://github.com/user-attachments/assets/8021e1b6-3e0d-4081-9a13-9ea7b29f2607





# Credit Card Optimizer

Monorepo with a Ruby on Rails JSON API and a React frontend.

```
backend/   Rails 8.1 API-only app (PostgreSQL)
frontend/  React 19 + TypeScript app built with Vite
bin/dev    Runs both dev servers together (foreman + Procfile.dev)
```

## Prerequisites

- Ruby 3.4.5 (see `backend/.ruby-version`; rbenv picks it up automatically)
- Node 22+
- PostgreSQL 14+ running locally and accepting connections from your OS user (`psql -l` should work without a password)
- foreman (`gem install foreman`) for `bin/dev`

## Setup (fresh clone)

```sh
git clone <repo-url> Credit-card-opt && cd Credit-card-opt

# 1. Backend: gems, database, env file
cd backend
bundle install
cp .env.example .env          # optional: defaults work for a local Postgres
bin/rails db:create db:migrate
cd ..

# 2. Frontend: packages, env file
cd frontend
npm install
cp .env.example .env          # optional: leave VITE_API_URL empty in development
cd ..
```

No secrets are needed to run locally. `backend/config/master.key` is not in the
repo on purpose; in development and test Rails generates its own signing key at
`backend/tmp/local_secret.txt` the first time it boots.

## Running

```sh
bin/dev
```

`bin/dev` starts both processes from the root `Procfile.dev` and stops both on Ctrl-C:

- API: http://localhost:3000 (health check at http://localhost:3000/api/v1/health)
- Frontend: http://localhost:5173 (proxies `/api/*` to the Rails server)

Open http://localhost:5173, click **Sign up**, enter an email and a password of
at least 8 characters, and you land on the dashboard logged in.

To run the servers separately: `cd backend && bin/rails server` and
`cd frontend && npm run dev`. `backend/bin/setup` also works: it installs gems,
prepares the database, and then execs `bin/dev` (pass `--skip-server` to stop
before that).

## Environment variables

Both apps run with zero configuration. Each has a committed `.env.example` that
documents every variable; copy it to `.env` (gitignored) only if you need to
change something.

### Backend (`backend/.env`)

Loaded by `dotenv-rails` in the development and test environments only. In
production, set real environment variables instead.

| Variable | Default | Purpose |
| --- | --- | --- |
| `DATABASE_URL` | unset (uses `config/database.yml`) | Postgres connection override, e.g. `postgres://postgres:postgres@localhost:5432`. Leave the database name out of the URL so `database.yml` still picks `credit_card_opt_development` or `credit_card_opt_test` per environment; a URL with a database name forces every environment, including the test suite, onto that database. |
| `FRONTEND_ORIGIN` | `http://localhost:5173` | Origin allowed by CORS (`config/initializers/cors.rb`). Only matters when the browser calls the API directly rather than through the Vite proxy. |
| `SECRET_KEY_BASE` | generated in dev/test | Signs JWTs (see below) and cookies. Required in production, or supply `RAILS_MASTER_KEY` to unlock `config/credentials.yml.enc`. |

There is no separate `JWT_SECRET`: tokens are signed with
`Rails.application.secret_key_base`, so rotating that key invalidates every
existing token.

### Frontend (`frontend/.env`)

Loaded by Vite. Only variables prefixed with `VITE_` reach the browser.

| Variable | Default | Purpose |
| --- | --- | --- |
| `VITE_API_URL` | empty | Base URL prepended to every API path in `src/api/client.ts`. Leave empty in development so requests hit the same origin and `vite.config.ts` proxies `/api/*` to `http://localhost:3000`. Set it (no trailing slash) when the built app is served from a different origin than the API, and set the backend's `FRONTEND_ORIGIN` to match. |

## Authentication

The API is stateless: it issues a signed JWT (HS256, 7-day expiry, user id in
`sub`) and expects it back on every request. The relevant code is
`backend/app/services/auth/`, `backend/app/controllers/concerns/authenticable.rb`,
and `frontend/src/auth/`.

### Endpoints

All under `/api/v1/auth`. Request and response bodies are JSON.

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| `POST` | `/signup` | none | Create a user. Returns `201` with `{ token, user }`, or `422` with `{ errors: [...] }`. |
| `POST` | `/login` | none | Exchange credentials for a token. Returns `200` with `{ token, user }`, or `401` with `{ errors: ["Invalid email or password"] }`. |
| `GET` | `/me` | Bearer | Return the current user. `401` if the token is missing, expired, or invalid. |
| `DELETE` | `/logout` | none | Returns `204`. Logout is client-side: the server keeps no session, so the client just discards the token. |

### Getting a token from the command line

```sh
# Sign up (or POST to /api/v1/auth/login with the same body afterwards)
curl -s -X POST http://localhost:3000/api/v1/auth/signup \
  -H 'Content-Type: application/json' \
  -d '{"email":"you@example.com","password":"password123"}'
# => {"token":"eyJhbGciOiJIUzI1NiJ9...","user":{"id":1,"email":"you@example.com","created_at":"..."}}

# Use it
TOKEN=eyJhbGciOiJIUzI1NiJ9...
curl -s http://localhost:3000/api/v1/auth/me -H "Authorization: Bearer $TOKEN"
# => {"user":{"id":1,"email":"you@example.com","created_at":"..."}}
```

### How the frontend uses it

1. The login and sign-up forms call `signup()` / `login()` in
   `src/api/client.ts`. On success `AuthProvider` stores the token in
   `localStorage` under the key `auth_token` (`src/auth/tokenStorage.ts`) and
   redirects to the dashboard.
2. `apiFetch()` in `src/api/client.ts` adds `Authorization: Bearer <token>` to
   every request when a token is stored.
3. On page load, if a token is stored, `AuthProvider` calls `GET /api/v1/auth/me`
   to restore the session (the app shows a "Checking your session" spinner
   meanwhile). A `401` means the token is dead: it is cleared and the user is
   sent to `/login`. Any other failure (network error, 5xx) keeps the token and asks
   the user to log in again, so a valid session survives a temporary outage.
4. A `401` from any endpoint other than login, signup, or logout triggers the
   same clear-and-redirect. A `401` from login or signup is a credentials error
   and is shown in the form.
5. Logout calls `DELETE /api/v1/auth/logout`, clears the stored token, and
   redirects to `/login`.

Trade-off: `localStorage` is readable by any script on the page, so an XSS
vulnerability would expose the token. This is accepted for the MVP. A hardened
version would move the token to an `HttpOnly` cookie with CSRF protection.

## Seed data

```sh
cd backend && bin/rails db:seed
```

Seeds the reward currencies and a catalogue of roughly 65 Canadian consumer
credit cards (Amex, TD, RBC, BMO, Scotiabank, CIBC, National Bank, Tangerine,
Rogers, Neo, PC Financial, Simplii, Desjardins, MBNA, Brim, Canadian Tire,
Home Trust, Walmart), each with a currency, a base earn rate, and dated
category reward rules. Seeding is idempotent: currencies are keyed on name,
cards on name, and rules on card + category + `effective_from`, so re-running
`db:seed` refreshes existing rows instead of duplicating them. The data lives
in `backend/db/seeds/reward_currencies.rb` and one file per issuer under
`backend/db/seeds/cards/`, and is written through the
`Seeds::UpsertRewardCurrency` and `Seeds::UpsertCreditCard` services.

How rewards are modelled:

- **Cash-back cards** use the `Cash Back` currency at 1 cent per point and
  store the percentage as the earning rate (4% back is `4.0`), so $150 at 4.0
  earns 600 points worth $6.00. WestJet dollars, Canadian Tire Money,
  BonusDollars, Brim points and Walmart Reward Dollars follow the same
  convention since they are worth one cent each.
- **Points currencies** store points per dollar; the valuation lives on the
  currency (`cents_per_point`: Membership Rewards 1.0, Aeroplan 1.5, Avion
  1.0, Scene+ 1.0, BMO Rewards 0.7, CIBC Aventura 1.0, PC Optimum 0.1, TD
  Rewards 0.5, Air Miles 10.5 per mile) with the rationale in `description`.
- **Categories** come from `PurchaseCategories::ALL`. Streaming maps to
  `entertainment`, Air Canada and WestJet bonuses to `flights`, and a card
  whose travel bonus covers everything gets `travel`, `flights` and `hotels`
  rules. Flat-rate cards get a single `general` rule at their flat rate.
- **Merchant-specific rates** (Scene+ at Empire grocers, Loblaw banners,
  Shoppers Drug Mart, Neo partners, Costco, Walmart) are described in `notes`
  rather than modelled as rules, and recurring bill payments are not a
  category.
- **Tangerine** lets cardholders choose their categories; the seed picks
  groceries and dining.
- **`spend_cap_cents` is always annual**; monthly caps are multiplied by 12
  and the issuer's wording is kept in the rule notes. The MVP calculator
  ignores caps in the math but surfaces them in each result's explanation.

Rates are a best-effort snapshot of public earn rates and are not fetched from
issuers, so check `db/seeds/cards/<issuer>.rb` before relying on a specific
number. `spec/db/seeds_spec.rb` loads the seeds and checks the invariants
above.

## Tests

```sh
cd backend && bundle exec rspec
cd frontend && npm run lint && npm run build
cd frontend && npm run test:e2e
```

The end-to-end suite (`frontend/e2e/`, Playwright) boots the Rails API in the `test` environment on port 3000 and the Vite dev server on port 5173, then drives the sign up, login, logout, and protected-route flows in a real browser. Run `npx playwright install chromium` once to download the browser. If a server is already listening on either port it is reused, so stop your dev server first if you want the test database.

## Troubleshooting

- **`bin/dev` says foreman is not installed**: `gem install foreman`, or run the two servers separately as shown above.
- **`db:create` fails with a connection or password error**: Postgres is not running, or it does not trust your OS user. Start it, or set `DATABASE_URL` in `backend/.env` as described in the table above.
- **Port 3000 or 5173 already in use**: stop the other process, or run `bin/rails server -p <port>` and update the proxy target in `frontend/vite.config.ts`.
- **Browser shows CORS errors**: you are calling the API directly (a non-empty `VITE_API_URL`). Set `FRONTEND_ORIGIN` on the backend to the app's origin and restart the API.
- **Every request returns 401 after pulling changes**: the signing key changed. Log out and log back in (or clear `auth_token` in localStorage).

## Conventions

- All API routes live under `/api/v1` (`backend/config/routes.rb`).
- The frontend talks to the API through `frontend/src/api/client.ts`. In development the Vite proxy handles the origin; in production set `VITE_API_URL`.
- CORS is configured in `backend/config/initializers/cors.rb` and reads `FRONTEND_ORIGIN`.
- Backend business logic lives in service objects under `backend/app/services/`; controllers, models, and jobs stay thin (see `CLAUDE.md`).
