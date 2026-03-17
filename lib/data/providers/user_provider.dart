import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';

class UserProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Création du document utilisateur après l'inscription
  Future<void> createUserDocument({
    required String uid,
    required String email,
    required String name,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'profileImageUrl': null,
        'bio': null,
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Erreur lors de la création du compte : $e");
    }
  }

  /// Récupère un utilisateur
  Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception("Impossible de récupérer l'utilisateur : $e");
    }
  }

  //get user stream
  Stream<UserModel?> streamUser(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      return doc.exists ? UserModel.fromMap(doc.data()!) : null;
    });
  }

  /// Mise à jour du profil utilisateur
  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      data["updatedAt"] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      throw Exception("Erreur lors de la mise à jour : $e");
    }
  }

  /// Upload de la photo de profil
  Future<String> uploadProfilePhoto(String userId, File photoFile) async {
    try {
      final ref = _storage.ref().child("profile_photos/$userId.jpg");

      await ref.putFile(photoFile);

      final photoUrl = await ref.getDownloadURL();

      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return photoUrl;
    } catch (e) {
      throw Exception("Erreur upload photo : $e");
    }
  }

  /// Supprime la photo de profil
  Future<void> deleteProfilePhoto(String userId) async {
    try {
      final ref = _storage.ref().child("profile_photos/$userId.jpg");
      await ref.delete();

      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Erreur lors de la suppression de la photo : $e");
    }
  }

  /// Vérifie si un user existe
  Future<bool> userExists(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Recherche d’utilisateurs (pour créer un chat)
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final results = await _firestore
          .collection('users')
          .where("name", isGreaterThanOrEqualTo: query)
          .where("name", isLessThanOrEqualTo: "$query\uf8ff")
          //.where("uid",isNotEqualTo: currentUser?.uid)
          .get();

      return results.docs.map((d) => d.data()).toList();
    } catch (e) {
      throw Exception("Erreur recherche utilisateurs : $e");
    }
  }

 /* Stream<List<Map<String, dynamic>>> searchUsersStream(String query) {
    try {
      return _firestore
          .collection('users')
          .where("name", isGreaterThanOrEqualTo: query)
          .where("name", isLessThanOrEqualTo: "$query\uf8ff")
          .snapshots()
          .map((snapshot) {
            final users = snapshot.docs.map((d) => d.data()).toList();

            final currentUid = FirebaseAuth.instance.currentUser!.uid;
            return users.where((u) => u['uid'] != currentUid).toList();
          });
    } catch (e) {
      return Stream.error("Erreur recherche utilisateurs : $e");
    }
  }*/
  Stream<List<Map<String, dynamic>>> searchUsersStream(String query) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUid == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .where("name", isGreaterThanOrEqualTo: query)
        .where("name", isLessThanOrEqualTo: "$query\uf8ff")
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs.map((d) => d.data()).toList();
      return users.where((u) => u['uid'] != currentUid).toList();
    })
    // catch les erreurs ASYNCHRONES du stream
        .handleError((error, stackTrace) {
      debugPrint('❌ Search stream error: $error');
      debugPrint('Stack: $stackTrace');
      return <Map<String, dynamic>>[];
    });
  }

  ///get current user
  User? get currentUser => _auth.currentUser;
}
