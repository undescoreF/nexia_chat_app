// data/repositories/webrtc_test.dart
import 'package:flutter_webrtc/flutter_webrtc.dart';

typedef RemoteStreamCallback = void Function(MediaStream stream);
typedef IceCandidateCallback = void Function(Map<String, dynamic> candidate);

class LocalWebRTCRepository {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  final RemoteStreamCallback? onRemoteStream;
  final IceCandidateCallback? onLocalIceCandidate;

  LocalWebRTCRepository({this.onRemoteStream, this.onLocalIceCandidate});

  Future<RTCPeerConnection> _createPeerConnection() async {
    if (_peerConnection != null) return _peerConnection!;

    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ],
    };

    _peerConnection = await createPeerConnection(configuration);

    // Envoi des ICE via callback
    _peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
      if (candidate != null && onLocalIceCandidate != null) {
        onLocalIceCandidate!({
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        });
      }
    };

    // Gestion du stream distant
    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty && onRemoteStream != null) {
        onRemoteStream!(event.streams.first);
      }
    };

    return _peerConnection!;
  }

  /// Obtenir le flux local (créé une seule fois)
  Future<MediaStream> getLocalStream() async {
    if (_localStream != null) return _localStream!;

    final constraints = {
      'audio': true,
      'video': {'facingMode': 'user', 'width': 640, 'height': 480},
    };

    _localStream = await navigator.mediaDevices.getUserMedia(constraints);
    return _localStream!;
  }

  /// Ajouter les pistes locales à la peerConnection (idempotent)
  Future<void> addLocalTracksToPeer() async {
    await _createPeerConnection();
    if (_localStream != null) {
      for (final track in _localStream!.getTracks()) {
        // addTrack retourne un RTCRtpSender
        _peerConnection!.addTrack(track, _localStream!);
      }
    }
  }

  /// Créer offer (utilise la peerConnection existante)
  Future<Map<String, dynamic>> createOffer() async {
    try {
      await _createPeerConnection();
      _localStream ??= await getLocalStream();
      await addLocalTracksToPeer();

      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      return {
        'success': true,
        'offer': {'type': offer.type, 'sdp': offer.sdp},
        'localStream': _localStream,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Créer answer à partir d'une offer distante (ne recrée pas la peer)
  Future<Map<String, dynamic>> createAnswer(
    Map<String, dynamic> remoteOffer,
  ) async {
    try {
      await _createPeerConnection();
      _localStream ??= await getLocalStream();
      await addLocalTracksToPeer();

      // Set remote offer
      final remoteDesc = RTCSessionDescription(
        remoteOffer['sdp'],
        remoteOffer['type'],
      );
      await _peerConnection!.setRemoteDescription(remoteDesc);

      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      return {
        'success': true,
        'answer': {'type': answer.type, 'sdp': answer.sdp},
        'localStream': _localStream,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Appliquer une answer distante (appelant reçoit answer)
  Future<void> setRemoteAnswer(Map<String, dynamic> remoteAnswer) async {
    if (_peerConnection != null) {
      final desc = RTCSessionDescription(
        remoteAnswer['sdp'],
        remoteAnswer['type'],
      );
      await _peerConnection!.setRemoteDescription(desc);
    }
  }

  /// Ajouter ICE candidate distant
  Future<void> addIceCandidate(Map<String, dynamic> candidate) async {
    if (_peerConnection != null && candidate['candidate'] != null) {
      final rtcCandidate = RTCIceCandidate(
        candidate['candidate'],
        candidate['sdpMid'],
        candidate['sdpMLineIndex'],
      );
      await _peerConnection!.addCandidate(rtcCandidate);
    }
  }

  /// Fermer et nettoyer
  void close() {
    try {
      _localStream?.getTracks().forEach((t) => t.stop());
      _localStream = null;
      _peerConnection?.close();
      _peerConnection = null;
    } catch (_) {}
  }
}
