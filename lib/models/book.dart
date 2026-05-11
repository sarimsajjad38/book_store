class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int quantity;
  final double rating;
  final int reviewCount;
  final String sellerId;
  final DateTime createdAt;
  final bool isFeatured;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.description = '',
    required this.price,
    this.imageUrl = '',
    this.category = 'General',
    this.quantity = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.sellerId = '',
    DateTime? createdAt,
    this.isFeatured = false,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? 'General',
      quantity: json['quantity'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      sellerId: json['sellerId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isFeatured: json['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'quantity': quantity,
      'rating': rating,
      'reviewCount': reviewCount,
      'sellerId': sellerId,
      'createdAt': createdAt.toIso8601String(),
      'isFeatured': isFeatured,
    };
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    int? quantity,
    double? rating,
    int? reviewCount,
    String? sellerId,
    DateTime? createdAt,
    bool? isFeatured,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      sellerId: sellerId ?? this.sellerId,
      createdAt: createdAt ?? this.createdAt,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}
