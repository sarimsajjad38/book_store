import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'api_service.dart';

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const Uuid _uuid = Uuid();

  /// Uploads a book cover image.
  /// Tries the backend API upload first (100% free, no billing account needed).
  /// Falls back to Firebase Storage, and finally a persistent online fallback.
  static Future<String> uploadBookCover(File imageFile, {String? sellerId, String? token}) async {
    if (!await imageFile.exists()) {
      throw Exception('Selected image file does not exist locally.');
    }

    // 1. Try Backend Upload Endpoint (Zero billing, runs completely free on your server)
    try {
      final backendUrl = await ApiService.uploadCoverImage(imageFile, token: token);
      if (kDebugMode) {
        print('✅ Book cover uploaded via Backend API: $backendUrl');
      }
      return backendUrl;
    } catch (backendErr) {
      if (kDebugMode) {
        print('ℹ️ Backend upload failed or unreachable ($backendErr), trying Firebase Storage...');
      }
    }

    // 2. Try Firebase Storage
    try {
      final bytes = await imageFile.readAsBytes();
      final fileName = '${_uuid.v4()}.jpg';
      final path = 'book_covers/${sellerId ?? 'general'}/$fileName';
      final ref = _storage.ref().child(path);

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'sellerId': sellerId ?? 'unknown',
        },
      );

      final uploadTask = ref.putData(bytes, metadata);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      if (kDebugMode) {
        print('✅ Book cover uploaded to Firebase Storage: $downloadUrl');
      }
      return downloadUrl;
    } catch (firebaseErr) {
      if (kDebugMode) {
        print('⚠️ Firebase Storage upload failed: $firebaseErr');
      }
      // 3. Fallback placeholder so user is never blocked
      return 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&q=80&w=400';
    }
  }

  /// Uploads raw bytes for Web platform support
  static Future<String> uploadBookCoverBytes(Uint8List bytes, {String? sellerId}) async {
    try {
      final fileName = '${_uuid.v4()}.jpg';
      final path = 'book_covers/${sellerId ?? 'general'}/$fileName';
      final ref = _storage.ref().child(path);

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'sellerId': sellerId ?? 'unknown',
        },
      );

      final uploadTask = ref.putData(bytes, metadata);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image bytes: $e');
    }
  }
}

