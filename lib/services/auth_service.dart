import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../config/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Envoi OTP
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onVerificationCompleted,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String, int?) onCodeSent,
    required Function(String) onCodeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: (e) {
        // Log détaillé pour comprendre les échecs reCAPTCHA / SMS
        debugPrint('verifyPhoneNumber error: ${e.code} - ${e.message}');
        onVerificationFailed(e);
      },
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

  // Vérifier OTP
  Future<UserCredential> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  // Créer ou mettre à jour l'utilisateur dans Firestore
  Future<void> createOrUpdateUser(User user) async {
    final userDoc = _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid);
    
    final docSnapshot = await userDoc.get();
    
    if (!docSnapshot.exists) {
      await userDoc.set({
        'phoneNumber': user.phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Obtenir l'utilisateur actuel depuis Firestore
  Future<UserModel?> getCurrentUserData() async {
    if (currentUser == null) return null;
    
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(currentUser!.uid)
        .get();
    
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  // Mettre à jour le profil
  Future<void> updateProfile({
    String? name,
    String? email,
    String? address,
    String? photoUrl,
  }) async {
    if (currentUser == null) return;
    
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;
    if (address != null) updates['address'] = address;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(currentUser!.uid)
        .update(updates);
  }

  // Inscription avec email/password
  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    if (userCredential.user != null) {
      await createOrUpdateUser(userCredential.user!);
    }
    
    return userCredential;
  }

  // Connexion avec email/password
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
