import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isPasswordHidden = true;
  bool _isRememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isPasswordHidden => _isPasswordHidden;
  bool get isRememberMe => _isRememberMe;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => _auth.currentUser != null;

  AuthProvider() {
    _auth.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  void togglePasswordVisibility() {
    _isPasswordHidden = !_isPasswordHidden;
    notifyListeners();
  }

  void toggleRememberMe(bool value) {
    _isRememberMe = value;
    notifyListeners();
  }

  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_authErrorMessage(e));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  Future<bool> createUserWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_authErrorMessage(e));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  Future<bool> signInAnonymously() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _auth.signInAnonymously();
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_authErrorMessage(e));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _setLoading(false);
    } on FirebaseAuthException catch (e) {
      _setError(_authErrorMessage(e));
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _auth.signOut();
      _setLoading(false);
    } catch (e) {
      _setError('Sign out failed. Please try again.');
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
