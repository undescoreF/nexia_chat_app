import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../app/services/webrtc_service.rtc.dart';
import '../providers/call_provider.dart';

class CallRepository {
  final CallProvider callProvider_;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  RemoteStreamCallback? onRemoteStream;

  CallRepository(this.callProvider_, {this.onRemoteStream});
  final String username = dotenv.env['NAT_USERNAME']!;
  final String usercred = dotenv.env['NAT_CRED']!;

  Future<void> initPeerConnection(String myId, String otherId) async {
    if (_peerConnection != null) {
      await dispose();
    }

    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
        {'urls': 'stun:stun2.l.google.com:19302'},

        {
          'urls': [
            'turn:global.relay.metered.ca:80',
            'turn:global.relay.metered.ca:443',
            'turn:global.relay.metered.ca:443?transport=tcp',
          ],
          'username': username,
          'credential': usercred,
        },
      ],
      'iceCandidatePoolSize': 10,
    };

    _peerConnection = await createPeerConnection(config);

    _peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) async {
      if (candidate != null) {
        await callProvider_.sendIceCandidate(myId, otherId, {
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        });
      }
    };

    _peerConnection!.onTrack = (event) {
      debugPrint("[RECEVEUR] onTrack déclenché !");
      debugPrint("Nombre de streams : ${event.streams.length}");
      if (event.streams.isNotEmpty) {
        final stream = event.streams.first;
        debugPrint(
          "Pistes reçues : ${stream.getTracks().map((t) => t.kind).toList()}",
        );
        onRemoteStream?.call(stream);
      }
    };
  }

  Future<MediaStream> getLocalStream({bool withVideo = false}) async {
    //  Vérifie que le flux est utilisable
    if (_localStream != null && _localStream!.getTracks().isNotEmpty) {
      return _localStream!;
    }
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': withVideo,
    });
    return _localStream!;
  }

  Future<RTCSessionDescription> createOffer(String myId, String otherId) async {
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    await callProvider_.sendOffer(myId, otherId, offer.sdp!);
    return offer;
  }

  Future<RTCSessionDescription> createAnswer(
    RTCSessionDescription remoteOffer,
    String myId,
    String otherId,
  ) async {
    await _peerConnection!.setRemoteDescription(remoteOffer);
    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    await callProvider_.sendAnswer(myId, otherId, answer.sdp!);
    return answer;
  }

  Future<void> setRemoteAnswer(RTCSessionDescription answer) async {
    await _peerConnection!.setRemoteDescription(answer);
  }

  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    await _peerConnection!.addCandidate(candidate);
  }

  Future<void> addLocalTracks(MediaStream stream) async {
    //print("Ajout de ${stream.getTracks().length} pistes locales");
    for (var track in stream.getTracks()) {
    //  print("Ajout de la piste : ${track.kind}");
      _peerConnection!.addTrack(track, stream);
    }
  }

  Future<void> dispose() async {
    _localStream?.getTracks().forEach((t) => t.stop());
    await _peerConnection?.close();
    _peerConnection = null;
    _localStream = null;
  }
}
