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
  String? _errorText;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _errorText = '이메일을 입력해 주세요.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        _sent = true;
        _errorText = null;
      });
    } catch (_) {
      setState(() => _errorText = '전송에 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // ── 헤더: 뒤로가기 + 중앙 제목 ──
              Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      '비밀번호 찾기',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

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

              // 경고/완료 문구
              if (_errorText != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorText!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              if (_sent) ...[
                const SizedBox(height: 8),
                const Text(
                  '메일이 전송되었습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.green),
                ),
              ],

              const SizedBox(height: 32),

              // 전송 버튼
              SizedBox(
                width: 320,
                child: ElevatedButton(
                  onPressed: _sendReset,
                  child: Text(_sent ? '전송됨' : '전송하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
