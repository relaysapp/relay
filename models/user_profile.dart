class UserProfile {
  final String uid;
  final String email;
  final String nickname;
  final String gender;

  UserProfile({
    required this.uid,
    required this.email,
    required this.nickname,
    required this.gender,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nickname': nickname,
      'gender': gender,
    };
  }

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      email: map['email'],
      nickname: map['nickname'],
      gender: map['gender'],
    );
  }
}
