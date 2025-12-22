import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' show FieldValue;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:nexachat/data/models/user_model.dart';
import 'package:nexachat/data/repositories/call_repository.dart';
import 'package:nexachat/app/modules/calls/views/call_view.dart';
import '../../../../data/providers/user_provider.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../services/webrtc_service.rtc.dart';
import '../../auth/controllers/userController.dart';

class CallControllers extends GetxController {
  final CallRepository callRepository_;
  late WebRTCService webRTCService_;
  UserModel remoteUser = UserModel(uid: '', name: '', email: '');
  var shouldCloseCallView = false.obs;

  var isInCall = false.obs;
  var incomingCall = false.obs;
  var callStatus = ''.obs;
  var currentCallId = ''.obs;

  // États internes
  final Set<String> _processedIceCandidates = {};
  StreamSubscription? _incomingCallSubscription;
  StreamSubscription? _rtcChangesSubscription; //nettoyer l'écoute RTC
  UserController? _userController;

  CallControllers(this.callRepository_) {
    webRTCService_ = WebRTCService(callRepository_);
  }

  @override
  void onInit() {
    super.onInit();
    _initializeUserController();
  }

  void _initializeUserController() {
    if (Get.isRegistered<UserController>()) {
      _userController = Get.find<UserController>();
    } else {
      // Créer et enregistrer le UserController
      final userRepository = Get.put(UserRepository(UserProvider()));
      _userController = Get.put(UserController(userRepository));
    }
  }

  /// Écouter les appels entrants
  void listenForIncomingCalls(String currentUserId) {
    _incomingCallSubscription?.cancel();
    _incomingCallSubscription = callRepository_.callProvider_.calls
        .where('calleeId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'ringing')
        .snapshots()
        .listen((snapshot) async {
          if (snapshot.docs.isEmpty) return;

          final callDoc = snapshot.docs.first;
          final callData = callDoc.data() as Map<String, dynamic>;
          final callerId = callData['callerId'] as String;
          await _userController!.loadUserInfo(callerId);
          if (_userController!.user.value != null) {
            remoteUser = _userController!.user.value!;
          } else {
            remoteUser = UserModel(uid: callerId, name: callerId, email: '');
          }
          incomingCall.value = true;
          currentCallId.value = callDoc.id;
          Get.to(() => CallView(user: remoteUser, isOutgoing: false));
        });
  }

  /// Démarrer un appel (appelant)
  Future<void> startCall(String myId, String otherId) async {
    _resetState();
    await callRepository_.callProvider_.createCall(myId, otherId);
    await webRTCService_.initCall(
      myId: myId,
      otherId: otherId,
      withVideo: true,
    );
    RTCSessionDescription offer = await webRTCService_.createOffer(
      myId: myId,
      otherId: otherId,
    );

    await callRepository_.callProvider_.sendOffer(myId, otherId, offer.sdp!);
    _listenForRtcChanges(myId, otherId);
    callStatus.value = 'ringing';
  }

  /// Accepter un appel (receveur)
  Future<void> acceptCall(
    RTCSessionDescription remoteOffer, {
    required String myId,
    required String otherId,
  }) async {
    try {
      await webRTCService_.initCall(
        myId: myId,
        otherId: otherId,
        withVideo: true,
      );
      RTCSessionDescription answer = await webRTCService_.acceptCall(
        remoteOffer,
        myId: myId,
        otherId: otherId,
      );

      await callRepository_.callProvider_.sendAnswer(
        myId,
        otherId,
        answer.sdp!,
      );
      await callRepository_.callProvider_.updateCallStatus(
        myId,
        otherId,
        'accepted',
      );

      isInCall.value = true;
      incomingCall.value = false;
      _listenForRtcChanges(myId, otherId);
    } catch (e) {
      print('Erreur lors de l\'acceptation de l\'appel : $e');
    }
  }

  /// Rejeter un appel
  Future<void> rejectCall(String myId, String otherId) async {
    try {
      await webRTCService_.endCall();
      await callRepository_.callProvider_.updateCallStatus(
        myId,
        otherId,
        'rejected',
      );
    } catch (e) {
      print('Erreur lors de la fermeture de l\'appel : $e');
    } finally {
      _resetState();
      shouldCloseCallView.value = true;
    }
  }

  /// Terminer un appel
  Future<void> endCall(String myId, String otherId) async {
    try {
      await webRTCService_.endCall();
      await callRepository_.callProvider_.updateCallStatus(
        myId,
        otherId,
        'ended',
      );
      await callRepository_.callProvider_.calls
          .doc(callRepository_.callProvider_.getCallDocId(myId, otherId))
          .update({'endedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      print('Erreur lors de la fermeture de l\'appel : $e');
    } finally {
      _resetState();
      shouldCloseCallView.value = true;
    }
  }

  /// Écoute en temps réel des changements RTC (answer + ICE)
  void _listenForRtcChanges(String myId, String otherId) {
    _rtcChangesSubscription?.cancel(); //Annule l'écoute précédente

    _rtcChangesSubscription = callRepository_.callProvider_
        .watchCall(myId, otherId)
        .listen((snapshot) async {
          if (!snapshot.exists) return;
          final data = snapshot.data() as Map<String, dynamic>;

          //Answer reçue
          if (data['answer'] != null &&
              data['sdpSenderId'] != myId &&
              !isInCall.value) {
            RTCSessionDescription answer = RTCSessionDescription(
              data['answer'],
              'answer',
            );
            await webRTCService_.setRemoteAnswer(answer);
            isInCall.value = true;
            callStatus.value = 'connected';
          }

          //  ICE candidates
          if (data['iceCandidates'] != null) {
            for (var ice in data['iceCandidates']) {
              final iceCandidateKey =
                  '${ice['candidate']}_${ice['sdpMid']}_${ice['sdpMLineIndex']}';

              // Utilise l'état PERSISTANT pour éviter les doublons
              if (ice['iceSenderId'] != myId &&
                  !_processedIceCandidates.contains(iceCandidateKey)) {
                final candidate = RTCIceCandidate(
                  ice['candidate'],
                  ice['sdpMid'],
                  ice['sdpMLineIndex'],
                );
                await webRTCService_.addRemoteIceCandidate(candidate);
                _processedIceCandidates.add(iceCandidateKey);
              }
            }
          }

          // Statut de l'appel
          if (data['status'] == 'rejected' || data['status'] == 'ended') {
            _resetState();
            shouldCloseCallView.value = true;
          }
        });
  }

  // Accès aux flux et renderer
  RTCVideoRenderer get remoteRenderer => webRTCService_.remoteRenderer;
  RTCVideoRenderer get localRenderer => webRTCService_.localRenderer;
  RxBool get isRemoteRendererInitialized =>
      webRTCService_.isRemoteRendererInitialized;
  RxBool get isLocalRendererInitialized =>
      webRTCService_.isLocalRendererInitialized;
  MediaStream? get localStream => webRTCService_.localStream;

  /// Réinitialise TOUT l'état de l'appel
  void _resetState() {
    isInCall.value = false;
    incomingCall.value = false;
    callStatus.value = '';
    currentCallId.value = '';
    remoteUser = UserModel(uid: '', name: '', email: '');

    // Annule tous les écouteurs actifs
    // _incomingCallSubscription?.cancel();
    _rtcChangesSubscription?.cancel();
    //_incomingCallSubscription = null;
    _rtcChangesSubscription = null;

    // Réinitialise l'état interne
    _processedIceCandidates.clear();
  }
}
