// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '524411589574-ck9ftbdh83gnn3nn6ohpcik1aqdm5eel.apps.googleusercontent.com',
    scopes: ['openid', 'email', 'profile'],
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
    final email = user.email!;
    var adminsPermissionDenied = false;

    try {
      final doc = await _firestore.collection('admins').doc(email).get();

      if (doc.exists) {
        final data = doc.data();
        if (data == null) {
          return false;
        }

        final isAdminFlag = data['isAdmin'];
        return isAdminFlag == true;
      }
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        adminsPermissionDenied = true;
      } else {
        return false;
      }
    } catch (_) {
      return false;
    }

    try {
      final configDoc = await _firestore
          .collection('admin')
          .doc('config')
          .get();
      if (!configDoc.exists) {
        return false;
      }

      final data = configDoc.data() ?? {};
      final adminsList = data['admins'] ?? data['adminEmails'];
      if (adminsList is List) {
        return adminsList.contains(email);
      }
      final singleAdmin = data['admin'];
      if (singleAdmin is String) {
        return singleAdmin == email;
      }
      return false;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        if (adminsPermissionDenied) {
          throw Exception(
            'Admin check blocked by Firestore rules. Allow read for admins/{email} or admin/config.',
          );
        }
        throw Exception(
          'Admin check blocked by Firestore rules. Allow read for admin/config.',
        );
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..addScope('openid')
          ..addScope('email')
          ..addScope('profile');
        final userCredential = await _auth.signInWithPopup(provider);

        if (userCredential.user == null) {
          throw Exception('No user returned from Firebase.');
        }

        if (userCredential.user?.email == null) {
          throw Exception('User email is null.');
        }

        final adminStatus = await isAdmin().timeout(
          const Duration(seconds: 10),
          onTimeout: () => false,
        );

        if (!adminStatus) {
          throw Exception('Access denied.');
        }

        return userCredential;
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      if (googleUser.email.isEmpty) {
        throw Exception('Invalid account: No email.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null && googleAuth.accessToken == null) {
        throw Exception('No authentication tokens received.');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      if (credential.idToken == null && credential.accessToken == null) {
        throw Exception('Invalid credential: Both tokens are null.');
      }

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('No user returned from Firebase.');
      }

      if (userCredential.user?.email == null) {
        throw Exception('User email is null.');
      }

      final adminStatus = await isAdmin().timeout(
        const Duration(seconds: 10),
        onTimeout: () => false,
      );

      if (!adminStatus) {
        throw Exception('Access denied.');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      final errorMsg = '${e.code}: ${e.message ?? "No message"}';
      if (e.code == 'account-exists-with-different-credential') {
        throw Exception('Account exists: $errorMsg');
      } else if (e.code == 'invalid-credential') {
        throw Exception('Invalid credential: $errorMsg');
      } else if (e.code == 'operation-not-allowed') {
        throw Exception('Not allowed: $errorMsg');
      } else if (e.code == 'user-disabled') {
        throw Exception('User disabled: $errorMsg');
      } else {
        throw Exception('Auth error: $errorMsg');
      }
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('Exception: ')) {
        rethrow;
      }
      throw Exception('Error: $errorStr');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {}
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}
