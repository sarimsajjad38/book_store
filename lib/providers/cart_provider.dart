import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/book.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  final _uuid = const Uuid();

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  int get totalQuantity =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get deliveryCharge => totalAmount > 500 ? 0 : 40;
  double get finalAmount => totalAmount + deliveryCharge;

  CartProvider() {
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('cart_items');
      if (cartData != null) {
        final List<dynamic> list = json.decode(cartData);
        _items.clear();
        for (final item in list) {
          _items.add(CartItem.fromJson(item));
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = json.encode(_items.map((i) => i.toJson()).toList());
      await prefs.setString('cart_items', cartData);
    } catch (_) {}
  }

  bool isInCart(String bookId) {
    return _items.any((item) => item.book.id == bookId);
  }

  void addToCart(Book book, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((item) => item.book.id == book.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        id: _uuid.v4(),
        book: book,
        quantity: quantity,
      ));
    }
    _saveCart();
    notifyListeners();
  }

  void removeFromCart(String bookId) {
    _items.removeWhere((item) => item.book.id == bookId);
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(String bookId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(bookId);
      return;
    }
    final index = _items.indexWhere((item) => item.book.id == bookId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      _saveCart();
      notifyListeners();
    }
  }

  void incrementQuantity(String bookId) {
    final index = _items.indexWhere((item) => item.book.id == bookId);
    if (index >= 0) {
      _items[index].quantity++;
      _saveCart();
      notifyListeners();
    }
  }

  void decrementQuantity(String bookId) {
    final index = _items.indexWhere((item) => item.book.id == bookId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      _saveCart();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }
}
