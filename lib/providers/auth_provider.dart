import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _firebaseUser;
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  String? _verificationId;

  User? get firebaseUser => _firebaseUser;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _firebaseUser != null;

  AuthProvider() {
    _authService.authStateChanges.listen((user) {
      _firebaseUser = user;
      if (user != null) {
        _loadUserData();
      } else {
        _user = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData() async {
    _user = await _authService.getCurrentUserData();
    notifyListeners();
  }

  Future<void> sendOTP(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.sendOTP(
        phoneNumber: phoneNumber,
        onVerificationCompleted: (credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        onVerificationFailed: (e) {
          _error = e.message;
          _isLoading = false;
          notifyListeners();
        },
        onCodeSent: (verificationId, resendToken) {
          _verificationId = verificationId;
          _isLoading = false;
          notifyListeners();
        },
        onCodeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOTP(String smsCode) async {
    if (_verificationId == null) {
      _error = 'Veuillez d\'abord demander un code OTP';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = await _authService.verifyOTP(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      
      await _authService.createOrUpdateUser(credential.user!);
      await _loadUserData();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Code invalide. Veuillez réessayer.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? address,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.updateProfile(
        name: name,
        email: email,
        address: address,
      );
      await _loadUserData();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Inscription avec email/password
  Future<bool> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
      );
      await _loadUserData();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Connexion avec email/password
  Future<bool> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );
      await _loadUserData();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Réinitialiser le mot de passe
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'weak-password':
          return 'Le mot de passe est trop faible';
        case 'email-already-in-use':
          return 'Cet email est déjà utilisé';
        case 'user-not-found':
          return 'Aucun utilisateur trouvé avec cet email';
        case 'wrong-password':
          return 'Mot de passe incorrect';
        case 'invalid-email':
          return 'Email invalide';
        case 'too-many-requests':
          return 'Trop de tentatives. Veuillez réessayer plus tard';
        default:
          return error.message ?? 'Une erreur est survenue';
      }
    }
    return error.toString();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _verificationId = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
