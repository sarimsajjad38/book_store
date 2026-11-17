import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import '../services/mock_data_service.dart';
import '../utils/constants.dart';

class BookProvider extends ChangeNotifier {
  List<Book> _books = [];
  List<Book> _featuredBooks = [];
  List<Book> _searchResults = [];
  List<Book> _recommendations = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String? _error;
  final List<String> _viewedBookIds = [];

  List<Book> get books => _books;
  List<Book> get featuredBooks => _featuredBooks;
  List<Book> get searchResults => _searchResults;
  List<Book> get recommendations => _recommendations;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  BookProvider() {
    _books = MockDataService.getBooks();
    _featuredBooks = MockDataService.getFeaturedBooks();
    _recommendations = MockDataService.getRecommendations(_viewedBookIds);
    loadBooks();
  }

  Future<void> loadBooks() async {
    _isLoading = true;
    _error = null;

    try {
      try {
        final apiBooks = await ApiService.getBooks(
          category: _selectedCategory != 'All' ? _selectedCategory : null,
        );
        final featured = await ApiService.getBooks(featured: true);

        _books = apiBooks;
        _featuredBooks = featured.isNotEmpty
            ? featured
            : apiBooks.where((b) => b.isFeatured).toList();

        if (_books.isNotEmpty) {
          _recommendations = MockDataService.getRecommendations(_viewedBookIds);
          _isLoading = false;
          notifyListeners();
          return;
        }
      } catch (_) {
        // Fall back to MockData if backend is unreachable
      }

      if (ApiConstants.enableOfflineMockFallback) {
        _books = _selectedCategory == 'All'
            ? MockDataService.getBooks()
            : MockDataService.getBooksByCategory(_selectedCategory);
        _featuredBooks = MockDataService.getFeaturedBooks();
        _recommendations = MockDataService.getRecommendations(_viewedBookIds);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load books';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectCategory(String category) async {
    _selectedCategory = category;
    _isLoading = true;
    notifyListeners();

    try {
      try {
        final apiBooks = await ApiService.getBooks(
          category: category != 'All' ? category : null,
        );
        if (apiBooks.isNotEmpty) {
          _books = apiBooks;
          _isLoading = false;
          notifyListeners();
          return;
        }
      } catch (_) {}

      if (category == 'All') {
        _books = MockDataService.getBooks();
      } else {
        _books = MockDataService.getBooksByCategory(category);
      }
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchBooks(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    try {
      try {
        final apiResults = await ApiService.getBooks(search: query.trim());
        if (apiResults.isNotEmpty) {
          _searchResults = apiResults;
          notifyListeners();
          return;
        }
      } catch (_) {}

      _searchResults = MockDataService.searchBooks(query);
      notifyListeners();
    } catch (_) {
      _searchResults = MockDataService.searchBooks(query);
      notifyListeners();
    }
  }

  void trackBookView(String bookId) {
    if (!_viewedBookIds.contains(bookId)) {
      _viewedBookIds.add(bookId);
      _recommendations = MockDataService.getRecommendations(_viewedBookIds);
      notifyListeners();
    }
  }

  Book? getBookById(String id) {
    try {
      return _books.firstWhere((b) => b.id == id);
    } catch (_) {
      return MockDataService.getBookById(id);
    }
  }

  List<Book> getSellerBooks(String sellerId) {
    final list = _books.where((b) => b.sellerId == sellerId).toList();
    if (list.isNotEmpty) return list;
    return MockDataService.getSellerBooks(sellerId);
  }

  Future<void> addBook(Book book, [String? token]) async {
    try {
      if (token != null && token.isNotEmpty && !token.startsWith('mock_')) {
        try {
          final added = await ApiService.addBook(book, token);
          _books.insert(0, added);
          notifyListeners();
          return;
        } catch (_) {}
      }
      MockDataService.addBook(book);
      loadBooks();
    } catch (_) {
      MockDataService.addBook(book);
      loadBooks();
    }
  }

  Future<void> updateBook(Book book, [String? token]) async {
    try {
      if (token != null && token.isNotEmpty && !token.startsWith('mock_')) {
        try {
          final updated = await ApiService.updateBook(book, token);
          final idx = _books.indexWhere((b) => b.id == book.id);
          if (idx != -1) _books[idx] = updated;
          notifyListeners();
          return;
        } catch (_) {}
      }
      MockDataService.updateBook(book);
      loadBooks();
    } catch (_) {
      MockDataService.updateBook(book);
      loadBooks();
    }
  }

  Future<void> deleteBook(String id, [String? token]) async {
    try {
      if (token != null && token.isNotEmpty && !token.startsWith('mock_')) {
        try {
          await ApiService.deleteBook(id, token);
          _books.removeWhere((b) => b.id == id);
          notifyListeners();
          return;
        } catch (_) {}
      }
      MockDataService.deleteBook(id);
      loadBooks();
    } catch (_) {
      MockDataService.deleteBook(id);
      loadBooks();
    }
  }
}
