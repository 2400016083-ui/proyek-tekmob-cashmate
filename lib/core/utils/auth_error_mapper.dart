import 'package:firebase_auth/firebase_auth.dart';

/// Maps a [FirebaseAuthException] code to a user-facing Indonesian message.
/// Shared between Login, Register, and password reset so the wording stays
/// consistent.
String firebaseAuthErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return 'Akun dengan email tersebut tidak ditemukan';
    case 'wrong-password':
    case 'invalid-credential':
      return 'Email atau password salah';
    case 'invalid-email':
      return 'Format email tidak valid';
    case 'email-already-in-use':
      return 'Email sudah terdaftar, silakan masuk';
    case 'weak-password':
      return 'Password terlalu lemah, minimal 6 karakter';
    case 'too-many-requests':
      return 'Terlalu banyak percobaan, coba lagi nanti';
    case 'network-request-failed':
      return 'Tidak ada koneksi internet';
    case 'user-disabled':
      return 'Akun ini telah dinonaktifkan';
    default:
      return e.message ?? 'Terjadi kesalahan, silakan coba lagi';
  }
}
