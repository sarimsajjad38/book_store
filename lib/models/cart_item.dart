import 'book.dart';

class CartItem {
  final String id;
  final Book book;
  int quantity;

  CartItem({
    required this.id,
    required this.book,
    this.quantity = 1,
  });

  double get totalPrice => book.price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      book: Book.fromJson(json['book']),
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book': book.toJson(),
      'quantity': quantity,
    };
  }

  CartItem copyWith({
    String? id,
    Book? book,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      book: book ?? this.book,
      quantity: quantity ?? this.quantity,
    );
  }
}
