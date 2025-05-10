import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ... 기존 이메일/비밀번호 필드 및 버튼 생략 ...
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(c, '/reset_password');
                    },
                    child: const Text('비밀번호 찾기'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // 로그인 로직
                    },
                    child: const Text('로그인'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(c, '/register');
                },
                child: const Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
