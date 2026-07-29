# AgroFin Upgrade Guide — Steps 1-4

This document describes the changes from the original Chunk-4 build and how to apply them to an existing AgroFin install.

## What's new in this update

| # | Change | Files added/modified |
|---|--------|----------------------|
| 1 | **Performance indexes** — ~25 new indexes across hot tables | `migrations/001_performance_indexes.sql` |
| 2 | **Environment variables** — secrets moved out of PHP files | `.env`, `.env.example`, `.gitignore`, `core/Env.php`, `config/database.php`, `index.php` |
| 3 | **CHECK constraints** — DB-level value validation | `migrations/002_check_constraints.sql` |
| 4 | **last_seen_at tracking** — admin can see active vs dormant users | `migrations/003_last_seen_at.sql`, `core/Controller.php`, `views/admin/users/detail.php` |

## How to apply

### 1. Run the migrations (in order)

From your MySQL client (or phpMyAdmin → Import):

```bash
mysql -u root agrofin < migrations/001_performance_indexes.sql
mysql -u root agrofin < migrations/002_check_constraints.sql
mysql -u root agrofin < migrations/003_last_seen_at.sql
```

Each migration prints a success message at the end. Re-running 001 will error on duplicate indexes — that's expected; means it's already applied.

> If you're on MySQL 5.7 (not 8.0+), the CHECK constraints in migration 002 are parsed but **not enforced**. Upgrade to MySQL 8 or MariaDB 10.2+ to get full benefit. The application layer still validates everything.

### 2. Configure .env

```bash
cp .env.example .env
nano .env  # edit DB credentials, set APP_KEY, etc.
```

The `.env` file is gitignored. Your previous `config/database.php` settings now come from `.env` instead. If you don't create a `.env`, the defaults still work for a typical XAMPP install (root user, no password, `agrofin` database).

### 3. Verify

Visit the app in your browser. Log in. Check:
- The login flow works (env is loading correctly)
- A page loads (indexes don't break anything)
- Try creating a crop with `quantity = -5` → should be rejected at DB level on MySQL 8+
- As admin, visit `/admin/users/detail/1` after a user logs in → see "এখন অনলাইন" badge if within 10 minutes

## What was NOT broken by these changes

- Existing data is untouched. No DROPs, no schema rewrites — only additive changes (CREATE INDEX, ADD CONSTRAINT, ADD COLUMN).
- The app falls back to defaults if `.env` is missing — so an upgrade without copying `.env` still works.
- The `last_seen_at` tracking is wrapped in try/catch — if migration 003 hasn't been run yet, the app just silently skips it.

## What's coming in Steps 5-8

- **Step 5**: ✅ Cron scheduler infrastructure (`cron/run.php` + `CronTask` base class) — **NOW INSTALLED**
- **Step 6**: ✅ Crop expiry auto-job — **NOW INSTALLED** (`cron/tasks/CropExpiryTask.php`)
- **Step 7**: ✅ Loan payment reminders — **NOW INSTALLED** (`cron/tasks/LoanReminderTask.php`) — sends 3-day-advance, due-today, and escalating overdue reminders; auto-defaults loans 30+ days late
- **Step 8**: Subscription recurring orders — pending

Bonus task added: `WeatherAlertExpiryTask` (hourly) — auto-deactivates expired weather alerts.

### Cron installation

See `cron/README.md` for full setup instructions. TL;DR:

```cron
# Add to crontab: heartbeat every 5 minutes; tasks self-throttle
*/5 * * * * /usr/bin/php /var/www/html/AgroFin/cron/run.php >> /var/log/agrofin-cron.log 2>&1
```

Manual operation:
```bash
php cron/run.php --list           # show registered tasks + last run
php cron/run.php                  # run all due tasks once
php cron/run.php --task=crop_expiry  # force-run a single task
```

### CLI-safe Database class

`config/database.php` was updated to throw a clean `RuntimeException` when called from CLI (instead of dumping HTML), so cron failures are logged properly instead of breaking the dispatcher.
