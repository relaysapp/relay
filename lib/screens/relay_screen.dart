import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';

class RelayScreen extends StatefulWidget {
  const RelayScreen({super.key});
  @override
  State<RelayScreen> createState() => _RelayScreenState();
}

class _RelayScreenState extends State<RelayScreen> {
  final _ctrl = TextEditingController();

  Future<void> _addComment() async {
    if (_ctrl.text.trim().isEmpty) return;
    await FirebaseFirestore.instance.collection('comments').add({
      'content': _ctrl.text.trim(),
      'nickname': '현재유저닉네임', // 나중에 실제 닉네임으로 교체
      'timestamp': FieldValue.serverTimestamp(),
    });
    _ctrl.clear();
  }

  Stream<List<Comment>> _comments() {
    return FirebaseFirestore.instance
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Comment.fromMap(doc.id, doc.data()!)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('릴레이 댓글')),
      body: Column(children: [
        Expanded(
          child: StreamBuilder<List<Comment>>(
            stream: _comments(),
            builder: (context, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final list = snap.data!;
              return ListView.builder(
                reverse: true,
                itemCount: list.length,
                itemBuilder: (c, i) {
                  final cm = list[i];
                  return ListTile(
                    title: Text(cm.content),
                    subtitle: Text('${cm.nickname} • ${cm.timestamp.toLocal()}'),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                decoration: const InputDecoration(hintText: '댓글을 입력하세요...', border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _addComment, child: const Text('작성')),
          ]),
        ),
      ]),
    );
  }
}