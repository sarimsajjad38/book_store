const express = require('express');
const https = require('https');
const Order = require('../models/Order');
const Book = require('../models/Book');
const { protect, authorize } = require('../middleware/auth');
const router = express.Router();

// POST /api/orders/create-razorpay-order
router.post('/create-razorpay-order', protect, async (req, res) => {
  try {
    const { amount } = req.body;
    if (!amount || amount <= 0) {
      return res.status(400).json({ message: 'Valid amount is required' });
    }

    const keyId = process.env.RAZORPAY_KEY_ID || 'rzp_test_booknest2026';
    const keySecret = process.env.RAZORPAY_KEY_SECRET;
    const amountInPaise = Math.round(amount * 100);

    // If live credentials are provided in .env, call Razorpay API
    if (keySecret) {
      const auth = Buffer.from(`${keyId}:${keySecret}`).toString('base64');
      const postData = JSON.stringify({
        amount: amountInPaise,
        currency: 'INR',
        receipt: `rcpt_${Date.now()}`,
      });

      const options = {
        hostname: 'api.razorpay.com',
        port: 443,
        path: '/v1/orders',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Basic ${auth}`,
          'Content-Length': Buffer.byteLength(postData),
        },
      };

      const request = https.request(options, (response) => {
        let data = '';
        response.on('data', (chunk) => (data += chunk));
        response.on('end', () => {
          try {
            const parsed = JSON.parse(data);
            if (response.statusCode >= 200 && response.statusCode < 300) {
              return res.json({ orderId: parsed.id, keyId, amount: amountInPaise });
            } else {
              return res.status(response.statusCode).json({ message: parsed.error?.description || 'Razorpay order creation failed' });
            }
          } catch (_) {
            return res.status(500).json({ message: 'Failed to parse Razorpay response' });
          }
        });
      });

      request.on('error', (err) => res.status(500).json({ message: err.message }));
      request.write(postData);
      request.end();
    } else {
      // Test / development mode
      res.json({
        orderId: `order_test_${Date.now()}`,
        keyId,
        amount: amountInPaise,
      });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// POST /api/orders - Place order
router.post('/', protect, async (req, res) => {
  try {
    const { items, shippingAddress, paymentMethod, razorpayPaymentId, razorpayOrderId, razorpaySignature } = req.body;
    if (!items || items.length === 0) return res.status(400).json({ message: 'No items in order' });

    const totalAmount = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
    const trackingId = `TRK${Date.now()}`;
    const isPaid = paymentMethod !== 'COD' && razorpayPaymentId;

    const order = await Order.create({
      userId: req.user._id,
      userName: req.user.name,
      items,
      totalAmount,
      shippingAddress,
      paymentMethod: paymentMethod || 'COD',
      paymentStatus: isPaid ? 'paid' : 'unpaid',
      status: isPaid ? 'confirmed' : 'pending',
      razorpayPaymentId: razorpayPaymentId || '',
      razorpayOrderId: razorpayOrderId || '',
      razorpaySignature: razorpaySignature || '',
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
