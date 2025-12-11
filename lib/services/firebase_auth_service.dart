import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:falcim_benim/services/firestore_service.dart';

/// Lightweight Firebase Auth service wrapper.
///
/// Usage:
/// - Call `await FirebaseAuthService.instance.init()` once (e.g., during app startup)
/// - Use the instance methods to sign in, sign up, sign out, and observe auth state.
class FirebaseAuthService {
  FirebaseAuthService._private();

  static final FirebaseAuthService instance = FirebaseAuthService._private();

  FirebaseAuth? _auth;
  bool _initialized = false;

  /// Initialize Firebase (and FirebaseAuth instance).
  ///
  /// If you used the FlutterFire CLI to generate `firebase_options.dart`, call
  /// `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` instead.
  Future<void> init() async {
    if (_initialized) return;
    await Firebase.initializeApp();
    _auth = FirebaseAuth.instance;
    _initialized = true;
  }

  /// Stream of authentication state changes.
  Stream<User?> authStateChanges() {
    _ensureAuth();
    return _auth!.authStateChanges();
  }

  /// Currently signed-in user, or null.
  User? get currentUser {
    _ensureAuth();
    return _auth!.currentUser;
  }

  /// Create a new account with email and password.
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? gender,
    String? maritalStatus,
    int? age,
  }) async {
    // Email/password signup removed — app uses phone + OTP.
    throw UnimplementedError('Email signup is disabled. Use phone + OTP.');
  }

  /// Sign in with email and password.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // Email sign-in removed — use phone + OTP flow instead.
    throw UnimplementedError('Email sign-in is disabled. Use phone + OTP.');
  }

  /// Sign out current user.
  Future<void> signOut() async {
    _ensureAuth();
    // Also sign out from GoogleSignIn on mobile platforms.
    if (!kIsWeb) {
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
    }
    await _auth!.signOut();
  }

  /// Sign in using Google account.
  ///
  /// Supports web (popup) and mobile (GoogleSignIn flow).
  Future<UserCredential> signInWithGoogle() async {
    _ensureAuth();
    try {
      UserCredential credential;

      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        credential = await _auth!.signInWithPopup(provider);
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          throw FirebaseAuthException(
            code: 'ERROR_ABORTED_BY_USER',
            message: 'Sign in aborted by user',
          );
        }
        final googleAuth = await googleUser.authentication;
        final cred = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        credential = await _auth!.signInWithCredential(cred);
      }

      final user = credential.user;
      if (user != null) {
        final userDoc = FirestoreService.instance
            .collection('Users')
            .doc(user.uid);
        final snapshot = await userDoc.get();

        final data = {
          'email': user.email,
          'displayName': user.displayName ?? '',
          'profilePictureUrl': user.photoURL ?? '',
          'isPremium': false,
          'premiumExpiryDate': null,
          'totalReadings': 0,
          'remaningReadings': 1,
          'gender': null,
          'maritalStatus': null,
          'age': null,
        };

        if (!snapshot.exists) {
          await userDoc.set({
            ...data,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          await userDoc.set({
            'updatedAt': FieldValue.serverTimestamp(),
            ...data,
          }, SetOptions(merge: true));
        }
      }

      return credential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Send a password reset email to the provided address.
  Future<void> sendPasswordResetEmail(String email) async {
    // Password reset not supported for phone-only authentication.
    throw UnimplementedError('Password reset is disabled for phone-only auth.');
  }

  /// Ensure a Firestore user document exists for the currently signed-in user.
  /// If it doesn't exist, create a minimal profile using the provided optional fields.
  Future<void> ensureUserDocument({
    String? displayName,
    String? gender,
    String? maritalStatus,
    int? age,
  }) async {
    _ensureAuth();
    final user = _auth!.currentUser;
    if (user == null) return;
    final userDoc = FirestoreService.instance.collection('Users').doc(user.uid);
    final snapshot = await userDoc.get();

    final data = {
      'phoneNumber': user.phoneNumber ?? '',
      'displayName': displayName ?? user.displayName ?? '',
      'profilePictureUrl': user.photoURL ?? '',
      'isPremium': false,
      'premiumExpiryDate': null,
      'totalReadings': 0,
      'remaningReadings': 1,
      'gender': gender,
      'maritalStatus': maritalStatus,
      'age': age,
    };

    if (!snapshot.exists) {
      await userDoc.set({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await userDoc.set({
        'updatedAt': FieldValue.serverTimestamp(),
        ...data,
      }, SetOptions(merge: true));
    }
  }

  /// Update the display name of the current user.
  Future<void> updateDisplayName(String displayName) async {
    _ensureAuth();
    final user = _auth!.currentUser;
    if (user == null) return;
    await user.updateDisplayName(displayName);
    // force reload so currentUser reflects change
    await user.reload();
  }

  void _ensureAuth() {
    if (!_initialized || _auth == null) {
      throw StateError(
        'FirebaseAuthService is not initialized. Call FirebaseAuthService.instance.init() first.',
      );
    }
  }

  Future<String?> getIdToken() async {
    User? user = _auth!.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }
}
