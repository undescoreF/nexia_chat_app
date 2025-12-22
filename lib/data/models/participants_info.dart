class ParticipantInfo {
  final String uid;
  final String name;
  final String avatarUrl;

  ParticipantInfo({
    required this.uid,
    required this.name,
    required this.avatarUrl,
  });

  factory ParticipantInfo.fromMap(Map<String, dynamic> map) {
    return ParticipantInfo(
      uid: map['uid'],
      name: map['name'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'name': name, 'avatarUrl': avatarUrl};
  }
}
