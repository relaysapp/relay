import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('로그인'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 이메일
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
              // 비밀번호
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
              // 비밀번호 찾기
              SizedBox(
                width: 320,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(c, '/reset_password'),
                  child: const Text('비밀번호 찾기'),
                ),
              ),
              const SizedBox(height: 8),
              // 회원가입
              SizedBox(
                width: 320,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(c, '/register'),
                  child: const Text('회원가입'),
                ),
              ),
              const SizedBox(height: 8),
              // 로그인
              SizedBox(
                width: 320,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: 로그인 로직
                  },
                  child: const Text('로그인'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
