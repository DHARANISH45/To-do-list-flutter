import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

    Stream<User?> get authStateChanges => _auth.authStateChanges();

 
  User? get currentUser => _auth.currentUser;

  
  Future<User?> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
       
        await _database.ref('users/${user.uid}').set({
          'email': email.trim(),
          'createdAt': DateTime.now().toIso8601String(),
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      developer.log('SignUp error: $e', name: 'AuthService');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  
  Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      developer.log('SignIn error: $e', name: 'AuthService');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; 
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
       
        final snapshot = await _database.ref('users/${user.uid}').get();
        if (!snapshot.exists) {
          await _database.ref('users/${user.uid}').set({
            'email': user.email ?? '',
            'createdAt': DateTime.now().toIso8601String(),
          });
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      developer.log('Google SignIn error: $e', name: 'AuthService');
      throw 'Google Sign-In failed. Please try again.';
    }
  }

  
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      developer.log('Password reset error: $e', name: 'AuthService');
      throw 'Failed to send password reset email. Please try again.';
    }
  }

  
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      developer.log('SignOut error: $e', name: 'AuthService');
      throw 'Failed to sign out. Please try again.';
    }
  }

  
  String _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'Invalid email. No user found.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        developer.log('Unhandled auth error: ${e.code} - ${e.message}',
            name: 'AuthService');
        return 'Authentication failed. Please try again.';
    }
  }
}
