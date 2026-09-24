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
```

## Conventions

- All API routes live under `/api/v1` (`backend/config/routes.rb`).
- The frontend talks to the API through `frontend/src/api/client.ts`. In development the Vite proxy handles the origin; in production set `VITE_API_URL`.
- CORS is configured in `backend/config/initializers/cors.rb` and reads `FRONTEND_ORIGIN`.
