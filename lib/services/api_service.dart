import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../models/order.dart';
import '../models/user.dart';
import '../models/cart_item.dart';
import '../utils/constants.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 10);

  static Map<String, String> _headers([String? token]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // --- HEALTH CHECK ---
  static Future<bool> isBackendAvailable() async {
    try {
      final res = await http
          .get(Uri.parse('${ApiConstants.baseUrl}/health'))
          .timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // --- AUTH ---
  static Future<AppUser> login(String email, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}');
    final res = await http
        .post(
          url,
          headers: _headers(),
          body: json.encode({'email': email, 'password': password}),
        )
        .timeout(_timeout);

    final data = json.decode(res.body);
    if (res.statusCode == 200) {
      return AppUser.fromJson(data);
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  static Future<AppUser> signup(
    String name,
    String email,
    String password, {
    String role = 'customer',
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.signup}');
    final res = await http
        .post(
          url,
          headers: _headers(),
          body: json.encode({
            'name': name,
            'email': email,
            'password': password,
            'role': role,
          }),
        )
        .timeout(_timeout);

    final data = json.decode(res.body);
    if (res.statusCode == 201 || res.statusCode == 200) {
      return AppUser.fromJson(data);
    } else {
      throw Exception(data['message'] ?? 'Sign up failed');
    }
  }

  static Future<AppUser> getProfile(String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}');
    final res = await http.get(url, headers: _headers(token)).timeout(_timeout);

    final data = json.decode(res.body);
    if (res.statusCode == 200) {
      return AppUser.fromJson(data);
    } else {
      throw Exception(data['message'] ?? 'Failed to get profile');
    }
  }

  static Future<AppUser> updateProfile(
    String token, {
    String? name,
    String? phone,
    String? address,
    String? password,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}');
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (address != null) body['address'] = address;
    if (password != null && password.isNotEmpty) body['password'] = password;

    final res = await http
        .put(url, headers: _headers(token), body: json.encode(body))
        .timeout(_timeout);

    final data = json.decode(res.body);
    if (res.statusCode == 200) {
      return AppUser.fromJson(data);
    } else {
      throw Exception(data['message'] ?? 'Failed to update profile');
    }
  }

  static Future<bool> deleteAccount(String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.deleteAccount}');
    final res = await http.delete(url, headers: _headers(token)).timeout(_timeout);
    return res.statusCode == 200;
  }

  // --- BOOKS ---
  static Future<List<Book>> getBooks({
    String? category,
    String? search,
    bool? featured,
  }) async {
    final queryParams = <String, String>{};
    if (category != null && category != 'All') queryParams['category'] = category;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (featured == true) queryParams['featured'] = 'true';

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.books}')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final res = await http.get(uri, headers: _headers()).timeout(_timeout);
    if (res.statusCode == 200) {
      final List<dynamic> list = json.decode(res.body);
      return list.map((item) => Book.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load books: ${res.statusCode}');
    }
  }

  static Future<Book> getBookById(String id) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.books}/$id');
    final res = await http.get(url, headers: _headers()).timeout(_timeout);

    if (res.statusCode == 200) {
      return Book.fromJson(json.decode(res.body));
    } else {
      throw Exception('Book not found');
    }
  }

  static Future<List<Book>> getSellerBooks(String sellerId, String token) async {
    final url =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.books}/seller/$sellerId');
    final res = await http.get(url, headers: _headers(token)).timeout(_timeout);

    if (res.statusCode == 200) {
      final List<dynamic> list = json.decode(res.body);
      return list.map((item) => Book.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load seller books');
    }
  }

  static Future<Book> addBook(Book book, String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.books}');
    final res = await http
        .post(
          url,
          headers: _headers(token),
          body: json.encode({
            'title': book.title,
            'author': book.author,
            'description': book.description,
            'price': book.price,
            'imageUrl': book.imageUrl,
            'category': book.category,
            'quantity': book.quantity,
            'rating': book.rating,
            'isFeatured': book.isFeatured,
          }),
        )
        .timeout(_timeout);

    if (res.statusCode == 201 || res.statusCode == 200) {
      return Book.fromJson(json.decode(res.body));
    } else {
      final data = json.decode(res.body);
      throw Exception(data['message'] ?? 'Failed to add book');
    }
  }

  static Future<Book> updateBook(Book book, String token) async {
    final url =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.books}/${book.id}');
    final res = await http
        .put(
          url,
          headers: _headers(token),
          body: json.encode({
            'title': book.title,
            'author': book.author,
            'description': book.description,
            'price': book.price,
            'imageUrl': book.imageUrl,
            'category': book.category,
            'quantity': book.quantity,
            'rating': book.rating,
            'isFeatured': book.isFeatured,
          }),
        )
        .timeout(_timeout);

    if (res.statusCode == 200) {
      return Book.fromJson(json.decode(res.body));
    } else {
      final data = json.decode(res.body);
      throw Exception(data['message'] ?? 'Failed to update book');
    }
  }

  static Future<bool> deleteBook(String id, String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.books}/$id');
    final res = await http.delete(url, headers: _headers(token)).timeout(_timeout);
    return res.statusCode == 200;
  }

  static Future<String> uploadCoverImage(dynamic imageFile, {String? token}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.uploadCover}');
    final request = http.MultipartRequest('POST', url);
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(await http.MultipartFile.fromPath('cover', imageFile.path));
    final streamedResponse = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['imageUrl'] as String;
    } else {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Failed to upload cover image');
    }
  }

  static Future<List<Book>> getRecommendations(String token) async {
    final url =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.recommendations}');
    final res = await http.get(url, headers: _headers(token)).timeout(_timeout);

    if (res.statusCode == 200) {
      final List<dynamic> list = json.decode(res.body);
      return list.map((item) => Book.fromJson(item)).toList();
    } else {
      return [];
    }
  }

  // --- ORDERS ---
  static Future<Order> placeOrder({
    required String token,
    required List<CartItem> cartItems,
    required String shippingAddress,
    String paymentMethod = 'COD',
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.orders}');
    final itemsPayload = cartItems
        .map((item) => {
              'bookId': item.book.id,
              'title': item.book.title,
              'author': item.book.author,
              'imageUrl': item.book.imageUrl,
              'price': item.book.price,
              'quantity': item.quantity,
            })
        .toList();

    final res = await http
        .post(
          url,
          headers: _headers(token),
          body: json.encode({
            'items': itemsPayload,
            'shippingAddress': shippingAddress,
            'paymentMethod': paymentMethod,
          }),
        )
        .timeout(_timeout);

    if (res.statusCode == 201 || res.statusCode == 200) {
      return Order.fromJson(json.decode(res.body));
    } else {
      final data = json.decode(res.body);
      throw Exception(data['message'] ?? 'Failed to place order');
    }
  }

  static Future<List<Order>> getUserOrders(String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.myOrders}');
    final res = await http.get(url, headers: _headers(token)).timeout(_timeout);

    if (res.statusCode == 200) {
      final List<dynamic> list = json.decode(res.body);
      return list.map((item) => Order.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  static Future<List<Order>> getSellerOrders(String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.sellerOrders}');
    final res = await http.get(url, headers: _headers(token)).timeout(_timeout);

    if (res.statusCode == 200) {
      final List<dynamic> list = json.decode(res.body);
      return list.map((item) => Order.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load seller orders');
    }
  }

  static Future<List<Order>> getAllOrders(String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.orders}');
    final res = await http.get(url, headers: _headers(token)).timeout(_timeout);

    if (res.statusCode == 200) {
      final List<dynamic> list = json.decode(res.body);
      return list.map((item) => Order.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load all orders');
    }
  }

  static Future<Order> updateOrderStatus(
    String orderId,
    String status,
    String token,
  ) async {
    final url =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.orders}/$orderId/status');
    final res = await http
        .put(
          url,
          headers: _headers(token),
          body: json.encode({'status': status}),
        )
        .timeout(_timeout);

    if (res.statusCode == 200) {
      return Order.fromJson(json.decode(res.body));
    } else {
      final data = json.decode(res.body);
      throw Exception(data['message'] ?? 'Failed to update order status');
    }
  }

  // --- ADMIN ---
  static Future<Map<String, dynamic>> getAdminStats(String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.adminStats}');
    final res = await http.get(url, headers: _headers(token)).timeout(_timeout);

    if (res.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(res.body));
    } else {
      throw Exception('Failed to load admin stats');
    }
  }

  static Future<List<AppUser>> getAdminUsers(String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.adminUsers}');
    final res = await http.get(url, headers: _headers(token)).timeout(_timeout);

    if (res.statusCode == 200) {
      final List<dynamic> list = json.decode(res.body);
      return list.map((item) => AppUser.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }
}

