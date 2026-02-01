// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '524411589574-ck9ftbdh83gnn3nn6ohpcik1aqdm5eel.apps.googleusercontent.com',
    scopes: ['email'],
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    if (user.email == null || !user.email!.contains('@')) {
      return false;
    }

    try {
      final doc = await _firestore.collection('admins').doc(user.email).get();

      if (!doc.exists) {
        return false;
      }

      final data = doc.data();
      if (data == null) {
        return false;
      }

      final isAdminFlag = data['isAdmin'];
      return isAdminFlag == true;
    } catch (e) {
      return false;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      if (googleUser.email.isEmpty) {
        await _googleSignIn.signOut();
        throw Exception('Invalid account.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null || googleAuth.accessToken == null) {
        await _googleSignIn.signOut();
        throw Exception('Authentication failed.');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user?.email != googleUser.email) {
        await signOut();
        throw Exception('Verification failed.');
      }

      final adminStatus = await isAdmin().timeout(
        const Duration(seconds: 10),
        onTimeout: () => false,
      );

      if (!adminStatus) {
        await signOut();
        throw Exception('Access denied.');
      }

      return userCredential;
    } catch (e) {
      try {
        await signOut();
      } catch (_) {
        // Ignore
      }
      rethrow;
    }
  }

  Future<bool> verifyAdminWithSecurityCheck() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    if (!user.emailVerified && user.providerData.isEmpty) {
      return false;
    }

    return await isAdmin();
  }

  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }
}
