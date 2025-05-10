import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailVerifyScreen extends StatelessWidget {
  const EmailVerifyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('이메일 인증')),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('이메일로 인증 메일을 보냈습니다.'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              await user?.reload();
              if (user != null && user.emailVerified) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
            child: const Text('인증 완료 확인'),
          ),
        ]),
      ),
    );
  }
}