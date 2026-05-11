# 📚 BookNest - Premium Online Bookstore

<p align="center">
  <img src="assets/readme/logo.png" width="200" alt="BookNest Logo">
</p>

<p align="center">
  <b>Elevating your reading experience with a modern, full-stack digital bookstore.</b>
</p>

---

## ✨ Overview

**BookNest** is a comprehensive, multi-platform bookstore application built with **Flutter** and **Node.js**. It provides a seamless shopping experience for customers, a robust management tool for sellers, and a powerful dashboard for administrators.

<p align="center">
  <img src="assets/readme/mockup.png" width="600" alt="BookNest App Mockup">
</p>

---

## 🚀 Key Features

### 👤 User Roles
- **Customers**: Browse books, manage cart, place orders, and view recommendations.
- **Sellers**: Manage book inventory, track sales, and process orders.
- **Admins**: Comprehensive dashboard with platform-wide statistics and user management.

### 🛠 Core Functionality
- **Authentication**: Secure login and signup with JWT and password hashing.
- **Book Discovery**: Advanced search and categorization.
- **Shopping Cart**: Real-time cart management.
- **Order Tracking**: Detailed order history and status updates.
- **Admin Analytics**: Real-time stats for revenue, users, and books.
- **Themes**: Elegant Light and Dark modes.

---

## 🛠 Tech Stack

### Frontend
- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Networking**: Http
- **UI Components**: Material 3, Google Fonts, Badges

### Backend
- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MongoDB (via Mongoose)
- **Security**: JWT, BcryptJS, Express Validator

---

## 📂 Project Structure

```text
book_store/
├── lib/                  # Flutter Frontend
│   ├── models/           # Data structures
│   ├── providers/        # State management logic
│   ├── screens/          # UI Screens (Auth, Admin, Customer, Seller)
│   ├── utils/            # Themes and constants
│   └── main.dart         # App entry point
├── backend/              # Node.js Backend
│   ├── config/           # DB configuration
│   ├── middleware/       # Auth and validation
│   ├── models/           # MongoDB schemas
│   ├── routes/           # API endpoints
│   └── server.js         # Backend entry point
└── assets/               # Images and static files
```

---

## ⚙️ Installation & Setup

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Node.js](https://nodejs.org/)
- [MongoDB](https://www.mongodb.com/) (Local or Atlas)

### 1. Backend Setup
```bash
cd backend
npm install
# Create a .env file based on .env.example
npm run dev
```

### 2. Frontend Setup
```bash
flutter pub get
flutter run
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/sarimsajjad38">Sarim Sajjad</a>
</p>
