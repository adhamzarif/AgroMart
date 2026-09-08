# 🌾 AgroMart

**Smart Farmer Marketplace & Financial Intelligence System**

AgroMart is an agricultural platform designed for Bangladeshi farmers, buyers, and other marketplace participants. The project combines a web frontend, REST-style backend APIs, agricultural crop and market-price features, financial/database components, and Bangla-first interface support.

Built by **Team UIU_Return0**  
**SWE Lab Project**

---

## ✨ Features

### 👨‍🌾 For Farmers

- Register and manage farmer information
- Add and manage crop listings
- Upload crop images
- View marketplace crop information
- Access market-price information
- Use a Bangla-first interface

### 🛒 Marketplace

- Browse available crops
- View crop information and prices
- Organize crops through categories
- Support crop-related API operations

### 📈 Market Prices

- Market-price API integration
- Price data management
- Price-history database support
- Dedicated Live Price frontend page

### 🌐 Bangla / Internationalization

- Dedicated internationalization files
- Language context through `LangContext.jsx`
- Shared translation strings
- Frontend installation script for i18n setup

### 🔐 Authentication & Security

- Authentication API and routes
- Authentication middleware
- CSRF middleware
- Rate limiting
- Request validation
- Centralized error handling
- File-upload middleware

---

## 🏗️ Architecture

AgroMart is organized as a **separate frontend + backend application**:

```text
                    ┌──────────────────────────┐
                    │       React Frontend     │
                    │   Vite + Tailwind CSS    │
                    └────────────┬─────────────┘
                                 │
                           API Requests
                                 │
                                 ▼
                    ┌──────────────────────────┐
                    │     Node.js Backend      │
                    │         Express          │
                    └────────────┬─────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
                    ▼                         ▼
             Application APIs          Database Layer
             Controllers/Routes        SQL Migrations
             Models/Services           Seed Data
```

The repository contains dedicated `backend/`, `frontend/`, `migrations/`, `docs/`, and seed-data components. The supplied project tree contains **1,816 directories and 11,487 files**; dependency directories such as `node_modules` account for a large portion of that tree.

---

## 🛠️ Tech Stack

### Backend

- **Node.js**
- **Express**
- JavaScript
- REST-style API structure
- Middleware-based request processing
- Authentication, CSRF, rate limiting, validation, and upload handling

The backend is organized around controllers, routes, models, middleware, services, utilities, configuration, jobs, storage, and tests.

### Frontend

- **React**
- **Vite**
- **Tailwind CSS**
- JavaScript / JSX
- React Router
- Custom UI components
- API client modules

The frontend contains API modules, reusable layout/UI components, language context, i18n strings, pages, assets, and Vite/Tailwind configuration.

### Database

- SQL-based relational database
- Versioned SQL migrations
- Reference/marketplace/transaction/payment/financial/agent/smart database modules
- Database views
- Seed data

The migration directory currently contains migrations from `000_prelude.sql` through `009_views.sql`, together with database application, verification, and seed scripts.

---

## 📂 Project Structure

> `node_modules/` contents are intentionally not expanded below because they contain third-party dependencies. The actual project tree includes both backend and frontend dependency directories.

```text
AgroMart/
│
├── backend/
│   ├── install_crops_api.sh
│   ├── package.json
│   ├── package-lock.json
│   │
│   ├── src/
│   │   ├── config/
│   │   │   ├── db.js
│   │   │   └── env.js
│   │   │
│   │   ├── controllers/
│   │   │   ├── auth.controller.js
│   │   │   ├── crops.controller.js
│   │   │   └── prices.controller.js
│   │   │
│   │   ├── index.js
│   │   │
│   │   ├── jobs/
│   │   │
│   │   ├── middleware/
│   │   │   ├── auth.js
│   │   │   ├── csrf.js
│   │   │   ├── errorHandler.js
│   │   │   ├── rateLimit.js
│   │   │   └── upload.js
│   │   │
│   │   ├── models/
│   │   │   ├── crop.model.js
│   │   │   ├── price.model.js
│   │   │   └── user.model.js
│   │   │
│   │   ├── routes/
│   │   │   ├── auth.routes.js
│   │   │   ├── categories.routes.js
│   │   │   ├── crops.routes.js
│   │   │   ├── prices.routes.js
│   │   │   └── stats.routes.js
│   │   │
│   │   ├── services/
│   │   └── utils/
│   │       └── validate.js
│   │
│   ├── storage/
│   │   └── uploads/
│   │       └── crops/
│   │
│   ├── tests/
│   └── node_modules/
│
├── docs/
│   ├── AgroMart_Normalization_Analysis.md
│   ├── AgroMart_Relational_Schema.md
│   ├── AgroMart_SQL_Query_Demonstration.md
│   ├── api.md
│   ├── mysql_schema_reference.sql
│   ├── normalization.md
│   └── schema.md
│
├── frontend/
│   ├── index.html
│   ├── install_i18n.sh
│   ├── package.json
│   ├── package-lock.json
│   ├── postcss.config.js
│   ├── SETUP_FRONTEND.md
│   │
│   ├── public/
│   │   └── crops/
│   │       ├── alu.jpg
│   │       ├── begun.jpg
│   │       ├── kachamorich.jpg
│   │       ├── lau.jpg
│   │       ├── mosurdal.jpg
│   │       ├── mugdal.jpg
│   │       ├── peyaj.jpg
│   │       ├── shorisha.jpg
│   │       └── tomato.jpg
│   │
│   ├── src/
│   │   ├── api/
│   │   │   ├── auth.api.js
│   │   │   ├── client.js
│   │   │   ├── crops.api.js
│   │   │   ├── prices.api.js
│   │   │   └── stats.api.js
│   │   │
│   │   ├── App.jsx
│   │   ├── assets/
│   │   │   └── logo.svg
│   │   │
│   │   ├── components/
│   │   │   ├── layout/
│   │   │   │   ├── Footer.jsx
│   │   │   │   ├── Layout.jsx
│   │   │   │   └── Navbar.jsx
│   │   │   ├── sections/
│   │   │   │   └── FeaturedCrops.jsx
│   │   │   └── ui/
│   │   │       ├── Badge.jsx
│   │   │       ├── Button.jsx
│   │   │       ├── Card.jsx
│   │   │       ├── ProductCard.jsx
│   │   │       └── StatCard.jsx
│   │   │
│   │   ├── context/
│   │   │   └── LangContext.jsx
│   │   │
│   │   ├── hooks/
│   │   │
│   │   ├── i18n/
│   │   │   ├── strings_final.js
│   │   │   └── strings.js
│   │   │
│   │   ├── index.css
│   │   ├── main.jsx
│   │   │
│   │   └── pages/
│   │       ├── auth/
│   │       │   └── Register.jsx
│   │       ├── farmer/
│   │       │   └── CropForm.jsx
│   │       ├── Home.jsx
│   │       ├── HowItWorks.jsx
│   │       ├── LivePrice.jsx
│   │       └── Marketplace.jsx
│   │
│   ├── tailwind.config.js
│   ├── vite.config.js
│   └── node_modules/
│
├── migrations/
│   ├── 000_prelude.sql
│   ├── 001_init.sql
│   ├── 002_reference.sql
│   ├── 003_marketplace.sql
│   ├── 004_transactions.sql
│   ├── 005_payments.sql
│   ├── 006_financial.sql
│   ├── 007_agent.sql
│   ├── 008_smart.sql
│   ├── 009_views.sql
│   ├── apply_all.sh
│   ├── seed.sql
│   └── verify_db.sh
│
├── seed/
│   ├── download_demo_images.sh
│   ├── refresh_demo.sh
│   └── seed_price_history.sql
│
├── seed_crops.sql
├── project-structure.txt
└── README.md
```

The backend/frontend split and the database/documentation directories are directly reflected in the supplied project tree.

---

## 📁 Backend Structure

### `backend/src/config/`

Application configuration and database/environment setup.

### `backend/src/controllers/`

Handles application-level request processing:

- `auth.controller.js`
- `crops.controller.js`
- `prices.controller.js`

### `backend/src/routes/`

Defines the backend API route groups:

- Authentication
- Categories
- Crops
- Prices
- Statistics

### `backend/src/models/`

Database-facing application models:

- Users
- Crops
- Prices

### `backend/src/middleware/`

Cross-cutting request processing and security:

- Authentication
- CSRF protection
- Error handling
- Rate limiting
- File uploads

### `backend/src/services/`

Service-layer functionality.

### `backend/src/jobs/`

Background/job-related backend functionality.

### `backend/storage/uploads/`

Uploaded crop files.

The backend tree explicitly contains these configuration, controller, middleware, model, route, service, utility, storage, and test areas.

---

## 🎨 Frontend Structure

The frontend is a React application built with Vite and Tailwind CSS.

### `frontend/src/api/`

Centralized API modules:

- `auth.api.js`
- `crops.api.js`
- `prices.api.js`
- `stats.api.js`
- `client.js`

### `frontend/src/components/`

Reusable UI components.

#### Layout

- `Navbar.jsx`
- `Layout.jsx`
- `Footer.jsx`

#### Sections

- `FeaturedCrops.jsx`

#### UI

- `Badge.jsx`
- `Button.jsx`
- `Card.jsx`
- `ProductCard.jsx`
- `StatCard.jsx`

### `frontend/src/pages/`

Application pages:

- Home
- Marketplace
- Live Price
- How It Works
- Registration
- Farmer Crop Form

### `frontend/src/context/`

Global React context, including language management.

### `frontend/src/i18n/`

Translation/string resources.

## The tree confirms the API, reusable components, language context, i18n files, and application pages listed above.

## 🗄️ Database & Migrations

Database changes are maintained as ordered SQL migrations:

| Migration              | Purpose                          |
| ---------------------- | -------------------------------- |
| `000_prelude.sql`      | Initial database preparation     |
| `001_init.sql`         | Initial schema                   |
| `002_reference.sql`    | Reference data                   |
| `003_marketplace.sql`  | Marketplace functionality        |
| `004_transactions.sql` | Transaction functionality        |
| `005_payments.sql`     | Payment functionality            |
| `006_financial.sql`    | Financial functionality          |
| `007_agent.sql`        | Agent functionality              |
| `008_smart.sql`        | Smart/intelligence functionality |
| `009_views.sql`        | Database views                   |

Supporting scripts:

- `apply_all.sh` — apply migrations
- `verify_db.sh` — verify database state
- `seed.sql` — database seed data

Additional seed resources are available under `seed/`, including price-history data and demo-image scripts.

---

## 📚 Documentation

The `docs/` directory contains:

- **`AgroMart_Relational_Schema.md`** — relational schema documentation
- **`AgroMart_Normalization_Analysis.md`** — database normalization analysis
- **`AgroMart_SQL_Query_Demonstration.md`** — SQL demonstrations
- **`api.md`** — API documentation
- **`mysql_schema_reference.sql`** — SQL schema reference
- **`normalization.md`** — normalization documentation
- **`schema.md`** — schema documentation

These documentation files are present in the project tree.

---

## 🚀 Getting Started

### Prerequisites

Install:

- Node.js
- npm
- A supported SQL database
- Git

---

### 1. Clone the Repository

```bash
git clone https://github.com/adhamzarif/AgroMart.git
cd AgroMart
```

---

### 2. Install Backend Dependencies

```bash
cd backend
npm install
```

The backend has its own `package.json` and `package-lock.json`. fileciteturn4file0L67-L69

---

### 3. Configure the Backend

Review the backend environment/configuration files:

```text
backend/src/config/
├── db.js
└── env.js
```

Configure the database connection and required environment values for your local environment.

---

### 4. Prepare the Database

From the project root:

```bash
cd migrations
```

Review the migration scripts and use the provided migration/verification scripts:

```bash
./apply_all.sh
./verify_db.sh
```

On Windows, run the equivalent SQL files using your preferred MySQL-compatible database tool if shell scripts are not available.

---

### 5. Install Frontend Dependencies

```bash
cd ../frontend
npm install
```

The frontend includes Vite, Tailwind configuration, React source files, and its own dependency manifest. fileciteturn4file0L110-L112 fileciteturn4file0L67-L69

---

### 6. Start the Applications

Use the scripts defined in each application's `package.json`.

Backend:

```bash
cd backend
npm run <backend-script>
```

Frontend:

```bash
cd frontend
npm run <frontend-script>
```

For frontend-specific setup information, see:

```text
frontend/SETUP_FRONTEND.md
```

---

## 🔌 API Overview

The backend currently separates API functionality into route groups for:

```text
/auth
/categories
/crops
/prices
/stats
```

The corresponding frontend API modules are:

```text
frontend/src/api/
├── auth.api.js
├── crops.api.js
├── prices.api.js
└── stats.api.js
```

This separation keeps API communication independent from React page and component code. fileciteturn4file0L89-L97 fileciteturn5file2L59-L60

---

## 🧪 Testing

The repository contains a dedicated backend test directory:

```text
backend/
└── tests/
```

Run the test command defined in `backend/package.json`.

---

## 🖼️ Crop Images

Demo crop images are included in:

```text
frontend/public/crops/
```

Current image assets include:

```text
alu.jpg
begun.jpg
kachamorich.jpg
lau.jpg
mosurdal.jpg
mugdal.jpg
peyaj.jpg
shorisha.jpg
tomato.jpg
```

The backend also provides storage for uploaded crop images under:

```text
backend/storage/uploads/crops/
```

The project tree confirms both the frontend demo-image directory and backend crop-upload storage. fileciteturn4file0L98-L101 fileciteturn5file4L139-L147

---

## 🌱 Project Scripts

Useful project-level scripts include:

```text
backend/install_crops_api.sh
frontend/install_i18n.sh
migrations/apply_all.sh
migrations/verify_db.sh
seed/download_demo_images.sh
seed/refresh_demo.sh
```

These scripts support API installation, frontend i18n setup, database migration/verification, and demo-data preparation.

---

## 👥 Team UIU_Return0

**SWE Lab Project**

---

## 📝 License

For academic and educational use.
