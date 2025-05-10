import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final emailController = TextEditingController();
  String message = '';

  Future<void> _sendReset() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      setState(() => message = '비밀번호 재설정 메일을 보냈습니다.');
    } catch (e) {
      setState(() => message = '오류 발생: 이메일을 확인해주세요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width / 3;
    return Scaffold(
      appBar: AppBar(title: const Text('비밀번호 찾기')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('비밀번호 재설정', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              SizedBox(
                width: width,
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: '이메일'),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Text(message, style: const TextStyle(color: Colors.blue)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _sendReset, child: const Text('전송')),
            ],
          ),
        ),
      ),
    );
  }
}