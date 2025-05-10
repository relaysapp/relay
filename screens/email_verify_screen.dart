import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class EmailVerifyScreen extends StatefulWidget {
  const EmailVerifyScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends State<EmailVerifyScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  Future<void> _checkVerification() async {
    await user.reload();
    if (user.emailVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("아직 이메일 인증이 완료되지 않았습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("이메일 인증")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("가입하신 이메일을 확인하고 인증해주세요."),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkVerification,
              child: const Text("인증 완료했어요"),
            )
          ],
        ),
      ),
    );
  }
}
