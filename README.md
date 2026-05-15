# FitGo

AI-powered fitness meal planning application. Generate personalized meal plans based on your body metrics and dietary preferences.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Node.js + Express |
| Database | MySQL |
| Frontend | Flutter (Android / iOS / Web / Windows) |
| APIs | Spoonacular (meal planning), Resend (email) |

## Features

- User registration with email OTP verification
- JWT-based authentication with password reset
- Personalized calorie calculation (TDEE) from height, weight, age, gender, activity level
- AI-generated weekly meal plans via Spoonacular API
- Dietary preference support: standard, vegetarian, keto, vegan
- Save and view favorite meal plans
- Ingredient exclusion for allergies/dislikes

## Project Structure

```
FitGo/
├── backend/                  # Node.js API server
│   ├── controllers/          # Auth, meal, user logic
│   ├── middleware/            # JWT auth middleware
│   ├── routes/               # Express route definitions
│   ├── services/             # Spoonacular, email, user services
│   ├── utils/                # Calorie calculator, email sender
│   ├── migrations/           # Database migrations
│   └── server.js             # Entry point (port 3000)
├── flutter/                  # Flutter mobile/web/desktop app
│   └── lib/
│       ├── models/           # Data models with JSON serialization
│       ├── providers/        # Auth & data state management
│       ├── screens/          # UI pages (onboarding, home, etc.)
│       ├── services/         # API client, local storage
│       └── router/           # App route definitions
├── schema.sql                # Database schema reference
└── start-app.sh              # One-command startup script
```

## Getting Started

### Prerequisites

- **Node.js** 18+
- **MySQL** 8.0+
- **Flutter SDK** 3.0+

### 1. Database Setup

```bash
mysql -u root -p < schema.sql
```

### 2. Backend Setup

```bash
cd backend
cp .env.example .env
```

Edit `.env` with your actual values:

```env
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=your_mysql_password
MYSQL_DATABASE=fitgo

JWT_SECRET=your_jwt_secret
JWT_EXPIRY=7d

SPOONACULAR_API_KEY=your_spoonacular_api_key
SPOONACULAR_BASE_URL=https://api.spoonacular.com/mealplanner/generate

RESEND_API_KEY=your_resend_api_key
RESEND_FROM_EMAIL=no-reply@yourdomain.com
```

```bash
npm install
npm run dev
```

The API server starts at `http://localhost:3000`.

### 3. Flutter App

```bash
cd flutter
flutter pub get
flutter run
```

### One-Command Start

```bash
bash start-app.sh    # macOS/Linux
.\start-app.ps1      # Windows PowerShell
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/auth/register` | Register with email OTP |
| POST | `/api/auth/verify-otp` | Verify registration OTP |
| POST | `/api/auth/login` | Login with email & password |
| POST | `/api/auth/forgot-password` | Request password reset |
| POST | `/api/auth/reset-password` | Reset password with OTP |
| GET | `/api/meal/generate` | Generate meal plan (auth required) |
| POST | `/api/meal/save` | Save a meal plan (auth required) |
| GET | `/api/meal/saved` | Get saved meal plans (auth required) |
| GET | `/api/user/profile` | Get user profile (auth required) |
| PUT | `/api/user/profile` | Update user profile (auth required) |

## Environment Variables

| Variable | Description |
|----------|-------------|
| `MYSQL_HOST` | MySQL host |
| `MYSQL_PORT` | MySQL port |
| `MYSQL_USER` | MySQL user |
| `MYSQL_PASSWORD` | MySQL password |
| `MYSQL_DATABASE` | Database name |
| `JWT_SECRET` | JWT signing secret |
| `JWT_EXPIRY` | Token expiration duration |
| `SPOONACULAR_API_KEY` | [Spoonacular API](https://spoonacular.com/food-api) key |
| `RESEND_API_KEY` | [Resend](https://resend.com) API key for email |
| `RESEND_FROM_EMAIL` | Sender email address |
| `PORT` | Server port (default: 3000) |
