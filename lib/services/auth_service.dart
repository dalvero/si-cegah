import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mendapatkan ID pengguna saat ini
  User? get currentUser => _auth.currentUser;

  // =======================
  // REGISTER EMAIL & PASSWORD
  // =======================
  Future<UserCredential?> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
    String role,  // user / admin
    String peran, // opsional tambahan (misal kategori / jurusan)
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
          'role': role,   // <- fleksibel user / admin
          'peran': peran, // <- tambahan sesuai kebutuhan
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // =======================
  // LOGIN EMAIL & PASSWORD
  // =======================
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // =======================
  // LOGIN GOOGLE
  // =======================
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Jika user baru, simpan ke Firestore dengan role default "user"
      if (userCredential.user != null &&
          userCredential.additionalUserInfo!.isNewUser) {
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'name': userCredential.user!.displayName,
          'role': 'user', // default google sign-in = user
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // =======================
  // GET USER ROLE
  // =======================
  Future<String?> getUserRole() async {
    if (currentUser == null) return null;

    final doc =
        await _firestore.collection('users').doc(currentUser!.uid).get();

    if (doc.exists) {
      return doc.data()?['role'] as String?;
    }
    return null;
  }

  // =======================
  // LOGOUT
  // =======================
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }
}
