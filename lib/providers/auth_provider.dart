import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/mock_data_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;
  UserRole? get role => _user?.role;
  String? get token => _user?.token;

  AuthProvider() {
    _loadStoredUser();
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  void _syncFcmToken(String? token) {
    final fcmToken = NotificationService.fcmToken;
    if (fcmToken != null && token != null && token.isNotEmpty) {
      ApiService.updateFcmToken(fcmToken, token: token);
    }
  }

  Future<void> _loadStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      if (userData != null) {
        _user = AppUser.fromJson(json.decode(userData));
        _syncFcmToken(_user?.token);
        notifyListeners();
      }
    } catch (_) {
      // Ignore stored data errors
    }
  }

  Future<void> _saveUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(user.toJson()));
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First attempt real API call
      try {
        final apiUser = await ApiService.login(email, password);
        _user = apiUser;
        await _saveUser(apiUser);
        _syncFcmToken(apiUser.token);
        _isLoading = false;
        notifyListeners();
        return true;
      } catch (apiErr) {
        // If API fails with specific auth message (e.g. invalid credentials)
        final errMsg = apiErr.toString();
        if (errMsg.contains('Invalid email or password') ||
            errMsg.contains('User not found')) {
          _error = 'Invalid email or password';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // If backend server is unreachable and fallback is enabled:
        if (ApiConstants.enableOfflineMockFallback) {
          final mockUser = MockDataService.authenticateUser(email, password);
          if (mockUser != null) {
            _user = mockUser;
            await _saveUser(mockUser);
            _isLoading = false;
            notifyListeners();
            return true;
          }
        }
        rethrow;
      }
    } catch (e) {
      _error = 'Invalid email or password. Please verify credentials.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(
    String name,
    String email,
    String password, {
    UserRole role = UserRole.customer,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (name.trim().isEmpty) {
        _error = 'Please enter your name';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!_isValidEmail(email)) {
        _error = 'Please enter a valid email';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _error = 'Password must be at least 6 characters';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Try real API first
      try {
        final apiUser = await ApiService.signup(
          name,
          email,
          password,
          role: role.name,
        );
        _user = apiUser;
        await _saveUser(apiUser);
        _syncFcmToken(apiUser.token);
        _isLoading = false;
        notifyListeners();
        return true;
      } catch (apiErr) {
        final errMsg = apiErr.toString();
        if (errMsg.contains('already registered') || errMsg.contains('exists')) {
          _error = 'Email is already registered';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // If offline fallback enabled
        if (ApiConstants.enableOfflineMockFallback) {
          final mockUser = MockDataService.registerUser(
            name,
            email,
            password,
            role: role,
          );
          if (mockUser != null) {
            _user = mockUser;
            await _saveUser(mockUser);
            _isLoading = false;
            notifyListeners();
            return true;
          } else {
            _error = 'Email already exists';
            _isLoading = false;
            notifyListeners();
            return false;
          }
        }
        rethrow;
      }
    } catch (e) {
      _error = 'Sign up failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle({UserRole role = UserRole.customer}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      try {
        final apiUser = await ApiService.googleSignIn(
          email: account.email,
          name: account.displayName,
          avatarUrl: account.photoUrl,
        );
        _user = apiUser;
        await _saveUser(apiUser);
        _syncFcmToken(apiUser.token);
        _isLoading = false;
        notifyListeners();
        return true;
      } catch (apiErr) {
        // Fallback for offline/local environment
        final googleUser = AppUser(
          id: 'google_${account.id}',
          name: account.displayName ?? 'Google User',
          email: account.email,
          role: role,
          avatarUrl: account.photoUrl,
          token: 'google_token_${DateTime.now().millisecondsSinceEpoch}',
          createdAt: DateTime.now(),
        );
        _user = googleUser;
        await _saveUser(googleUser);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Google Sign-In failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? password,
  }) async {
    if (_user == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      if (_user?.token != null && !_user!.token!.startsWith('mock_')) {
        try {
          final updated = await ApiService.updateProfile(
            _user!.token!,
            name: name,
            phone: phone,
            address: address,
            password: password,
          );
          _user = updated.copyWith(token: _user!.token);
          await _saveUser(_user!);
          _isLoading = false;
          notifyListeners();
          return true;
        } catch (_) {}
      }

      // Local / mock fallback update
      _user = _user!.copyWith(
        name: name ?? _user!.name,
        phone: phone ?? _user!.phone,
        address: address ?? _user!.address,
      );
      await _saveUser(_user!);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to update profile';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_user?.token != null && _user!.token!.isNotEmpty) {
        try {
          await ApiService.deleteAccount(_user!.token!);
        } catch (_) {
          // If server call fails, proceed to clean up locally
        }
      }

      _user = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to delete account';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (_) {}
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
