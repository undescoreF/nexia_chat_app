import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class AppAuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Inscription avec email + mot de passe
  Future<User?> register(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user != null) {
      await saveOneSignalPlayerId(user.uid);
    }

    return cred.user;
  }

  /// Login
  Future<User?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user != null) {
      await saveOneSignalPlayerId(user.uid);
    }

    return cred.user;
  }

  ///Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Upload photo de profil
  Future<String> uploadProfilePicture(File file, String userId) async {
    final ref = _storage.ref().child('profile_pics/$userId.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  /// Current user
  User? get currentUser => _auth.currentUser;

  ///
  Future<void> saveOneSignalPlayerId(String userId) async {
    final playerId = OneSignal.User.pushSubscription.id;

    if (playerId != null) {
      final userDoc = _firestore.collection('users').doc(userId);

      await userDoc.set({
        'oneSignalPlayerIds': FieldValue.arrayUnion([playerId]),
      }, SetOptions(merge: true));
    }
  }
}
