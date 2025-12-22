import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

import '../../data/repositories/call_repository.dart';

typedef RemoteStreamCallback = void Function(MediaStream stream);

class WebRTCService {
  late CallRepository _callRepository;
  MediaStream? localStream;
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  var isRemoteRendererInitialized = false.obs;
  var isLocalRendererInitialized = false.obs;

  bool _isInitialized = false;
  bool _renderersInitialized = false;
  WebRTCService(CallRepository callRepository) {
    _callRepository = callRepository;
    _initRemoteRenderer();
  }

  Future<void> _initRemoteRenderer() async {
    if (_renderersInitialized) return;
    await remoteRenderer.initialize();
    isRemoteRendererInitialized.value = true;
    await localRenderer.initialize();
    isLocalRendererInitialized.value = true;
    _renderersInitialized = true;
  }

  /// Initialise l'appel et le PeerConnection
  Future<void> initCall({
    required String myId,
    required String otherId,
    bool withVideo = false,
    RemoteStreamCallback? onRemoteStream,
  }) async {
    if (_isInitialized) {
      await endCall();
    }

    _callRepository.onRemoteStream = (stream) {
      remoteRenderer.srcObject = stream;
      stream.getAudioTracks().forEach((track) => track.enabled = true);
      if (onRemoteStream != null) onRemoteStream(stream);
    };

    await _callRepository.initPeerConnection(myId, otherId);
    localStream = await _callRepository.getLocalStream(withVideo: withVideo);
    await _callRepository.addLocalTracks(localStream!);
    localRenderer.srcObject = localStream;

    _isInitialized = true;
  }

  /// Créer une offre (appelant)
  Future<RTCSessionDescription> createOffer({
    required String myId,
    required String otherId,
  }) async {
    final offer = await _callRepository.createOffer(myId, otherId);
    return offer;
  }

  /// Accepter une offre distante et créer une réponse (receveur)
  Future<RTCSessionDescription> acceptCall(
    RTCSessionDescription remoteOffer, {
    required String myId,
    required String otherId,
  }) async {
    await initCall(myId: myId, otherId: otherId, withVideo: true);
    //  creer réponse
    final answer = await _callRepository.createAnswer(
      remoteOffer,
      myId,
      otherId,
    );
    return answer;
  }

  /// Appliquer une réponse distante (appelant reçoit answer)
  Future<void> setRemoteAnswer(RTCSessionDescription answer) async {
    await _callRepository.setRemoteAnswer(answer);
  }

  /// Ajouter ICE candidate distante
  Future<void> addRemoteIceCandidate(RTCIceCandidate candidate) async {
    await _callRepository.addIceCandidate(candidate);
  }

  /// Terminer l'appel
  Future<void> endCall() async {
    try {
      localStream?.getTracks().forEach((t) => t.stop());
      localStream = null;
      remoteRenderer.srcObject = null;
      localRenderer.srcObject = null;
      await _callRepository.dispose();
    } catch (e) {
      print("Erreur lors de la fermeture de l'appel: $e");
    } finally {
      _isInitialized = false;
    }
  }
}
