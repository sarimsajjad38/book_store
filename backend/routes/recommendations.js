const express = require('express');
const Book = require('../models/Book');
const Order = require('../models/Order');
const { protect } = require('../middleware/auth');
const router = express.Router();

// GET /api/recommendations?userId=xxx
// Basic content-based recommendation engine
router.get('/', protect, async (req, res) => {
  try {
    // Get user's order history to find preferred categories
    const userOrders = await Order.find({ userId: req.user._id });
    const purchasedBookIds = [];
    const categoryCount = {};

    for (const order of userOrders) {
      for (const item of order.items) {
        purchasedBookIds.push(item.bookId.toString());
        const book = await Book.findById(item.bookId);
        if (book) {
          categoryCount[book.category] = (categoryCount[book.category] || 0) + item.quantity;
        }
      }
    }

    // Sort categories by purchase frequency
    const sortedCategories = Object.entries(categoryCount)
      .sort((a, b) => b[1] - a[1])
      .map(([cat]) => cat);

    let recommendations = [];

    if (sortedCategories.length > 0) {
      // Get books from preferred categories, excluding already purchased
      recommendations = await Book.find({
        _id: { $nin: purchasedBookIds },
        category: { $in: sortedCategories.slice(0, 3) },
      }).sort({ rating: -1 }).limit(6);
    }

    // Fill remaining slots with top-rated books
    if (recommendations.length < 6) {
      const topRated = await Book.find({
        _id: { $nin: [...purchasedBookIds, ...recommendations.map(b => b._id)] },
      }).sort({ rating: -1 }).limit(6 - recommendations.length);
      recommendations = [...recommendations, ...topRated];
    }

    res.json(recommendations);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
