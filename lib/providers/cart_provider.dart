import 'package:flutter/material.dart';
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
    notifyListeners();
  }

  void removeFromCart(String bookId) {
    _items.removeWhere((item) => item.book.id == bookId);
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
      notifyListeners();
    }
  }

  void incrementQuantity(String bookId) {
    final index = _items.indexWhere((item) => item.book.id == bookId);
    if (index >= 0) {
      _items[index].quantity++;
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
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
