import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignalingProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ENVOYER une offre WebRTC
  Future<void> sendOffer(String roomId, Map<String, dynamic> offer) async {
    await _firestore.collection('webrtc_calls').doc(roomId).set({
      'offer': offer,
      'callerId': FirebaseAuth.instance.currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'waiting',
    });
  }

  /// ENVOYER une réponse WebRTC
  Future<void> sendAnswer(String roomId, Map<String, dynamic> answer) async {
    await _firestore.collection('webrtc_calls').doc(roomId).update({
      'answer': answer,
      'status': 'active',
      'answererId': FirebaseAuth.instance.currentUser!.uid,
    });
  }

  /// ÉCOUTER les changements d'une salle - TYPAGE CORRIGÉ
  Stream<DocumentSnapshot> listenToCall(String roomId) {
    return _firestore.collection('webrtc_calls').doc(roomId).snapshots();
  }
}
