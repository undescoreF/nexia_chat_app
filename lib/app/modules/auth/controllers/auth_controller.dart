import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexachat/data/providers/user_provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../../../../data/models/auth_result.dart';
import '../../../../data/providers/call_provider.dart';
import '../../../../data/repositories/call_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../utils/firebase_error_helper.dart';
import '../../calls/controller/call_controllers.dart';
import '../../chat/controller/notification_controller.dart';
import 'package:flutter/foundation.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepo = UserRepository(UserProvider());
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var isLoading = false.obs;
  User? get currentUser => _auth.currentUser;
  //String get currentUserId => _auth.currentUser!.uid;
  String get currentUserId {
    if (_auth.currentUser != null) {
      return _auth.currentUser!.uid;
    }
    return 'UNAUTHENTICATED';
  }
  // final NotificationController _notifCtrl = Get.find<NotificationController>();
  //final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthController() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        final callController = Get.find<CallControllers>();
        callController.listenForIncomingCalls(user.uid);
      } else {
        final callController = Get.find<CallControllers>();
        callController.dispose(); // à implémenter
      }
    });
  }

  /// INSCRIPTION
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      if (kDebugMode) {
        await FirebaseAuth.instance.setSettings(
          appVerificationDisabledForTesting: true,
        );
      }
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user!;
      await _userRepo.createUser(uid: user.uid, email: email, name: name);
      if (user != null) {
        await saveOneSignalPlayerId(user.uid);
      }
      try {
        await user.sendEmailVerification();
      } catch (e) {
        debugPrint("erreur$e");
      }

      return AuthResult(
        messageKey: "register_email_sent",
        type: AlertType.success,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(messageKey: e.code, type: AlertType.error);
    } finally {
      isLoading.value = false;
    }
  }

  /// CONNEXION
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      // Connexion Firebase
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user == null) {
        return AuthResult(messageKey: "error_unknown", type: AlertType.error);
      }
      if (user != null) {
        await saveOneSignalPlayerId(user.uid);
      }

      await user.reload();

      if (!user.emailVerified) {
        return AuthResult(
          messageKey: "login_email_not_verified",
          type: AlertType.info,
        );
      }

      /*   // Récupère le token FCM pour cet appareil
      final token = await _notifCtrl.provider.getToken();

      // Sauvegarde dans Firestore
      if (token != null) {
        await _firestore.collection('users').doc(currentUserId).update({
          'fcmToken': token,
        });
      }*/

      /* CallProvider callProvider = Get.put(CallProvider(),permanent: true);
      CallRepository callRepository = Get.put(CallRepository(callProvider),permanent: true);
      final callController = Get.put(
        CallControllers(CallRepository(CallProvider())),
        permanent: true,
      );

      callController.listenForIncomingCalls(currentUserId);*/

      return AuthResult(messageKey: "login_success", type: AlertType.success);
    } on FirebaseAuthException catch (e) {
      return AuthResult(messageKey: e.code, type: AlertType.error);
    } on TimeoutException {
      return AuthResult(messageKey: "timeout", type: AlertType.error);
    } catch (_) {
      return AuthResult(messageKey: "error_unknown", type: AlertType.error);
    } finally {
      isLoading.value = false;
    }
  }

  /// DÉCONNEXION
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// RÉINITIALISATION DU MOT DE PASSE
  Future<String?> sendPasswordReset({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AppLocalizations.of(context)!.reset_email_sent(email);
    } on FirebaseAuthException catch (e) {
      return firebaseErrorMessage(context, e.code);
    }
  }

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
