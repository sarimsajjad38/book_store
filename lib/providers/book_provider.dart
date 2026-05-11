import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/mock_data_service.dart';

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
    loadBooks();
  }

  Future<void> loadBooks() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _books = MockDataService.getBooks();
      _featuredBooks = MockDataService.getFeaturedBooks();
      _recommendations = MockDataService.getRecommendations(_viewedBookIds);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load books';
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    if (category == 'All') {
      _books = MockDataService.getBooks();
    } else {
      _books = MockDataService.getBooksByCategory(category);
    }
    notifyListeners();
  }

  void searchBooks(String query) {
    if (query.isEmpty) {
      _searchResults = [];
    } else {
      _searchResults = MockDataService.searchBooks(query);
    }
    notifyListeners();
  }

  void trackBookView(String bookId) {
    if (!_viewedBookIds.contains(bookId)) {
      _viewedBookIds.add(bookId);
      _recommendations = MockDataService.getRecommendations(_viewedBookIds);
      notifyListeners();
    }
  }

  Book? getBookById(String id) {
    return MockDataService.getBookById(id);
  }

  List<Book> getSellerBooks(String sellerId) {
    return MockDataService.getSellerBooks(sellerId);
  }

  void addBook(Book book) {
    MockDataService.addBook(book);
    loadBooks();
  }

  void updateBook(Book book) {
    MockDataService.updateBook(book);
    loadBooks();
  }

  void deleteBook(String id) {
    MockDataService.deleteBook(id);
    loadBooks();
  }
}
