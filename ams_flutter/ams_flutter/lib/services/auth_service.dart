// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart' as app_user;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Login with email and password
  Future<app_user.User?> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = result.user;
      if (firebaseUser == null) {
        throw Exception('User not found');
      }

      return await getUserData(firebaseUser.uid);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    }
  }

  // Login with Google
  Future<app_user.User> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result =
          await _auth.signInWithCredential(credential);

      final User? firebaseUser = result.user;
      if (firebaseUser == null) {
        throw Exception('Failed to sign in with Google');
      }

      // Check if user already exists in Firestore
      final userDoc = await _db.collection('users').doc(firebaseUser.uid).get();
      if (!userDoc.exists) {
        // Create new user profile
        final app_user.User newUser = app_user.User(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'User',
          role: app_user.UserRole.teacher,
        );
        await _db.collection('users').doc(newUser.uid).set(newUser.toJson());
        return newUser;
      }

      final data = userDoc.data();
      if (data == null || data is! Map<String, dynamic>) {
        throw Exception(
            'Invalid user data format: expected Map<String, dynamic>, got ${data.runtimeType}');
      }
      return app_user.User.fromJson(data);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } catch (e) {
      throw e.toString().replaceFirst('Exception: ', '');
    }
  }

  // Login Anonymously
  Future<app_user.User> signInAnonymously() async {
    try {
      final UserCredential result = await _auth.signInAnonymously();

      final User? firebaseUser = result.user;
      if (firebaseUser == null) {
        throw Exception('Failed to sign in anonymously');
      }

      // Check if user already exists in Firestore
      final userDoc = await _db.collection('users').doc(firebaseUser.uid).get();
      if (!userDoc.exists) {
        // Create new anonymous user profile
        final app_user.User newUser = app_user.User(
          uid: firebaseUser.uid,
          email: '',
          name: 'Guest User',
          role: app_user.UserRole.student,
          isAnonymous: true,
        );
        await _db.collection('users').doc(newUser.uid).set(newUser.toJson());
        return newUser;
      }

      final data = userDoc.data();
      if (data == null || data is! Map<String, dynamic>) {
        throw Exception(
            'Invalid user data format: expected Map<String, dynamic>, got ${data.runtimeType}');
      }
      return app_user.User.fromJson(data);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } catch (e) {
      throw e.toString().replaceFirst('Exception: ', '');
    }
  }

  // Register new user
  Future<app_user.User> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    app_user.UserRole role = app_user.UserRole.teacher,
    String? department,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = result.user;
      if (firebaseUser == null) {
        throw Exception('Failed to create user');
      }

      final app_user.User user = app_user.User(
        uid: firebaseUser.uid,
        email: email,
        name: name,
        role: role,
        department: department,
      );

      // Save user data to Firestore
      await _db.collection('users').doc(user.uid).set(user.toJson());

      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signOut();
    }
  }

  Stream<app_user.User?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((User? user) async {
      if (user == null) return null;
      return await getUserData(user.uid);
    });
  }

// Get user data from Firestore
  Future<app_user.User?> getUserData(String uid) async {
    try {
      final DocumentSnapshot doc = await _db.collection('users').doc(uid).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data();
      if (data == null || data is! Map<String, dynamic>) {
        return null;
      }

      return app_user.User.fromJson(data);
    } catch (e) {
      print('getUserData error for $uid: $e');
      return null;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    }
  }

  // Map Firebase errors to user friendly messages
  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-password':
      case 'login-attempts-exceeded':
        return 'Invalid email or password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      case 'weak-password':
        return 'Password should be at least 6 characters';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'credential-already-in-use':
        return 'This credential is already associated with another account';
      case 'expired-action-code':
        return 'This action link has expired';
      case 'invalid-action-code':
        return 'This action link is invalid';
      default:
        return 'Login failed. Please check your credentials and try again.';
    }
  }
}
