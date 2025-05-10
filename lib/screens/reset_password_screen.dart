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
      // AppBar 로 화살표 자동 표시
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          '비밀번호 찾기',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(builder: (ctx, cons) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: cons.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                const SizedBox(height: 16),
                if (_errorText != null) ...[
                  Text(
                    _errorText!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_sent) ...[
                  const Text(
                    '메일이 전송되었습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.green),
                  ),
                  const SizedBox(height: 16),
                ],
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
        );
      }),
    );
  }
}
