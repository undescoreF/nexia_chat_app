import 'dart:io';

import '../models/user_model.dart';
import '../providers/user_provider.dart';

class UserRepository {
  final UserProvider _provider;

  UserRepository(this._provider);

  /// Création du document utilisateur après inscription
  Future<UserModel> createUser({
    required String uid,
    required String email,
    required String name,
  }) async {
    await _provider.createUserDocument(uid: uid, email: email, name: name);

    final data = await _provider.getUser(uid);
    return UserModel.fromMap(data!);
  }

  /// Récupère un utilisateur
  Future<UserModel?> getUser(String uid) async {
    final data = await _provider.getUser(uid);
    if (data == null) return null;
    return UserModel.fromMap(data);
  }

  Stream<UserModel?> streamUser(String uid) {
    return _provider.streamUser(uid);
  }

  /// Upload + mise à jour photo de profil
  Future<String> uploadProfilePhoto(String uid, File file) async {
    return await _provider.uploadProfilePhoto(uid, file);
  }

  ///  Mise à jour du profil
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _provider.updateProfile(uid, data);
  }

  /// Supprime photo de profil
  Future<void> deleteProfilePhoto(String uid) async {
    await _provider.deleteProfilePhoto(uid);
  }

  /// Vérifie si un utilisateur existe
  Future<bool> userExists(String uid) async {
    return await _provider.userExists(uid);
  }

  /// Recherche des utilisateurs (utile pour démarrer un chat)
  Future<List<UserModel>> searchUsers(String query) async {
    final results = await _provider.searchUsers(query);
    return results.map((e) => UserModel.fromMap(e)).toList();
  }

  Stream<List<UserModel>> searchUsersStream(String query) {
    final resultsStream = _provider.searchUsersStream(query);
    return resultsStream.map(
      (list) => list.map((e) => UserModel.fromMap(e)).toList(),
    );
  }

  /// Indiquer que l'utilisateur est en ligne
  Future<void> setUserOnline(String uid) async {
    await _provider.updateProfile(uid, {
      'isOnline': true,
      'lastSeen': DateTime.now(),
    });
  }

  /// Indiquer qu'il est hors ligne
  Future<void> setUserOffline(String uid) async {
    await _provider.updateProfile(uid, {
      'isOnline': false,
      'lastSeen': DateTime.now(),
    });
  }
}
