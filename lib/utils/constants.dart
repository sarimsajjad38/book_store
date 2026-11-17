import 'package:flutter/foundation.dart';

class ApiConstants {
  /// Base API URL dynamically resolved based on current platform
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5001/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5001/api';
    }
    return 'http://localhost:5001/api';
  }

  /// Toggle whether the app automatically falls back to local Mock data
  /// if the backend server is unreachable
  static bool enableOfflineMockFallback = true;

  // Auth endpoints
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String profile = '/auth/profile';

  // Book endpoints
  static const String books = '/books';
  static const String featuredBooks = '/books?featured=true';
  static const String searchBooks = '/books';
  static const String booksByCategory = '/books';

  // Order endpoints
  static const String orders = '/orders';
  static const String myOrders = '/orders/my';
  static const String sellerOrders = '/orders/seller';

  // Recommendation endpoint
  static const String recommendations = '/recommendations';

  // Admin endpoints
  static const String adminUsers = '/admin/users';
  static const String adminStats = '/admin/stats';
}

class AppStrings {
  static const String appName = 'BookNest';
  static const String tagline = 'Your Literary Paradise';
  static const String welcomeBack = 'Welcome Back';
  static const String signInToContinue = 'Sign in to continue your reading journey';
  static const String createAccount = 'Create Account';
  static const String joinUs = 'Join us and discover your next great read';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String fullName = 'Full Name';
  static const String login = 'Login';
  static const String signUp = 'Sign Up';
  static const String noAccount = "Don't have an account? ";
  static const String haveAccount = "Already have an account? ";
  static const String featuredBooks = 'Featured Books';
  static const String allBooks = 'All Books';
  static const String categories = 'Categories';
  static const String myCart = 'My Cart';
  static const String checkout = 'Checkout';
  static const String orderHistory = 'Order History';
  static const String profile = 'Profile';
  static const String addToCart = 'Add to Cart';
  static const String placeOrder = 'Place Order';
  static const String trackOrder = 'Track Order';
}

class BookCategories {
  static const List<String> all = [
    'All',
    'Fiction',
    'Non-Fiction',
    'Science',
    'History',
    'Biography',
    'Self-Help',
    'Technology',
    'Poetry',
    'Children',
    'Mystery',
    'Romance',
  ];

  static const Map<String, String> icons = {
    'All': '📚',
    'Fiction': '✨',
    'Non-Fiction': '📖',
    'Science': '🔬',
    'History': '🏛️',
    'Biography': '👤',
    'Self-Help': '🌟',
    'Technology': '💻',
    'Poetry': '🎭',
    'Children': '🧸',
    'Mystery': '🔍',
    'Romance': '💕',
  };
}
