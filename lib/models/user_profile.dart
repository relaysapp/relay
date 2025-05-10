class UserProfile {
  final String email;
  final String nickname;
  final String gender;
  final int level;
  final int exp;

  UserProfile({
    required this.email,
    required this.nickname,
    required this.gender,
    this.level = 1,
    this.exp = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nickname': nickname,
      'gender': gender,
      'level': level,
      'exp': exp,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      email: map['email'] ?? '',
      nickname: map['nickname'] ?? '',
      gender: map['gender'] ?? '',
      level: map['level'] ?? 1,
      exp: map['exp'] ?? 0,
    );
  }
}
