const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { protect } = require('../middleware/auth');
const router = express.Router();

const generateToken = (id) =>
  jwt.sign(
    { id },
    process.env.JWT_SECRET || 'booknest_jwt_secret_key_change_in_production_2026',
    { expiresIn: process.env.JWT_EXPIRE || '30d' }
  );

// POST /api/auth/signup
router.post('/signup', async (req, res) => {
  try {
    const { name, email, password, role } = req.body;
    const userExists = await User.findOne({ email });
    if (userExists) return res.status(400).json({ message: 'Email already registered' });

    const user = await User.create({ name, email, password, role: role || 'customer' });
    res.status(201).json({
      _id: user._id, name: user.name, email: user.email, role: user.role,
      phone: user.phone, address: user.address,
      token: generateToken(user._id),
      createdAt: user.createdAt,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user || !(await user.matchPassword(password))) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }
    res.json({
      _id: user._id, name: user.name, email: user.email, role: user.role,
      phone: user.phone, address: user.address,
      token: generateToken(user._id),
      createdAt: user.createdAt,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// GET /api/auth/profile
router.get('/profile', protect, async (req, res) => {
  res.json(req.user);
});

// PUT /api/auth/profile
router.put('/profile', protect, async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    user.name = req.body.name || user.name;
    user.phone = req.body.phone || user.phone;
    user.address = req.body.address || user.address;
    if (req.body.password) user.password = req.body.password;
    const updated = await user.save();
    res.json({ _id: updated._id, name: updated.name, email: updated.email, role: updated.role, phone: updated.phone, address: updated.address });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// PUT /api/auth/fcm-token - Update FCM push notification device token
router.put('/fcm-token', protect, async (req, res) => {
  try {
    const { fcmToken } = req.body;
    if (!fcmToken) return res.status(400).json({ message: 'fcmToken is required' });
    const user = await User.findByIdAndUpdate(
      req.user._id,
      { fcmToken },
      { new: true }
    ).select('-password');
    res.json({ message: 'FCM token updated successfully', user });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// DELETE /api/auth/account - Delete user account (App Store & Google Play compliance)
router.delete('/account', protect, async (req, res) => {
  try {
    const userId = req.user._id;
    await User.findByIdAndDelete(userId);
    res.json({ success: true, message: 'Account and associated personal data deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
