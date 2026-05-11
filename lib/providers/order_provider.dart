import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../services/mock_data_service.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  final _uuid = const Uuid();

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserOrders(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _orders = MockDataService.getUserOrders(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load orders';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSellerOrders(String sellerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _orders = MockDataService.getSellerOrders(sellerId);
      // Also include all orders for demo
      if (_orders.isEmpty) {
        _orders = MockDataService.getOrders();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load orders';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _orders = MockDataService.getOrders();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load orders';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Order?> placeOrder({
    required String userId,
    required String userName,
    required List<CartItem> cartItems,
    required String shippingAddress,
    String paymentMethod = 'COD',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      final orderItems =
          cartItems.map((item) => OrderItem.fromCartItem(item)).toList();

      final totalAmount =
          cartItems.fold<double>(0, (sum, item) => sum + item.totalPrice);

      final order = Order(
        id: 'ORD${_uuid.v4().substring(0, 8).toUpperCase()}',
        userId: userId,
        userName: userName,
        items: orderItems,
        totalAmount: totalAmount,
        status: OrderStatus.pending,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        trackingId: 'TRK${DateTime.now().millisecondsSinceEpoch}',
      );

      MockDataService.addOrder(order);
      _orders.insert(0, order);
      _isLoading = false;
      notifyListeners();
      return order;
    } catch (e) {
      _error = 'Failed to place order';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    MockDataService.updateOrderStatus(orderId, status);
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(
        status: status,
        deliveredAt:
            status == OrderStatus.delivered ? DateTime.now() : null,
      );
      notifyListeners();
    }
  }

  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }
}
