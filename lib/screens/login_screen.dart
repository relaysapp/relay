// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim();
    final pwd = _passwordCtrl.text;
    if (email.isEmpty || pwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 모두 입력해 주세요.')),
      );
      return;
    }
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: pwd);
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? '로그인에 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 앱바 대신 화면 자체 레이아웃으로 구성
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. 상단 로그인 텍스트
              const Text(
                '로그인',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // 2. 이메일 입력란
              SizedBox(
                width: 320,
                child: TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    border: UnderlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. 비밀번호 입력란
              SizedBox(
                width: 320,
                child: TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    border: UnderlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 4. 로그인 버튼
              SizedBox(
                width: 320,
                child: ElevatedButton(
                  onPressed: _signIn,
                  child: const Text('로그인'),
                ),
              ),
              const SizedBox(height: 16),

              // 5. 회원가입 버튼
              SizedBox(
                width: 320,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text('회원가입'),
                ),
              ),
              const SizedBox(height: 16),

              // 6. 비밀번호 찾기 버튼
              SizedBox(
                width: 320,
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/reset_password'),
                  child: const Text('비밀번호 찾기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
