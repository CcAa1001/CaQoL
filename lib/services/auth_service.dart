import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(firebaseAuthProvider));
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(firebaseAuthProvider).authStateChanges();
});

class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;
  static const _serverClientId =
      '3442674846-c4lpco0mo2qi5po0p2tb1knrg150t906.apps.googleusercontent.com';
  static Future<void>? _googleInit;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');

      final user = _auth.currentUser;
      if (user != null && user.isAnonymous) {
        try {
          return await user.linkWithPopup(provider);
        } on FirebaseAuthException catch (error) {
          if (error.code != 'credential-already-in-use' &&
              error.code != 'provider-already-linked') {
            rethrow;
          }
        }
      }
      return _auth.signInWithPopup(provider);
    }

    _googleInit ??= GoogleSignIn.instance.initialize(
      serverClientId: _serverClientId,
    );
    await _googleInit;
    final googleUser = await GoogleSignIn.instance.authenticate();
    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final user = _auth.currentUser;
    if (user != null && user.isAnonymous) {
      try {
        return await user.linkWithCredential(credential);
      } on FirebaseAuthException catch (error) {
        if (error.code != 'credential-already-in-use' &&
            error.code != 'provider-already-linked') {
          rethrow;
        }
      }
    }

    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
