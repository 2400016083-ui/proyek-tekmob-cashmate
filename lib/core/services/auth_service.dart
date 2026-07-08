import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Thin wrapper around FirebaseAuth (+ Google Sign-In). Methods let
/// [FirebaseAuthException]/[GoogleSignInException] propagate as-is so the
/// calling screen can map error codes to user-facing messages.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _googleSignInInitialized = false;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> registerWithEmail(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  /// Requires the Google OAuth client to be registered for this app in the
  /// Firebase Console (SHA-1 fingerprint) — will throw until that is done.
  Future<UserCredential> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;
    if (!_googleSignInInitialized) {
      await googleSignIn.initialize();
      _googleSignInInitialized = true;
    }

    final account = await googleSignIn.authenticate();
    final idToken = account.authentication.idToken;

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (_googleSignInInitialized) {
      await GoogleSignIn.instance.signOut();
    }
  }
}
