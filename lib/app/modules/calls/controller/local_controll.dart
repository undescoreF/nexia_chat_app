import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../../data/providers/signaling_test.dart';
import '../../../../data/repositories/webrtc_test.dart';

enum CallState { idle, connecting, waiting, connected, error, ended }

class LocalCallController extends GetxController {
  final LocalSignalingProvider _signalingProvider = LocalSignalingProvider();

  late LocalWebRTCRepository _webrtcRepo;
  late TextEditingController serverIpController;
  late TextEditingController roomIdController;

  var callState = CallState.idle.obs;
  var localStream = Rxn<MediaStream>();
  var remoteStream = Rxn<MediaStream>();
  String? currentRoomId;
  String serverIp = '192.168.137.33';

  late RTCVideoRenderer localRenderer;
  late RTCVideoRenderer remoteRenderer;

  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    _initRenderers();
    serverIpController = TextEditingController(text: serverIp);
    roomIdController = TextEditingController();
  }

  @override
  void onClose() {
    serverIpController.dispose();
    roomIdController.dispose();
    _cleanup();
    super.onClose();
  }

  Future<void> _initRenderers() async {
    localRenderer = RTCVideoRenderer();
    remoteRenderer = RTCVideoRenderer();
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  Future<void> _ensureInitializedRepo() async {
    if (_isInitialized) return;

    _webrtcRepo = LocalWebRTCRepository(
      onRemoteStream: (MediaStream stream) {
        remoteStream.value = stream;
        remoteRenderer.srcObject = remoteStream.value;
        update();
      },
      onLocalIceCandidate: (candidate) {
        // envoi des ICE vers le signaling
        if (currentRoomId != null) {
          _signalingProvider.sendIceCandidate(candidate);
        }
      },
    );

    // Obtenir le flux local
    localStream.value = await _webrtcRepo.getLocalStream();
    localRenderer.srcObject = localStream.value;

    _isInitialized = true;
  }

  /// Démarrer un appel (appelant)
  Future<void> startCall(String roomId) async {
    try {
      callState.value = CallState.connecting;
      currentRoomId = roomId;

      await _ensureInitializedRepo();

      // Connexion signaling & listeners
      _signalingProvider.connect(roomId, serverIp);
      _setupSignalingListeners();

      // Créer l'offre
      final result = await _webrtcRepo.createOffer();
      if (result['success']) {
        // Offre envoyée
        _signalingProvider.sendOffer(result['offer']);
        callState.value = CallState.waiting;
      } else {
        throw Exception(result['error']);
      }
    } catch (e) {
      callState.value = CallState.error;
      Get.snackbar('Erreur', 'Impossible de démarrer l\'appel: $e');
    }
  }

  /// Rejoindre un appel (receveur)
  Future<void> joinCall(String roomId) async {
    try {
      callState.value = CallState.connecting;
      currentRoomId = roomId;

      await _ensureInitializedRepo();

      // Connexion signaling & listeners
      _signalingProvider.connect(roomId, serverIp);
      _setupSignalingListeners();
    } catch (e) {
      callState.value = CallState.error;
      Get.snackbar('Erreur', 'Impossible de rejoindre: $e');
    }
  }

  void _setupSignalingListeners() {
    // Éviter plusieurs listeners
    _signalingProvider.messageStream.listen((message) async {
      try {
        final data = json.decode(message);
        final type = data['type'];
        final payload = data['data'];

        switch (type) {
          case 'offer':
            await _handleOffer(payload);
            break;
          case 'answer':
            await _handleAnswer(payload);
            break;
          case 'ice-candidate':
            await _handleIceCandidate(payload);
            break;
          case 'join':
            //TODO
            break;
          case 'leave':
            // //TODO
            break;
          default:
            print('Type inconnu: $type');
        }
      } catch (e) {
        print('Erreur traitement message signaling: $e');
      }
    });
  }

  Future<void> _handleOffer(Map<String, dynamic> offer) async {
    try {
      await _ensureInitializedRepo();

      // createAnswer gère setRemoteDescription puis createAnswer
      final result = await _webrtcRepo.createAnswer(offer);
      if (result['success']) {
        _signalingProvider.sendAnswer(result['answer']);
        callState.value = CallState.connected;
      } else {
        throw Exception(result['error']);
      }
    } catch (e) {
      print('Erreur _handleOffer: $e');
      callState.value = CallState.error;
    }
  }

  Future<void> _handleAnswer(Map<String, dynamic> answer) async {
    try {
      await _webrtcRepo.setRemoteAnswer(answer);
      callState.value = CallState.connected;
    } catch (e) {
      print('Erreur _handleAnswer: $e');
    }
  }

  Future<void> _handleIceCandidate(Map<String, dynamic> candidate) async {
    try {
      await _webrtcRepo.addIceCandidate(candidate);
    } catch (e) {
      print('Erreur addIceCandidate: $e');
    }
  }

  Future<void> endCall() async {
    callState.value = CallState.ended;
    _signalingProvider.disconnect();
    _webrtcRepo.close();

    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
    localStream.value = null;
    remoteStream.value = null;
    currentRoomId = null;
    _isInitialized = false;
  }

  void _cleanup() {
    try {
      _signalingProvider.disconnect();
      _webrtcRepo.close();
      localRenderer.dispose();
      remoteRenderer.dispose();
    } catch (_) {}
    _isInitialized = false;
  }

  // getters
  RTCVideoRenderer get localRenderer_ => localRenderer;
  RTCVideoRenderer get remoteRenderer_ => remoteRenderer;
}
