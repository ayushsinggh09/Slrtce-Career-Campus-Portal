import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupabaseStorageService {
  final _storage = Supabase.instance.client.storage;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Upload file to Supabase Storage
  /// Returns the public URL of uploaded file
  Future<String?> uploadFileFromBytes({
    required Uint8List bytes,
    required String folder,
    required String fileName,
    String? mimeType,
    Function(double)? onProgress,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create unique file path
      final filePath = '$folder/${user.uid}_$fileName';

      if (kDebugMode) {
        print('Uploading to Supabase: $filePath');
      }

      // Upload file to Supabase
      await _storage.from('student-files').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              contentType: mimeType,
              upsert: true, // Overwrite if file exists
            ),
          );

      // Get public URL
      final publicUrl = _storage.from('student-files').getPublicUrl(filePath);

      if (kDebugMode) {
        print('Upload successful! URL: $publicUrl');
      }

      return publicUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading to Supabase: $e');
      }
      rethrow;
    }
  }

  /// Delete file from Supabase Storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      // Extract file path from URL
      // URL format: https://xxx.supabase.co/storage/v1/object/public/student-files/path/to/file.pdf
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;

      // Find 'student-files' bucket and get everything after it
      final bucketIndex = pathSegments.indexOf('student-files');
      if (bucketIndex == -1) {
        throw Exception('Invalid Supabase storage URL');
      }

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      if (kDebugMode) {
        print('Deleting from Supabase: $filePath');
      }

      await _storage.from('student-files').remove([filePath]);

      if (kDebugMode) {
        print('Delete successful!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting from Supabase: $e');
      }
      rethrow;
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String filePath) async {
    try {
      final response = await _storage.from('student-files').list(
            path: filePath.split('/').first,
          );
      return response.any((file) => file.name == filePath.split('/').last);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking file existence: $e');
      }
      return false;
    }
  }

  /// Get file size
  Future<int?> getFileSize(String filePath) async {
    try {
      final response = await _storage.from('student-files').list(
            path: filePath.split('/').first,
          );
      final file = response.firstWhere(
        (file) => file.name == filePath.split('/').last,
      );
      return file.metadata?['size'] as int?;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting file size: $e');
      }
      return null;
    }
  }
}