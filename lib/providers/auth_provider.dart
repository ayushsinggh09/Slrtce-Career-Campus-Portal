import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SharedPreferences _prefs;

  User? _currentUser;
  Map<String, dynamic>? _userData;

  AuthProvider(this._prefs) {
    _initializeAuth();
  }

  bool get isAuthenticated => _currentUser != null;
  User? get currentUser => _currentUser;
  String? get currentUserId => _currentUser?.uid;
  String? get currentUserEmail => _currentUser?.email;
  String? get currentUserName => _userData?['name'];

  void _initializeAuth() {
    _auth.authStateChanges().listen((User? user) async {
      _currentUser = user;
      if (user != null) {
        await _loadUserData();
      } else {
        _userData = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData() async {
    if (_currentUser == null) return;
    try {
      final doc =
          await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (doc.exists) {
        _userData = doc.data();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user data: $e');
      }
    }
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        return AuthResult(success: false, message: 'All fields are required');
      }
      if (password.length < 6) {
        return AuthResult(
            success: false, message: 'Password must be at least 6 characters');
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await _firestore.collection('students').doc(credential.user!.uid).set({
          'name': name,
          'email': email,
          'phone': '',
          'branch': '',
          'batchYear': '',
          'rollNumber': '',
          'profilePicturePath': null,
          'tenthPercentage': null,
          'twelfthPercentage': null,
          'diplomaPercentage': null,
          'semesterGPAs': List.filled(8, null),
          'skills': [],
          'resumePath': null,
          'certificatePaths': [],
          'appliedJobIds': [],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await credential.user!.updateDisplayName(name);
        await credential.user!.sendEmailVerification();
        _currentUser = credential.user;
        await _loadUserData();
        return AuthResult(
            success: true,
            message: 'Registration successful! Please verify your email.');
      }
      return AuthResult(
          success: false, message: 'Registration failed. Please try again.');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          message = 'The email address is invalid.';
          break;
        default:
          message = e.message ?? 'Registration failed. Please try again.';
      }
      return AuthResult(success: false, message: message);
    } catch (e) {
      return AuthResult(
          success: false, message: 'Registration failed: ${e.toString()}');
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return AuthResult(
            success: false, message: 'Email and password are required');
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _currentUser = credential.user;
      await _loadUserData();

      if (_currentUser != null && !_currentUser!.emailVerified) {
        return AuthResult(
            success: true,
            message:
                'Login successful! Please verify your email. aslo try to check Spam section in email section!');
      }
      return AuthResult(success: true, message: 'Login successful!');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        default:
          message = e.message ?? 'Login failed. Please try again.';
      }
      return AuthResult(success: false, message: message);
    } catch (e) {
      return AuthResult(
          success: false, message: 'Login failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      _userData = null;
      await _prefs.clear();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error during logout: $e');
      }
      rethrow;
    }
  }

  Future<AuthResult> deleteAccount() async {
    try {
      if (_currentUser == null) {
        return AuthResult(success: false, message: 'No user logged in');
      }
      //step 1 to delete any student Delete user documents first
      await _firestore.collection('users').doc(_currentUser!.uid).delete();
      await _firestore.collection('students').doc(_currentUser!.uid).delete();
      //step 2 to delete the auth user
      await _currentUser!.delete();
      _currentUser = null;
      _userData = null;
      await _prefs.clear();
      notifyListeners();
      return AuthResult(success: true, message: 'Account deleted successfully');
    } on FirebaseAuthException catch (e) {
      return AuthResult(
          success: false, message: e.message ?? 'Failed to delete');
    } catch (e) {
      return AuthResult(
          success: false, message: 'Failed to delete: ${e.toString()}');
    }
  }

  Future<bool> checkEmailVerified() async {
    await _currentUser?.reload();
    _currentUser = _auth.currentUser;
    return _currentUser?.emailVerified ?? false;
  }
}

class AuthResult {
  final bool success;
  final String message;
  AuthResult({required this.success, required this.message});
}
