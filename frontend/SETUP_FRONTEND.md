# Fix the empty frontend (fill scaffolds + wire A1 Register page)

Your frontend/ config files are all 0 bytes — the Vite app was never scaffolded.
These files fill them. Your existing src/api/ and src/pages/ A1 files are preserved.

## Where each file goes
```
frontend/package.json          <- fill (was empty)
frontend/vite.config.js        <- fill (was empty)
frontend/index.html            <- fill (was empty)
frontend/src/main.jsx          <- fill (was empty)
frontend/src/App.jsx           <- fill (was empty) — has /register route wired
frontend/src/index.css         <- new (minimal styles)
```
Your existing (keep, do NOT overwrite):
```
frontend/src/api/client.js         (A1)
frontend/src/api/auth.api.js       (A1)
frontend/src/pages/auth/Register.jsx (A1)
```

## Install
```bash
cd ~/Documents/AgroMart/frontend
# copy the fill files in (from this bundle), then:
npm install
```
This installs React 18, react-dom, react-router-dom, and Vite 5 — all stable.

## Run (two terminals)
```bash
# terminal 1 — backend (leave running)
cd ~/Documents/AgroMart/backend && npm run dev

# terminal 2 — frontend
cd ~/Documents/AgroMart/frontend && npm run dev
```

## Test in the browser
Open http://localhost:5173  -> click "Create an account"
Or go straight to http://localhost:5173/register

Fill the form (use a NEW phone if 01712345678 is already taken, e.g. 01812345678),
submit -> green "Registered!" message.

Then confirm the row landed:
```bash
psql -U agromart -d agromart -h localhost -c "SELECT user_id, full_name, phone FROM users;"
```

That completes slice A1 through the browser: form -> fetch -> API -> Postgres.

## Note on versions
package.json pins React 18 (not 19) and Vite 5 (not 8) — the stable versions the
build guide assumed. If you'd rather use the newest React 19 / Vite 8, the code works
on both; these are just the safer defaults for a rolling-release box.
