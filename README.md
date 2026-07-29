# 🌾 AgroFin

**Smart Farmer Marketplace & Financial Intelligence System**

A unified agricultural platform built for Bangladeshi farmers — combining a direct marketplace, microloans, real-time market prices, weather intelligence, and an AI assistant — all in Bangla.

Built by **Team FirstFail** 

---

## ✨ Features

## 📸 Screenshots

### Home Page
![Home Page](screenshots/home.png)

### Marketplace
![Dashboard](screenshots/market_place.png)

---
### For Farmers
- List crops with photos, set prices, manage inventory
- Smart wallet with trigger-based double-entry accounting
- Apply for microloans with automatic eligibility scoring
- Live market price comparison (your crop vs. external market)
- District-specific 5-day weather forecasts and severe-weather alerts
- Expense tracking with auto-computed profit/loss
- Direct messaging with buyers

### For Buyers
- Browse crops by category, district, or price
- Save favorites and recurring subscriptions
- Order with mock or live payment gateway
- Rate farmers after delivery
- Track orders in real-time

### For Agents
- Register farmers in the field (with OTP verification)
- Manage assigned farmers, log activities
- Commission tracking on every farmer sale
- File support tickets on behalf of farmers

### For Admins
- Real-time platform-wide dashboard
- Loan application approval workflow
- Market price management with full price history
- Issue manual weather alerts per district
- Full audit log of every admin action

### Cross-cutting
- **AI Assistant** — Bangla chatbot for weather, prices, orders, loans
- **Bangla-first UI** — Native Bangla throughout, with 64 Bangladesh districts preloaded
  
---

## Tech Stack

- **Backend:** PHP 8 (custom MVC framework, no external dependencies)
- **Database:** MariaDB / MySQL 8
- **Frontend:** Vanilla JS, custom CSS, Bootstrap Icons
- **External APIs:** OpenWeatherMap (weather), SSLCommerz (payment, optional)
- **Cron-driven:** Automated background tasks for weather, market prices, analytics

---

## Database Highlights

| Metric | Count |
|---|---|
| Tables | **39** (normalized to BCNF) |
| Foreign Keys | **71** |
| Triggers | **3** (order numbering, inventory logs, wallet double-entry) |
| Views | **2** (`vw_active_crops_with_details`, `vw_farmer_performance`) |
| Composite Indexes | **20+** |

Database documentation available in the `docs/` folder.

---

## 📂 Project Structure

```
AgroFin/
├── Controllers/     # 13 MVC controllers (Auth, Farmer, Buyer, Agent, Admin, etc.)
├── Models/          # 24 data models
├── views/           # 71 view files organized by role
│   ├── admin/       # Admin panel views
│   ├── agent/       # Agent dashboard views
│   ├── farmer/      # Farmer dashboard views
│   ├── buyer/       # Buyer dashboard views
│   ├── liveprice/   # Live market price page
│   ├── marketplace/ # Public marketplace
│   └── ...
├── core/            # 18 framework files
│   ├── Router.php           # URL routing
│   ├── Controller.php       # Base controller
│   ├── Model.php            # Base model
│   ├── Csrf.php             # CSRF protection
│   ├── SessionGuard.php     # Session security
│   ├── WeatherProvider.php  # Weather API integration
│   ├── PaymentProvider.php  # Payment gateway abstraction
│   ├── SmsProvider.php      # SMS abstraction
│   ├── LlmProvider.php      # AI integration
│   └── ...
├── cron/            # Background tasks
│   └── tasks/       # 10 cron tasks
│       ├── WeatherFetchTask.php
│       ├── MarketPriceFetchTask.php
│       ├── DemandAnalyticsTask.php
│       ├── LoanReminderTask.php
│       ├── SubscriptionSchedulerTask.php
│       ├── CropExpiryTask.php
│       ├── WeatherAlertExpiryTask.php
│       ├── OtpCleanupTask.php
│       ├── CacheCleanupTask.php
│       └── LogRotateTask.php
├── migrations/      # 6 SQL migrations
├── includes/        # Shared header, navbar, sidebar, footer
├── assets/          # CSS, JS, fonts
├── config/          # Routes and configuration
├── tests/           # Unit + integration tests
├── docs/            # Project documentation
├── uploads/         # User-uploaded files (crops/profiles/receipts)
├── storage/         # Cache and logs
├── database.sql     # Complete schema + seed data
└── index.php        # Front controller
```

---

## 🚀 Local Setup

### Prerequisites
- **XAMPP** (PHP 8+ and MariaDB / MySQL 8)
- A modern web browser

### Steps

**1. Clone the repository**
```bash
git clone https://github.com/redwan212/AgroFin.git
```

**2. Move to XAMPP htdocs**
Copy the `AgroFin` folder to `C:\xampp\htdocs\`.

**3. Start XAMPP**
Start **Apache** and **MySQL** from the XAMPP Control Panel.

**4. Create the database**
- Open phpMyAdmin: `http://localhost/phpmyadmin`
- Click "New" → name the database `agrofin` → Create
- Select the `agrofin` database → Import tab → choose `database.sql` → Go

**5. Configure environment**
```bash
copy .env.example .env
```
Open `.env` and fill in:
- `WEATHER_API_KEY` — get a free key from https://openweathermap.org/api
- (Optional) `SSLCOMMERZ_STORE_ID` and `SSLCOMMERZ_STORE_PASSWORD` for real payments (leave blank to use mock gateway)
- `APP_KEY` — any random 32-character string

**6. Open the app**
Visit `http://localhost/AgroFin` in your browser.

---

## 🔑 Demo Accounts

All accounts use the password: **`password123`**

| Role | Phone | Name | Location |
|------|-------|------|----------|
| Farmer | `01712345001` | করিম মিয়া | Mymensingh |
| Farmer | `01812345002` | ফাতেমা বেগম | Comilla |
| Farmer | `01912345003` | হালিম মিয়া | Rangpur |
| Buyer | `01612345004` | হাসান চৌধুরী | Dhaka |
| Buyer | `01512345005` | FreshMart | Dhaka |
| Agent | `01312345006` | রফিক হোসেন | — |
| Agent | `01412345007` | সালমা আক্তার | — |
| Admin | `01212345008` | সুলতানা | — |

You can sign in with **phone number** or **email**.

---

## ⚙️ Background Tasks

To enable scheduled background tasks (weather fetching, price updates, loan reminders, etc.), configure cron in your environment.

On Linux/Mac:
```bash
*/15 * * * * php /path/to/AgroFin/cron/run.php
```

On Windows (Task Scheduler): create a task that runs every 15 minutes invoking:
```cmd
C:\xampp\php\php.exe C:\xampp\htdocs\AgroFin\cron\run.php
```

To run a specific task manually:
```bash
php cron/run.php --task=weather_fetch
php cron/run.php --task=market_price_fetch
```

See `cron/README.md` for details.

---

## 🧪 Testing

```bash
php tests/run.php
```

Tests cover both unit (individual class behavior) and integration (full request/response flows).

---

## 📄 Documentation

The `docs/` folder contains:
- **`AgroFin_Relational_Schema.md`** — All 39 tables documented in detail
- **`AgroFin_Normalization_Analysis.md`** — 1NF → BCNF analysis with examples
- **`AgroFin_SQL_Query_Demonstration.md`** — Advanced SQL features used (triggers, views, FOR UPDATE, UPSERT, etc.)

---

## 🛡️ Security Features

- **Password hashing:** bcrypt with cost factor 12
- **CSRF protection:** All state-changing forms protected
- **Session security:** HttpOnly, SameSite, configurable Secure flag
- **Rate limiting:** Login, OTP, registration endpoints rate-limited
- **OTP verification:** Phone verification at registration
- **Audit logging:** Every admin action recorded with before/after state
- **Input sanitization:** Server-side validation on every form
- **SQL injection prevention:** PDO prepared statements throughout

---

## 🌐 External Integrations

| Service | Purpose | Required |
|---------|---------|----------|
| OpenWeatherMap | 5-day forecasts + severe weather alerts | Yes (free tier OK) |
| SSLCommerz | Live payment gateway | Optional (mock available) |
| SMS Gateway | OTP delivery | Optional (logs to file by default) |

---

## 👥 Team FirstFail
DBMS Lab Project 

## 📝 License

For academic and educational use.
