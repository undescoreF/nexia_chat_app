import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../calls/controller/call_controllers.dart';

class UserController extends GetxController with WidgetsBindingObserver {
  final UserRepository _userRepository;

  var isOnline = false.obs;
  var lastSeen = DateTime.now().obs;
  var user = Rxn<UserModel>();
  RxMap<String, Rx<UserModel?>> users = <String, Rx<UserModel?>>{}.obs;

  UserController(this._userRepository);

  Future<void> setUserOnline(String uid) async {
    await _userRepository.setUserOnline(uid);
    isOnline.value = true;
    lastSeen.value = DateTime.now();
  }

  Future<String> getUsername(String uid) async {
    final user = await _userRepository.getUser(uid);
    if (user != null) {
      return user.name;
    } else {
      return "New message";
    }
  }

  Future<void> setUserOffline(String uid) async {
    await _userRepository.setUserOffline(uid);
    isOnline.value = false;
    lastSeen.value = DateTime.now();
  }

  Future<void> fetchUser(String uid) async {
    final userData = await _userRepository.getUser(uid);
    if (userData != null) {
      user.value = userData;
      isOnline.value = userData.isOnline;
      lastSeen.value = userData.lastSeen!;
    } else {
      debugPrint("je suis null");
    }
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        bindUserStream(currentUser.uid);
        setUserOnline(currentUser.uid);
      });
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setUserOffline(currentUser.uid);
    }

    super.onClose();
  }

  Future<void> loadUserInfo(String uid) async {
    try {
      final userData = await _userRepository.getUser(uid);
      if (userData != null) {
        user.value = userData;
        isOnline.value = userData.isOnline;
        lastSeen.value = userData.lastSeen!;
      } else {
        debugPrint('Utilisateur non trouvé');
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération de l\'utilisateur: $e');
    }
  }

  void bindUserStream(String uid) {
    if (!users.containsKey(uid)) {
      users[uid] = Rxn<UserModel?>();
      users[uid]!.bindStream(_userRepository.streamUser(uid));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        setUserOnline(currentUser.uid);
        final callController = Get.find<CallControllers>();
        callController.listenForIncomingCalls(
          FirebaseAuth.instance.currentUser!.uid,
        );
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        setUserOffline(currentUser.uid);
        break;

      case AppLifecycleState.detached:
        setUserOffline(currentUser.uid);
        break;
      case AppLifecycleState.hidden:
        throw UnimplementedError();
    }
  }
}
