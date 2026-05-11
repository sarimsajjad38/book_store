import '../models/book.dart';
import '../models/order.dart';
import '../models/user.dart';

/// Mock data service that simulates backend operations.
/// Replace with real API calls when backend is connected.
class MockDataService {
  static final List<Book> _books = [
    Book(
      id: '1',
      title: 'A Brief History of Time',
      author: 'Stephen Hawking',
      description:
          'A landmark volume in science writing by one of the great minds of our time. Hawking attempts to explain a range of subjects in cosmology, including the Big Bang, black holes, and light cones.',
      price: 299.0,
      imageUrl: 'https://m.media-amazon.com/images/I/81DBK93b6jL.jpg',
      category: 'Science',
      quantity: 50,
      rating: 4.7,
      reviewCount: 1245,
      sellerId: 'seller1',
      isFeatured: true,
    ),
    Book(
      id: '2',
      title: 'Sapiens: A Brief History of Humankind',
      author: 'Yuval Noah Harari',
      description:
          'In Sapiens, Dr Yuval Noah Harari spans the whole of human history, from the very first humans to walk the earth to the radical breakthroughs of the Cognitive, Agricultural and Scientific Revolutions.',
      price: 399.0,
      imageUrl: 'https://m.media-amazon.com/images/I/713jIoMO3UL.jpg',
      category: 'History',
      quantity: 35,
      rating: 4.8,
      reviewCount: 2103,
      sellerId: 'seller1',
      isFeatured: true,
    ),
    Book(
      id: '3',
      title: 'Atomic Habits',
      author: 'James Clear',
      description:
          'Tiny Changes, Remarkable Results. No matter your goals, Atomic Habits offers a proven framework for improving—every day.',
      price: 349.0,
      imageUrl: 'https://m.media-amazon.com/images/I/81YkqyaFVEL.jpg',
      category: 'Self-Help',
      quantity: 80,
      rating: 4.9,
      reviewCount: 5421,
      sellerId: 'seller1',
      isFeatured: true,
    ),
    Book(
      id: '4',
      title: 'The Great Gatsby',
      author: 'F. Scott Fitzgerald',
      description:
          'The story of the mysteriously wealthy Jay Gatsby and his love for the beautiful Daisy Buchanan.',
      price: 199.0,
      imageUrl: 'https://m.media-amazon.com/images/I/71FTb9X6wsL.jpg',
      category: 'Fiction',
      quantity: 60,
      rating: 4.5,
      reviewCount: 3200,
      sellerId: 'seller2',
      isFeatured: false,
    ),
    Book(
      id: '5',
      title: 'Clean Code',
      author: 'Robert C. Martin',
      description:
          'A Handbook of Agile Software Craftsmanship. Clean Code is divided into three parts which guide you through the principles, patterns, and practices of writing clean code.',
      price: 499.0,
      imageUrl: 'https://m.media-amazon.com/images/I/41xShlnTZTL.jpg',
      category: 'Technology',
      quantity: 25,
      rating: 4.6,
      reviewCount: 1890,
      sellerId: 'seller2',
      isFeatured: true,
    ),
    Book(
      id: '6',
      title: 'Gitanjali',
      author: 'Rabindranath Tagore',
      description:
          'A collection of poems by the Bengali poet, originally published in 1910. The English translation was published in 1912.',
      price: 149.0,
      imageUrl: 'https://m.media-amazon.com/images/I/71c1S1UsMML.jpg',
      category: 'Poetry',
      quantity: 40,
      rating: 4.8,
      reviewCount: 890,
      sellerId: 'seller1',
      isFeatured: false,
    ),
    Book(
      id: '7',
      title: 'Steve Jobs',
      author: 'Walter Isaacson',
      description:
          'Based on more than forty interviews with Jobs conducted over two years. The exclusive biography of Apple co-founder.',
      price: 450.0,
      imageUrl: 'https://m.media-amazon.com/images/I/81VStYnDGrL.jpg',
      category: 'Biography',
      quantity: 30,
      rating: 4.7,
      reviewCount: 2450,
      sellerId: 'seller2',
      isFeatured: true,
    ),
    Book(
      id: '8',
      title: 'The Psychology of Money',
      author: 'Morgan Housel',
      description:
          'Timeless lessons on wealth, greed, and happiness. Doing well with money isn\'t about how smart you are. It\'s about how you behave.',
      price: 299.0,
      imageUrl: 'https://m.media-amazon.com/images/I/71TRUbzcvaL.jpg',
      category: 'Self-Help',
      quantity: 70,
      rating: 4.8,
      reviewCount: 3100,
      sellerId: 'seller1',
      isFeatured: true,
    ),
    Book(
      id: '9',
      title: 'Sherlock Holmes: Complete Collection',
      author: 'Arthur Conan Doyle',
      description:
          'The complete collection of Sherlock Holmes stories, featuring the greatest detective of all time.',
      price: 599.0,
      imageUrl: 'https://m.media-amazon.com/images/I/81MFpGCCejL.jpg',
      category: 'Mystery',
      quantity: 20,
      rating: 4.9,
      reviewCount: 4500,
      sellerId: 'seller2',
      isFeatured: false,
    ),
    Book(
      id: '10',
      title: 'Pride and Prejudice',
      author: 'Jane Austen',
      description:
          'Since its immediate success in 1813, Pride and Prejudice has remained one of the most popular novels in the English language.',
      price: 179.0,
      imageUrl: 'https://m.media-amazon.com/images/I/71Q1tPupKjL.jpg',
      category: 'Romance',
      quantity: 45,
      rating: 4.7,
      reviewCount: 3800,
      sellerId: 'seller1',
      isFeatured: false,
    ),
    Book(
      id: '11',
      title: 'The Alchemist',
      author: 'Paulo Coelho',
      description:
          'The magical story of Santiago, an Andalusian shepherd boy who yearns to travel in search of a treasure.',
      price: 249.0,
      imageUrl: 'https://m.media-amazon.com/images/I/71aFt4+OTOL.jpg',
      category: 'Fiction',
      quantity: 55,
      rating: 4.6,
      reviewCount: 6200,
      sellerId: 'seller1',
      isFeatured: true,
    ),
    Book(
      id: '12',
      title: 'Thinking, Fast and Slow',
      author: 'Daniel Kahneman',
      description:
          'A groundbreaking tour of the mind, explaining the two systems that drive the way we think.',
      price: 379.0,
      imageUrl: 'https://m.media-amazon.com/images/I/71wvKXWfcML.jpg',
      category: 'Non-Fiction',
      quantity: 35,
      rating: 4.5,
      reviewCount: 2800,
      sellerId: 'seller2',
      isFeatured: false,
    ),
  ];

  static final List<AppUser> _users = [
    AppUser(
      id: 'admin1',
      name: 'Admin User',
      email: 'admin@booknest.com',
      role: UserRole.admin,
      phone: '6969696969',
      address: '123 Admin Street, New Delhi',
    ),
    AppUser(
      id: 'seller1',
      name: 'Kumar Harsh',
      email: 'seller@booknest.com',
      role: UserRole.seller,
      phone: '9876543211',
      address: '456 Book Lane, Mumbai',
    ),
    AppUser(
      id: 'seller2',
      name: 'Rohit Kumar Bhagat',
      email: 'priya@booknest.com',
      role: UserRole.seller,
      phone: '6969696969',
      address: '789 Library Road, Bangalore',
    ),
    AppUser(
      id: 'customer1',
      name: 'Roshan sher Singh',
      email: 'customer@booknest.com',
      role: UserRole.customer,
      phone: '6969696969',
      address: '101 Reader Avenue, Kolkata',
    ),
  ];

  static final List<Order> _orders = [
    Order(
      id: 'ORD001',
      userId: 'customer1',
      userName: 'Roshan Singh',
      items: [
        OrderItem(
          bookId: '1',
          title: 'A Brief History of Time',
          author: 'Stephen Hawking',
          imageUrl: 'https://m.media-amazon.com/images/I/81DBK93b6jL.jpg',
          price: 299.0,
          quantity: 1,
        ),
        OrderItem(
          bookId: '3',
          title: 'Atomic Habits',
          author: 'James Clear',
          imageUrl: 'https://m.media-amazon.com/images/I/81YkqyaFVEL.jpg',
          price: 349.0,
          quantity: 2,
        ),
      ],
      totalAmount: 997.0,
      status: OrderStatus.shipped,
      shippingAddress: '101 Reader Avenue, Kolkata 700001',
      trackingId: 'TRK123456789',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Order(
      id: 'ORD002',
      userId: 'customer1',
      userName: 'Roshan sher Singh',
      items: [
        OrderItem(
          bookId: '5',
          title: 'Clean Code',
          author: 'Robert C. Martin',
          imageUrl: 'https://m.media-amazon.com/images/I/41xShlnTZTL.jpg',
          price: 499.0,
          quantity: 1,
        ),
      ],
      totalAmount: 499.0,
      status: OrderStatus.delivered,
      shippingAddress: '101 Reader Avenue, Kolkata 700001',
      trackingId: 'TRK987654321',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      deliveredAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  // Books
  static List<Book> getBooks() => List.from(_books);

  static List<Book> getFeaturedBooks() =>
      _books.where((b) => b.isFeatured).toList();

  static List<Book> getBooksByCategory(String category) {
    if (category == 'All') return List.from(_books);
    return _books.where((b) => b.category == category).toList();
  }

  static List<Book> searchBooks(String query) {
    final q = query.toLowerCase();
    return _books.where((b) {
      return b.title.toLowerCase().contains(q) ||
          b.author.toLowerCase().contains(q) ||
          b.category.toLowerCase().contains(q);
    }).toList();
  }

  static Book? getBookById(String id) {
    try {
      return _books.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<Book> getSellerBooks(String sellerId) {
    return _books.where((b) => b.sellerId == sellerId).toList();
  }

  static void addBook(Book book) {
    _books.add(book);
  }

  static void updateBook(Book book) {
    final index = _books.indexWhere((b) => b.id == book.id);
    if (index != -1) _books[index] = book;
  }

  static void deleteBook(String id) {
    _books.removeWhere((b) => b.id == id);
  }

  // Users
  static AppUser? authenticateUser(String email, String password) {
    try {
      final user = _users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );
      // In mock mode, any password works
      return user.copyWith(token: 'mock_jwt_token_${user.id}');
    } catch (_) {
      return null;
    }
  }

  static AppUser? registerUser(String name, String email, String password,
      {UserRole role = UserRole.customer}) {
    // Check if email exists
    final exists = _users.any(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
    if (exists) return null;

    final newUser = AppUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      role: role,
      token: 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
    );
    _users.add(newUser);
    return newUser;
  }

  static List<AppUser> getAllUsers() => List.from(_users);

  // Orders
  static List<Order> getOrders() => List.from(_orders);

  static List<Order> getUserOrders(String userId) {
    return _orders.where((o) => o.userId == userId).toList();
  }

  static List<Order> getSellerOrders(String sellerId) {
    // Orders containing books from this seller
    return _orders.where((order) {
      return order.items.any((item) {
        final book = getBookById(item.bookId);
        return book?.sellerId == sellerId;
      });
    }).toList();
  }

  static void addOrder(Order order) {
    _orders.insert(0, order);
  }

  static void updateOrderStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(
        status: status,
        deliveredAt: status == OrderStatus.delivered ? DateTime.now() : null,
      );
    }
  }

  // Recommendations (basic content-based)
  static List<Book> getRecommendations(List<String> viewedBookIds) {
    if (viewedBookIds.isEmpty) return getFeaturedBooks();

    // Get categories of viewed books
    final viewedCategories = <String>{};
    for (final id in viewedBookIds) {
      final book = getBookById(id);
      if (book != null) viewedCategories.add(book.category);
    }

    // Recommend books from same categories, excluding already viewed
    final recommendations = _books.where((b) {
      return viewedCategories.contains(b.category) &&
          !viewedBookIds.contains(b.id);
    }).toList();

    // Sort by rating
    recommendations.sort((a, b) => b.rating.compareTo(a.rating));

    // If not enough, add top-rated books
    if (recommendations.length < 4) {
      final topRated = _books
          .where((b) => !viewedBookIds.contains(b.id))
          .toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));
      for (final book in topRated) {
        if (!recommendations.contains(book)) {
          recommendations.add(book);
        }
        if (recommendations.length >= 6) break;
      }
    }

    return recommendations.take(6).toList();
  }

  // Admin stats
  static Map<String, dynamic> getAdminStats() {
    return {
      'totalBooks': _books.length,
      'totalUsers': _users.length,
      'totalOrders': _orders.length,
      'totalRevenue': _orders.fold<double>(
        0,
        (sum, order) => sum + order.totalAmount,
      ),
      'pendingOrders':
          _orders.where((o) => o.status == OrderStatus.pending).length,
      'deliveredOrders':
          _orders.where((o) => o.status == OrderStatus.delivered).length,
    };
  }
}
