# AgroFin Cron Setup

## What this directory does

Background tasks run on a schedule via a single entry point: `cron/run.php`.
Each scheduled task is a class in `cron/tasks/` that extends `CronTask` and
implements a `run()` method.

## Currently registered tasks

| Task | Schedule | What it does |
|------|----------|--------------|
| `CropExpiryTask` | daily | Marks crops past `available_until` as `expired` and notifies farmers |
| `LoanReminderTask` | daily | Sends 3-day-advance, due-today, and overdue (1/7/14/30-day) loan reminders. Auto-marks 30+ days overdue as `defaulted`. |
| `WeatherAlertExpiryTask` | hourly | Deactivates weather alerts past their `end_time` |

## Installation

### Linux / macOS

Add to root or web-user crontab (`crontab -e`):

```cron
# AgroFin background tasks — runs every 5 minutes; each task self-throttles
*/5 * * * * /usr/bin/php /var/www/html/AgroFin/cron/run.php >> /var/log/agrofin-cron.log 2>&1
```

The 5-minute system trigger is the heartbeat — each task internally decides
whether it's due (daily tasks run once per day, hourly once per hour, etc.).

### Windows (XAMPP)

Use Task Scheduler with the action:
```
"C:\xampp\php\php.exe" "C:\xampp\htdocs\AgroFin\cron\run.php"
```
Trigger: repeat every 5 minutes indefinitely.

### Shared hosting (cPanel)

Most cPanel hosts let you add cron jobs in the control panel. Use the
same command as Linux above (adjust the path).

If you can't run cron at all (some cheap shared plans), use the HTTP fallback:
set `CRON_TOKEN` to a random string in `.env`, then hit
`https://yourdomain.com/AgroFin/cron/run.php?cron_token=YOUR_TOKEN`
from a free uptime-monitor service like UptimeRobot every 5 minutes.

## Manual operation

```bash
# Run all due tasks once
php cron/run.php

# List all registered tasks + last run time
php cron/run.php --list

# Force-run a specific task (ignores schedule)
php cron/run.php --task=crop_expiry
```

## Logging

All output goes to `storage/logs/cron-YYYY-MM-DD.log`. When run from CLI,
output also streams to stdout so `tail -f` works during development.

## Adding a new task

1. Create `cron/tasks/MyNewTask.php`
2. Extend `CronTask`, set `$name` and `$schedule`, implement `run()`
3. Return `['ok' => bool, 'message' => string, 'affected' => int]`
4. That's it — `run.php` auto-discovers task files in this directory

Example:

```php
<?php
class MyNewTask extends CronTask {
    public $name = 'my_task';
    public $schedule = 'hourly';

    public function run() {
        // do work
        return ['ok' => true, 'message' => 'Did the thing', 'affected' => 5];
    }
}
```

## Important: idempotency

Tasks should be safe to run twice. Use these patterns:
- Update queries with date filters (`WHERE updated_at < ...`) instead of "all"
- Insert-or-skip patterns for notifications (check for an existing recent row first)
- Check status before transitioning (`WHERE status='available'` before setting to `expired`)
