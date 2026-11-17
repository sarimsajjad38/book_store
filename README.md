# 📚 BookNest - Premium Online Bookstore

<p align="center">
  <img src="assets/readme/logo.png" width="200" alt="BookNest Logo">
</p>

<p align="center">
  <b>Elevating your reading experience with a modern, full-stack digital bookstore.</b>
</p>

---

## ✨ Overview

**BookNest** is a comprehensive, production-ready bookstore application built with **Flutter** (Android, iOS, Web) and **Node.js** (Express & MongoDB). It features multi-role capabilities for customers, sellers, and platform administrators, connected via a REST API with resilient offline fallback.

<p align="center">
  <img src="assets/readme/mockup.png" width="600" alt="BookNest App Mockup">
</p>

---

## 🚀 Key Features

### 👤 User Roles
- **Customers**: Browse catalog, intelligent recommendation engine, real-time cart persistence, checkout with delivery calculation, order history, and live tracking timeline.
- **Sellers**: Dashboard analytics, full book inventory CRUD, real-time order processing, and status progression.
- **Admins**: Platform-wide metrics (revenue, total books, user roles, order stats) and user management.

### 🛠 Core Technical Capabilities
- **Dual Mode Connectivity**: Full REST API integration via `ApiService` with seamless offline/mock fallback.
- **Session Persistence**: Persistent JWT tokens and stored user profiles with role-based splash redirection.
- **Cart & Theme Persistence**: Saved cart items and theme mode (Light & Dark) across app restarts via `SharedPreferences`.
- **Search & Discovery**: Case-insensitive text and category filtering.
- **Security**: JWT authentication, bcrypt password hashing, CORS whitelist protection, and centralized error handling.
- **Containerization**: One-command local development or cloud deployment via `docker-compose`.

---

## 🛠 Tech Stack

### Frontend
- **Framework**: Flutter (Dart 3.x)
- **State Management**: Provider
- **Networking**: Http (`ApiService`)
- **Persistence**: SharedPreferences
- **UI Components**: Material 3, Google Fonts, CachedNetworkImage, Badges

### Backend
- **Runtime**: Node.js (v18+)
- **Framework**: Express.js
- **Database**: MongoDB (Local or MongoDB Atlas) via Mongoose
- **Security**: JWT, BcryptJS, Express Validator, CORS

---

## 📂 Project Structure

```text
book_store/
├── lib/                         # Flutter Frontend
│   ├── models/                  # AppUser, Book, Order, CartItem
│   ├── providers/               # Auth, Book, Cart, Order, Theme Providers
│   ├── screens/
│   │   ├── admin/               # Admin panel & stats
│   │   ├── auth/                # Splash, Login, Signup
│   │   ├── customer/            # Home, Search, BookDetail, Cart, Checkout, Tracking
│   │   └── seller/              # Dashboard, Inventory, Add/Edit Book, Orders
│   ├── services/
│   │   ├── api_service.dart     # REST API Client (Auth, Books, Orders, Admin)
│   │   └── mock_data_service.dart # In-memory fallback dataset
│   ├── utils/                   # AppTheme, ApiConstants
│   ├── widgets/                 # BookCard, GradientButton, Timeline
│   └── main.dart                # App entry point
├── backend/                     # Node.js Backend API
│   ├── config/                  # MongoDB connection (db.js)
│   ├── middleware/              # JWT protect & role authorize
│   ├── models/                  # User, Book, Order schemas
│   ├── routes/                  # /auth, /books, /orders, /recommendations
│   ├── seed.js                  # Database bootstrap script
│   ├── Dockerfile               # Production container file
│   └── server.js                # API server & error handling
├── android/                     # Android build config & key.properties template
├── ios/                         # iOS Runner & Info.plist permissions
├── web/                         # Web build & manifest.json
└── docker-compose.yml           # Multi-container local/cloud deployment
```

---

## ⚙️ Quick Start

### 1. Run with Docker (Fastest)

```bash
docker-compose up -d
```
Starts MongoDB on `localhost:27017` and the BookNest API on `localhost:5000`.

### 2. Backend Manual Setup

```bash
cd backend
npm install

# Copy environment template
cp .env.example .env

# Seed initial admin, sellers, customers, and books
npm run seed

# Start development server
npm run dev
```

### 3. Frontend Setup

```bash
# In the root directory
flutter pub get
flutter run
```

---

## 🔑 Default Seed Accounts

All accounts use the password: `password123`

| Role | Email | Capabilities |
| :--- | :--- | :--- |
| **Admin** | `admin@booknest.com` | View revenue, platform stats, manage users & orders |
| **Seller** | `seller@booknest.com` | Manage inventory, add books, fulfill orders |
| **Customer** | `customer@booknest.com` | Browse, order books, track delivery |

---

## 🚢 Deployment & Production Build

### Backend Deployment (Render / Railway / AWS / GCP)
1. Provision a MongoDB database on [MongoDB Atlas](https://www.mongodb.com/atlas).
2. Set environment variables on your cloud provider:
   - `NODE_ENV=production`
   - `PORT=5000`
   - `MONGODB_URI=mongodb+srv://<user>:<password>@cluster.mongodb.net/booknest`
   - `JWT_SECRET=<secure-random-key>`
   - `CLIENT_ORIGINS=https://your-domain.web.app`
3. Deploy via the provided [Dockerfile](backend/Dockerfile) or container registry.

### Android Release Build (Google Play)
1. Copy `android/key.properties.example` to `android/key.properties` and add your keystore credentials.
2. Build the app bundle:
   ```bash
   flutter build appbundle --release
   ```
   Output: `build/app/outputs/bundle/release/app-release.aab`

### Web Release Build (Firebase / Netlify / Vercel)
```bash
flutter build web --release
```
Output: `build/web/`

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
