import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  String message = '';

  Future<void> resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      setState(() => message = '비밀번호 재설정 이메일이 전송되었습니다.');
    } catch (e) {
      setState(() => message = '오류 발생: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('비밀번호 재설정')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: '이메일')),
            ElevatedButton(onPressed: resetPassword, child: const Text('비밀번호 재설정 메일 보내기')),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: Colors.green)),
          ]),
        ));
  }
}
