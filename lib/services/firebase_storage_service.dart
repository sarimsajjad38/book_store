import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const Uuid _uuid = Uuid();

  /// Uploads a book cover image to Firebase Cloud Storage
  /// and returns the public HTTPS download URL.
  static Future<String> uploadBookCover(File imageFile, {String? sellerId}) async {
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

      final uploadTask = ref.putFile(imageFile, metadata);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      if (kDebugMode) {
        print('✅ Book cover uploaded successfully: $downloadUrl');
      }

      return downloadUrl;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('❌ Firebase Storage Error: ${e.code} - ${e.message}');
      }
      throw Exception('Failed to upload image: ${e.message ?? e.code}');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected Upload Error: $e');
      }
      throw Exception('Failed to upload image to Firebase Storage: $e');
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

