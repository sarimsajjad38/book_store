const mongoose = require('mongoose');

const orderItemSchema = new mongoose.Schema({
  bookId: { type: mongoose.Schema.Types.ObjectId, ref: 'Book', required: true },
  title: String, author: String, imageUrl: String,
  price: { type: Number, required: true },
  quantity: { type: Number, required: true, min: 1 },
});

const orderSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  userName: { type: String, default: '' },
  items: [orderItemSchema],
  totalAmount: { type: Number, required: true },
  status: { type: String, enum: ['pending','confirmed','processing','shipped','outForDelivery','delivered','cancelled'], default: 'pending' },
  shippingAddress: { type: String, required: true },
  paymentMethod: { type: String, default: 'COD' },
  trackingId: { type: String, default: '' },
  deliveredAt: { type: Date },
}, { timestamps: true });

module.exports = mongoose.model('Order', orderSchema);
