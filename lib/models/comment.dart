import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String content;
  final String nickname;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.content,
    required this.nickname,
    required this.timestamp,
  });

  factory Comment.fromMap(String id, Map<String, dynamic> data) {
    return Comment(
      id: id,
      content: data['content'] as String,
      nickname: data['nickname'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'nickname': nickname,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}