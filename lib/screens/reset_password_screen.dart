import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final e = _emailCtrl.text.trim();
    if (e.isEmpty) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: e);
      setState(() => _sent = true);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('전송 실패')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('비밀번호 찾기')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('비밀번호 재설정 메일 전송', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 24),
              SizedBox(
                width: 320,
                child: TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: '이메일', border: UnderlineInputBorder()),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 320,
                child: ElevatedButton(onPressed: _send, child: Text(_sent ? '전송됨' : '전송하기')),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
