import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';
import '../services/mock_data_service.dart';
import '../utils/constants.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  final _uuid = const Uuid();

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserOrders(String userId, [String? token]) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (token != null && token.isNotEmpty && !token.startsWith('mock_')) {
        try {
          final apiOrders = await ApiService.getUserOrders(token);
          _orders = apiOrders;
          _isLoading = false;
          notifyListeners();
          return;
        } catch (_) {}
      }

      if (ApiConstants.enableOfflineMockFallback) {
        _orders = MockDataService.getUserOrders(userId);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load orders';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSellerOrders(String sellerId, [String? token]) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (token != null && token.isNotEmpty && !token.startsWith('mock_')) {
        try {
          final apiOrders = await ApiService.getSellerOrders(token);
          _orders = apiOrders;
          _isLoading = false;
          notifyListeners();
          return;
        } catch (_) {}
      }

      if (ApiConstants.enableOfflineMockFallback) {
        _orders = MockDataService.getSellerOrders(sellerId);
        if (_orders.isEmpty) {
          _orders = MockDataService.getOrders();
        }
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load orders';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllOrders([String? token]) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (token != null && token.isNotEmpty && !token.startsWith('mock_')) {
        try {
          final apiOrders = await ApiService.getAllOrders(token);
          _orders = apiOrders;
          _isLoading = false;
          notifyListeners();
          return;
        } catch (_) {}
      }

      if (ApiConstants.enableOfflineMockFallback) {
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

  Future<Order?> placeOrder({
    required String userId,
    required String userName,
    required List<CartItem> cartItems,
    required String shippingAddress,
    String paymentMethod = 'COD',
    String? token,
    String? razorpayPaymentId,
    String? razorpayOrderId,
    String? razorpaySignature,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (token != null && token.isNotEmpty && !token.startsWith('mock_')) {
        try {
          final order = await ApiService.placeOrder(
            token: token,
            cartItems: cartItems,
            shippingAddress: shippingAddress,
            paymentMethod: paymentMethod,
            razorpayPaymentId: razorpayPaymentId,
            razorpayOrderId: razorpayOrderId,
            razorpaySignature: razorpaySignature,
          );
          _orders.insert(0, order);
          _isLoading = false;
          notifyListeners();
          return order;
        } catch (_) {}
      }

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

  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status, [
    String? token,
  ]) async {
    try {
      if (token != null && token.isNotEmpty && !token.startsWith('mock_')) {
        try {
          await ApiService.updateOrderStatus(orderId, status.name, token);
        } catch (_) {}
      }
      MockDataService.updateOrderStatus(orderId, status);
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          status: status,
          deliveredAt: status == OrderStatus.delivered ? DateTime.now() : null,
        );
        notifyListeners();
      }
    } catch (_) {
      MockDataService.updateOrderStatus(orderId, status);
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
