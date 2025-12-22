import 'package:get/get.dart' hide navigator;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/providers/signalingProvider.dart';
import '../../../../data/repositories/web_rtc_repository.dart';

enum CallState {
  idle, // Aucun appel
  connecting, // Connexion en cours
  waiting, // En attente de réponse
  connected, // Appel établi
  error, // Erreur
  ended, // Appel terminé
}

class CallController extends GetxController {
  final WebRTCRepository _webrtcRepo;
  final SignalingProvider _signalingProvider;

  var callState = CallState.idle.obs;
  var localStream = Rxn<MediaStream>();
  var remoteStream = Rxn<MediaStream>();
  String? currentRoomId;
  var isMuted = false.obs;
  var isVideoOn = true.obs;

  void toggleMuteP() => isMuted.value = !isMuted.value;
  void toggleVideoP() => isVideoOn.value = !isVideoOn.value;

  late RTCVideoRenderer localRenderer;
  late RTCVideoRenderer remoteRenderer;

  CallController(this._webrtcRepo, this._signalingProvider);

  @override
  void onInit() {
    super.onInit();
    _initializeRenderers();
  }

  @override
  void onClose() {
    localRenderer.dispose();
    remoteRenderer.dispose();
    super.onClose();
  }

  Future<void> _initializeRenderers() async {
    localRenderer = RTCVideoRenderer();
    remoteRenderer = RTCVideoRenderer();

    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  /// DÉMARRER un appel (créer une salle)
  Future<void> startCall(String targetUserId) async {
    try {
      callState.value = CallState.connecting;

      // Créer un ID de salle unique
      currentRoomId =
          'call_${targetUserId}_${DateTime.now().millisecondsSinceEpoch}';

      //caméra locale
      await _initializeLocalStream();

      // Initialiser l'appel
      final result = await _webrtcRepo.createCall(currentRoomId!);

      if (result['success']) {
        callState.value = CallState.waiting;
        _listenForAnswer(); // Écouter la réponse
      }
    } catch (e) {
      callState.value = CallState.error;
      Get.snackbar('Erreur', 'Impossible de démarrer l\'appel: $e');
    }
  }

  /// REJOINDRE un appel existant
  Future<void> joinCall(String roomId) async {
    try {
      callState.value = CallState.connecting;
      currentRoomId = roomId;

      await _initializeLocalStream();

      _signalingProvider.listenToCall(roomId).listen((
        DocumentSnapshot snapshot,
      ) async {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>?;
          if (data != null && data['offer'] != null) {
            final offer = data['offer'] as Map<String, dynamic>;
            final result = await _webrtcRepo.joinCall(roomId, offer);

            if (result['success']) {
              callState.value = CallState.connected;

              if (result['remoteStream'] != null) {
                remoteStream.value = result['remoteStream'];
                remoteRenderer.srcObject = remoteStream.value;
              }
            }
          }
        }
      });
    } catch (e) {
      callState.value = CallState.error;
      Get.snackbar('Erreur', 'Impossible de rejoindre l\'appel: $e');
    }
  }

  Future<void> _initializeLocalStream() async {
    try {
      final Map<String, dynamic> mediaConstraints = {
        'audio': true,
        'video': {'facingMode': 'user', 'width': 640, 'height': 480},
      };

      localStream.value = await navigator.mediaDevices.getUserMedia(
        mediaConstraints,
      );
      localRenderer.srcObject = localStream.value;
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'accéder à la caméra: $e');
    }
  }

  void _listenForAnswer() {
    _signalingProvider.listenToCall(currentRoomId!).listen((
      DocumentSnapshot snapshot,
    ) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        if (data != null && data['answer'] != null) {
          callState.value = CallState.connected;
        }
      }
    });
  }

  /// RACCROCHER
  Future<void> endCall() async {
    callState.value = CallState.ended;
    currentRoomId = null;

    // Libérer les ressources
    localStream.value?.getTracks().forEach((track) => track.stop());
    remoteStream.value?.getTracks().forEach((track) => track.stop());
    localStream.value = null;
    remoteStream.value = null;

    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
  }

  /// ACTIVER/DÉSACTIVER le microphone
  Future<void> toggleMute() async {
    final stream = localStream.value;
    if (stream != null) {
      final audioTracks = stream.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        final audioTrack = audioTracks.first;
        audioTrack.enabled = !audioTrack.enabled;

        Get.snackbar(
          'Micro',
          audioTrack.enabled ? 'Activé' : 'Désactivé',
          duration: const Duration(seconds: 1),
        );
        update();
      }
    }
  }

  Future<void> toggleVideo() async {
    final stream = localStream.value;
    if (stream != null) {
      final videoTracks = stream.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        final videoTrack = videoTracks.first;
        videoTrack.enabled = !videoTrack.enabled;

        Get.snackbar(
          'Caméra',
          videoTrack.enabled ? 'Activée' : 'Désactivée',
          duration: const Duration(seconds: 1),
        );
        update();
      }
    }
  }

  RTCVideoRenderer get localRenderer_ => localRenderer;
  RTCVideoRenderer get remoteRenderer_ => remoteRenderer;
}
