#!/usr/bin/env bash
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="${PROJECT_ROOT:-$(cd "$SKILL_DIR/../../.." && pwd)}"
API_URL="${API_URL:-http://localhost:3000}"
APP_URL="${APP_URL:-http://localhost:5173}"
LOG_DIR="${LOG_DIR:-$ROOT/walkthroughs/.logs}"
mkdir -p "$LOG_DIR"

status=0
check() {
  if "$@" >/dev/null 2>&1; then echo "✔ $*"; else echo "✖ $* (missing)"; status=1; fi
}

echo "== tools"
check command -v ffmpeg
check command -v ffprobe
check command -v node
if command -v say >/dev/null 2>&1; then echo "✔ say (narration on)"; else echo "⚠ say not found: pass --no-narration to record.mjs"; fi
if [ -d "$ROOT/frontend/node_modules/playwright" ]; then echo "✔ playwright module"; else echo "✖ playwright module: run 'cd frontend && npm install'"; status=1; fi
if ls "$HOME/Library/Caches/ms-playwright" 2>/dev/null | grep -q '^chromium-'; then echo "✔ chromium browser"; else echo "✖ chromium browser: run 'cd frontend && npx playwright install chromium'"; status=1; fi

echo "== servers"
up() { curl -fsS --max-time 2 "$1" >/dev/null 2>&1; }

if up "$API_URL/api/v1/health"; then
  echo "✔ backend at $API_URL"
else
  echo "… starting backend (dev) on :3000, log: $LOG_DIR/backend.log"
  (cd "$ROOT/backend" && nohup bin/rails server -p 3000 >"$LOG_DIR/backend.log" 2>&1 &)
  for _ in $(seq 1 60); do up "$API_URL/api/v1/health" && break; sleep 1; done
  if up "$API_URL/api/v1/health"; then echo "✔ backend at $API_URL"; else echo "✖ backend did not come up; see $LOG_DIR/backend.log"; status=1; fi
fi

if up "$APP_URL"; then
  echo "✔ frontend at $APP_URL"
else
  echo "… starting frontend on :5173, log: $LOG_DIR/frontend.log"
  (cd "$ROOT/frontend" && nohup npm run dev >"$LOG_DIR/frontend.log" 2>&1 &)
  for _ in $(seq 1 40); do up "$APP_URL" && break; sleep 1; done
  if up "$APP_URL"; then echo "✔ frontend at $APP_URL"; else echo "✖ frontend did not come up; see $LOG_DIR/frontend.log"; status=1; fi
fi

echo "== seed data"
if [ "$status" -eq 0 ]; then
  count=$(cd "$ROOT/backend" && bin/rails runner 'puts CreditCard.count' 2>/dev/null | tail -1 || echo 0)
  if [ "${count:-0}" -gt 0 ]; then
    echo "✔ $count credit cards in the catalogue"
  else
    echo "… catalogue empty, running db:seed"
    (cd "$ROOT/backend" && bin/rails db:seed >"$LOG_DIR/seed.log" 2>&1) && echo "✔ seeded" || { echo "✖ seed failed; see $LOG_DIR/seed.log"; status=1; }
  fi
fi

exit $status
