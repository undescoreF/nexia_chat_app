import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../providers/signalingProvider.dart';

class WebRTCRepository {
  final SignalingProvider _signalingProvider;

  WebRTCRepository(this._signalingProvider);

  /// INITIALISER un appel (côté appelant)
  Future<Map<String, dynamic>> createCall(String roomId) async {
    try {
      // Créer la connexion WebRTC
      final peerConnection = await _createPeerConnection();

      // Créer l'offre
      final offer = await peerConnection.createOffer();
      await peerConnection.setLocalDescription(offer);

      // Envoyer via Firebase
      await _signalingProvider.sendOffer(roomId, {
        'type': offer.type,
        'sdp': offer.sdp,
      });

      return {'success': true, 'peerConnection': peerConnection};
    } catch (e) {
      throw Exception("Erreur création appel: ${e.toString()}");
    }
  }

  /// REJOINDRE un appel (côté receveur)
  Future<Map<String, dynamic>> joinCall(
    String roomId,
    Map<String, dynamic> remoteOffer,
  ) async {
    try {
      //  Créer la connexion WebRTC
      final peerConnection = await _createPeerConnection();

      //  Configurer l'offre distante
      await peerConnection.setRemoteDescription(
        RTCSessionDescription(remoteOffer['sdp'], remoteOffer['type']),
      );

      // Créer la réponse
      final answer = await peerConnection.createAnswer();
      await peerConnection.setLocalDescription(answer);

      // Envoyer la réponse
      await _signalingProvider.sendAnswer(roomId, {
        'type': answer.type,
        'sdp': answer.sdp,
      });

      return {'success': true, 'peerConnection': peerConnection};
    } catch (e) {
      throw Exception("Erreur rejoindre appel: ${e.toString()}");
    }
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    // Configuration WebRTC
    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    return await createPeerConnection(configuration);
  }
}
