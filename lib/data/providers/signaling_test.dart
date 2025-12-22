import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class LocalSignalingProvider {
  WebSocketChannel? _channel;
  String? _currentRoomId;

  /// SE CONNECTER à une salle
  void connect(String roomId, String serverIp) {
    _currentRoomId = roomId;
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://$serverIp:8000/ws/$roomId'),
    );
  }

  /// ENVOYER un message
  void sendMessage(String type, dynamic data) {
    if (_channel != null) {
      final message = json.encode({
        'type': type,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      _channel!.sink.add(message);
    }
  }

  /// ENVOYER une offre SDP
  void sendOffer(Map<String, dynamic> offer) {
    sendMessage('offer', offer);
  }

  /// ENVOYER une réponse SDP
  void sendAnswer(Map<String, dynamic> answer) {
    sendMessage('answer', answer);
  }

  /// ENVOYER un candidat ICE
  void sendIceCandidate(Map<String, dynamic> candidate) {
    sendMessage('ice-candidate', candidate);
  }

  /// ÉCOUTER les messages
  Stream get messageStream {
    return _channel?.stream ?? const Stream.empty();
  }

  /// DÉCONNECTER
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _currentRoomId = null;
  }
}
