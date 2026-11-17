const express = require('express');
const Order = require('../models/Order');
const Book = require('../models/Book');
const { protect, authorize } = require('../middleware/auth');
const router = express.Router();

// POST /api/orders - Place order
router.post('/', protect, async (req, res) => {
  try {
    const { items, shippingAddress, paymentMethod } = req.body;
    if (!items || items.length === 0) return res.status(400).json({ message: 'No items in order' });

    const totalAmount = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
    const trackingId = `TRK${Date.now()}`;

    const order = await Order.create({
      userId: req.user._id,
      userName: req.user.name,
      items,
      totalAmount,
      shippingAddress,
      paymentMethod: paymentMethod || 'COD',
      trackingId,
    });

    // Update book inventory quantities
    for (const item of items) {
      try {
        await Book.findByIdAndUpdate(item.bookId, { $inc: { quantity: -item.quantity } });
      } catch (_) {}
    }

    res.status(201).json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// GET /api/orders/my - Get user's orders
router.get('/my', protect, async (req, res) => {
  try {
    const orders = await Order.find({ userId: req.user._id }).sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// GET /api/orders/seller - Get seller's orders
router.get('/seller', protect, authorize('seller', 'admin'), async (req, res) => {
  try {
    // If admin, return all orders; if seller, find orders with their books
    if (req.user.role === 'admin') {
      const orders = await Order.find().sort({ createdAt: -1 });
      return res.json(orders);
    }

    const sellerBooks = await Book.find({ sellerId: req.user._id }).select('_id');
    const sellerBookIds = sellerBooks.map(b => b._id);

    const orders = await Order.find({ 'items.bookId': { $in: sellerBookIds } }).sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// GET /api/orders - Get all orders (admin only)
router.get('/', protect, authorize('admin'), async (req, res) => {
  try {
    const orders = await Order.find().sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// PUT /api/orders/:id/status - Update order status
router.put('/:id/status', protect, authorize('seller', 'admin'), async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ message: 'Order not found' });
    order.status = req.body.status;
    if (req.body.status === 'delivered') order.deliveredAt = Date.now();
    const updated = await order.save();
    res.json(updated);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
