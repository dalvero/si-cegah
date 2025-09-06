import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mendapatkan ID pengguna saat ini
  User? get currentUser => _auth.currentUser;

  // ---- Metode Pendaftaran Email/Kata Sandi ----
  Future<UserCredential?> signUpWithEmailAndPassword(
  String email,
  String password,
  String name,
  String peran, // ✅ tambahkan parameter peran
) async {
  try {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Kirim email verifikasi
    await userCredential.user?.sendEmailVerification();

    // Simpan data pengguna di Firestore
    if (userCredential.user != null) {
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'role': 'user', // tetap untuk otorisasi sistem
        'peran': peran, // ✅ simpan pilihan peran
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return userCredential;
  } on FirebaseAuthException {
    rethrow;
  }
}

  // ---- Metode Login Email/Kata Sandi ----
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // ---- Metode Login Google ----
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Simpan data pengguna Google di Firestore jika belum ada
      if (userCredential.user != null && userCredential.additionalUserInfo!.isNewUser) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'name': userCredential.user!.displayName,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // ---- Metode Logout ----
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
