const express = require('express');
const cors = require('cors');
const path = require('path');
const dotenv = require('dotenv');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const mongoose = require('mongoose');

// Load env vars from backend/.env first, then root .env fallback
dotenv.config({ path: path.resolve(__dirname, '.env') });
dotenv.config();

const connectDB = require('./config/db');

// Connect to MongoDB
connectDB();

const app = express();

// Trust reverse proxy (enables HTTPS detection and accurate client IP in cloud deployments)
app.set('trust proxy', 1);

// Security Headers (Helmet)
app.use(
  helmet({
    crossOriginResourcePolicy: { policy: 'cross-origin' },
  })
);

// Rate Limiting to prevent DoS & brute-force attacks
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: process.env.NODE_ENV === 'production' ? 500 : 2000,
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: 'Too many requests from this IP, please try again after 15 minutes.' },
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 30, // 30 login/registration requests per 15 min
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: 'Too many authentication attempts, please try again after 15 minutes.' },
});

app.use('/api/', apiLimiter);
app.use('/api/auth/login', authLimiter);
app.use('/api/auth/register', authLimiter);

// Middleware
const allowedOrigins = process.env.CLIENT_ORIGINS
  ? process.env.CLIENT_ORIGINS.split(',')
  : ['*'];

app.use(
  cors({
    origin: (origin, callback) => {
      if (!origin || allowedOrigins.includes('*') || allowedOrigins.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error('Blocked by CORS policy'));
      }
    },
    credentials: true,
  })
);

app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/books', require('./routes/books'));
app.use('/api/orders', require('./routes/orders'));
app.use('/api/recommendations', require('./routes/recommendations'));

// Admin routes
const { protect, authorize } = require('./middleware/auth');
const User = require('./models/User');
const Book = require('./models/Book');
const Order = require('./models/Order');

app.get('/api/admin/stats', protect, authorize('admin'), async (req, res) => {
  try {
    const [totalBooks, totalUsers, totalOrders, revenueResult] = await Promise.all([
      Book.countDocuments(),
      User.countDocuments(),
      Order.countDocuments(),
      Order.aggregate([{ $group: { _id: null, total: { $sum: '$totalAmount' } } }]),
    ]);
    res.json({
      totalBooks,
      totalUsers,
      totalOrders,
      totalRevenue: revenueResult[0]?.total || 0,
      pendingOrders: await Order.countDocuments({ status: 'pending' }),
      deliveredOrders: await Order.countDocuments({ status: 'delivered' }),
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

app.get('/api/admin/users', protect, authorize('admin'), async (req, res) => {
  try {
    const users = await User.find().select('-password').sort({ createdAt: -1 });
    res.json(users);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Health check endpoints (for cloud load balancers & monitoring)
const healthHandler = (req, res) =>
  res.json({
    status: 'ok',
    service: 'BookNest API',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });

app.get('/health', healthHandler);
app.get('/api/health', healthHandler);

// 404 Handler
app.use((req, res) => {
  res.status(404).json({ message: `Route ${req.originalUrl} not found` });
});

// Global Error Handler
app.use((err, req, res, next) => {
  const statusCode = res.statusCode === 200 ? 500 : res.statusCode;
  res.status(statusCode).json({
    message: err.message || 'Internal Server Error',
    stack: process.env.NODE_ENV === 'production' ? undefined : err.stack,
  });
});

// Start server with automatic port-conflict fallback
const DEFAULT_PORT = parseInt(process.env.PORT, 10) || 5001;
let runningServer = null;

function startServer(port, maxAttempts = 5, currentAttempt = 0) {
  runningServer = app.listen(port, () => {
    console.log(`🚀 BookNest API running on port ${port}`);
  });

  runningServer.on('error', (err) => {
    if (err.code === 'EADDRINUSE' && currentAttempt < maxAttempts) {
      console.warn(`⚠️  Port ${port} is in use. Attempting next port ${port + 1}...`);
      startServer(port + 1, maxAttempts, currentAttempt + 1);
    } else {
      console.error('❌ Server startup error:', err.message);
    }
  });
}

function gracefulShutdown(signal) {
  console.log(`\n🛑 Received ${signal}. Closing HTTP server and database connections...`);
  if (runningServer) {
    runningServer.close(() => {
      console.log('✅ HTTP server closed.');
      mongoose.connection.close(false).then(() => {
        console.log('✅ MongoDB connection closed.');
        process.exit(0);
      });
    });
  } else {
    process.exit(0);
  }

  // Force exit after 10 seconds timeout
  setTimeout(() => {
    console.error('⚠️  Forced shutdown after timeout.');
    process.exit(1);
  }, 10000);
}

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

startServer(DEFAULT_PORT);
