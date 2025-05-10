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
      setState(() => _sent = false);
      // inline errorText or snackbar if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // back arrow
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text('비밀번호 찾기'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 제목: 가운데, 아래쪽으로
                const SizedBox(height: 16),
                const Text(
                  '비밀번호 재설정 메일 전송',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // 이메일 입력
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 전송 버튼
                SizedBox(
                  width: 320,
                  child: ElevatedButton(
                    onPressed: _send,
                    child: Text(_sent ? '전송됨' : '전송하기'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
