import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import 'email_verify_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  String _gender = '남';

  final _auth = FirebaseAuth.instance;

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final nickname = _nicknameController.text.trim();

    if (password.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("비밀번호는 최소 10자 이상이어야 합니다.")),
      );
      return;
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': email,
        'nickname': nickname,
        'gender': _gender,
      });

      await user.sendEmailVerification();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EmailVerifyScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("회원가입 오류: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("회원가입")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "이메일"),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "비밀번호"),
            ),
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(labelText: "닉네임"),
            ),
            DropdownButtonFormField(
              value: _gender,
              items: const [
                DropdownMenuItem(value: '남', child: Text('남')),
                DropdownMenuItem(value: '여', child: Text('여')),
                DropdownMenuItem(value: '기타', child: Text('기타')),
              ],
              onChanged: (value) {
                setState(() {
                  _gender = value.toString();
                });
              },
              decoration: const InputDecoration(labelText: "성별"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text("회원가입"),
            )
          ],
        ),
      ),
    );
  }
}
