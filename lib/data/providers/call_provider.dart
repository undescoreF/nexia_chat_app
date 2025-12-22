import 'package:cloud_firestore/cloud_firestore.dart';

class CallProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get calls => _firestore.collection('calls');

  Stream<DocumentSnapshot> watchCall(String myId, String otherId) {
    return calls.doc(getCallDocId(myId, otherId)).snapshots();
  }

  Future<void> sendOffer(String myId, String otherId, String sdp) {
    return calls.doc(getCallDocId(myId, otherId)).set({
      'offer': sdp,
      'sdpSenderId': myId,
      'status': 'ringing',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> sendAnswer(String myId, String otherId, String sdp) {
    return calls.doc(getCallDocId(myId, otherId)).set({
      'answer': sdp,
      'sdpSenderId': myId,
    }, SetOptions(merge: true));
  }

  Future<void> sendIceCandidate(
    String myId,
    String otherId,
    Map<String, dynamic> candidate,
  ) {
    return calls.doc(getCallDocId(myId, otherId)).update({
      'iceCandidates': FieldValue.arrayUnion([
        {...candidate, 'iceSenderId': myId},
      ]),
    });
  }

  Future<DocumentSnapshot> getOffer(String myId, String otherId) {
    return calls.doc(getCallDocId(myId, otherId)).get();
  }

  Future<void> updateCallStatus(String myId, String otherId, String status) {
    return calls.doc(getCallDocId(myId, otherId)).update({'status': status});
  }

  Future<void> createCall(String myId, String otherId) async {
    final callDocId = getCallDocId(myId, otherId);
    await calls.doc(callDocId).set({
      'status': 'ringing',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'callerId': myId,
      'calleeId': otherId,
      'sdpSenderId': myId,
      'offer': '',
      'answer': '',
      'iceCandidates': [],
    }, SetOptions(merge: true));
  }

  String getCallDocId(String id1, String id2) {
    final sortedIds = [id1, id2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }
}
