// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'dart:typed_data';

// class FirebaseStorageService {
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Future<String?> uploadFileFromBytes({
//     required Uint8List bytes,
//     required String folder,
//     required String fileName,
//     String? mimeType,
//     Function(double)? onProgress,
//   }) async {
//     // RESTORED: This is the real Firebase upload logic.
//     try {
//       final user = _auth.currentUser;
//       if (user == null) throw Exception('User not authenticated');

//       final ref = _storage.ref().child('$folder/${user.uid}_$fileName');
//       final metadata = SettableMetadata(contentType: mimeType);
//       final uploadTask = ref.putData(bytes, metadata);

//       uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
//         if (onProgress != null) {
//           final progress = snapshot.bytesTransferred / snapshot.totalBytes;
//           onProgress(progress);
//         }
//       });

//       final snapshot = await uploadTask;
//       return await snapshot.ref.getDownloadURL();
//     } catch (e) {
//       if (kDebugMode) print('Error uploading bytes: $e');
//       rethrow;
//     }
//   }

//   Future<void> deleteFile(String fileUrl) async {
//     // RESTORED: This is the real Firebase delete logic.
//     try {
//       await _storage.refFromURL(fileUrl).delete();
//     } catch (e) {
//       if (kDebugMode) print('Error deleting file: $e');
//       rethrow;
//     }
//   }
// }
