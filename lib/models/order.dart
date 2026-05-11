import 'cart_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
}

class OrderItem {
  final String bookId;
  final String title;
  final String author;
  final String imageUrl;
  final double price;
  final int quantity;

  OrderItem({
    required this.bookId,
    required this.title,
    required this.author,
    this.imageUrl = '',
    required this.price,
    required this.quantity,
  });

  double get totalPrice => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      bookId: json['bookId'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromCartItem(CartItem cartItem) {
    return OrderItem(
      bookId: cartItem.book.id,
      title: cartItem.book.title,
      author: cartItem.book.author,
      imageUrl: cartItem.book.imageUrl,
      price: cartItem.book.price,
      quantity: cartItem.quantity,
    );
  }
}

class Order {
  final String id;
  final String userId;
  final String userName;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final String shippingAddress;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String? trackingId;

  Order({
    required this.id,
    required this.userId,
    this.userName = '',
    required this.items,
    required this.totalAmount,
    this.status = OrderStatus.pending,
    this.shippingAddress = '',
    this.paymentMethod = 'COD',
    DateTime? createdAt,
    this.deliveredAt,
    this.trackingId,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: _parseStatus(json['status']),
      shippingAddress: json['shippingAddress'] ?? '',
      paymentMethod: json['paymentMethod'] ?? 'COD',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
      trackingId: json['trackingId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status.name,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'trackingId': trackingId,
    };
  }

  static OrderStatus _parseStatus(String? status) {
    switch (status) {
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'outForDelivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  Order copyWith({
    String? id,
    String? userId,
    String? userName,
    List<OrderItem>? items,
    double? totalAmount,
    OrderStatus? status,
    String? shippingAddress,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? deliveredAt,
    String? trackingId,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      trackingId: trackingId ?? this.trackingId,
    );
  }

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}
