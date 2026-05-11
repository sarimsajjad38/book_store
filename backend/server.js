const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const connectDB = require('./config/db');

// Load env vars
dotenv.config();

// Connect to MongoDB
connectDB();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

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
      totalBooks, totalUsers, totalOrders,
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

// Health check
app.get('/api/health', (req, res) => res.json({ status: 'ok', timestamp: new Date().toISOString() }));

// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 BookNest API running on port ${PORT}`));
