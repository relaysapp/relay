
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  String? _message;

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _message = "이메일을 입력해주세요.");
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() => _message = "비밀번호 재설정 메일을 전송했습니다.");
    } catch (e) {
      setState(() => _message = "오류 발생: 이메일을 다시 확인해주세요.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Text(
                      "비밀번호 찾기",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 280,
                  child: TextField(
                    controller: _emailController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      labelStyle: TextStyle(fontSize: 14),
                      contentPadding: EdgeInsets.only(bottom: 6),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(width: 1.2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _sendResetEmail,
                  child: const Text('비밀번호 재설정 메일 전송'),
                ),
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_message!, style: const TextStyle(color: Colors.blue)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
