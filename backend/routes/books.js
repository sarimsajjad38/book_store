const express = require('express');
const Book = require('../models/Book');
const { protect, authorize } = require('../middleware/auth');
const router = express.Router();

// GET /api/books - Get all books (with optional category/search filters)
router.get('/', async (req, res) => {
  try {
    const { category, search, featured } = req.query;
    let query = {};
    if (category && category !== 'All') query.category = category;
    if (featured === 'true') query.isFeatured = true;
    if (search && search.trim().isNotEmpty !== false) {
      const trimmed = search.trim();
      query.$or = [
        { title: { $regex: trimmed, $options: 'i' } },
        { author: { $regex: trimmed, $options: 'i' } },
        { category: { $regex: trimmed, $options: 'i' } },
        { description: { $regex: trimmed, $options: 'i' } },
      ];
    }
    const books = await Book.find(query).sort({ createdAt: -1 });
    res.json(books);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// GET /api/books/:id
router.get('/:id', async (req, res) => {
  try {
    const book = await Book.findById(req.params.id);
    if (!book) return res.status(404).json({ message: 'Book not found' });
    res.json(book);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// POST /api/books - Create book (seller/admin only)
router.post('/', protect, authorize('seller', 'admin'), async (req, res) => {
  try {
    const book = await Book.create({ ...req.body, sellerId: req.user._id });
    res.status(201).json(book);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// PUT /api/books/:id - Update book
router.put('/:id', protect, authorize('seller', 'admin'), async (req, res) => {
  try {
    const book = await Book.findById(req.params.id);
    if (!book) return res.status(404).json({ message: 'Book not found' });
    if (book.sellerId.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Not authorized to edit this book' });
    }
    const updated = await Book.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(updated);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// DELETE /api/books/:id
router.delete('/:id', protect, authorize('seller', 'admin'), async (req, res) => {
  try {
    const book = await Book.findById(req.params.id);
    if (!book) return res.status(404).json({ message: 'Book not found' });
    if (book.sellerId.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Not authorized' });
    }
    await book.deleteOne();
    res.json({ message: 'Book deleted' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// GET /api/books/seller/:sellerId
router.get('/seller/:sellerId', protect, async (req, res) => {
  try {
    const books = await Book.find({ sellerId: req.params.sellerId });
    res.json(books);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
