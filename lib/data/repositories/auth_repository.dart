import 'dart:io';
import '../providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final AppAuthProvider _provider;

  AuthRepository(this._provider);

  Future<User?> register(String email, String password) async {
    try {
      return await _provider.register(email, password);
    } catch (e) {
      throw Exception("Erreur inscription : ${e.toString()}");
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      return await _provider.login(email, password);
    } catch (e) {
      throw Exception("Erreur login : ${e.toString()}");
    }
  }

  Future<void> logout() async => await _provider.logout();

  Future<String> uploadProfilePicture(File file, String userId) async {
    return await _provider.uploadProfilePicture(file, userId);
  }

  User? get currentUser => _provider.currentUser;
}
