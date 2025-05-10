
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nicknameController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  String gender = '';
  String error = '';
  bool isNicknameChecked = false;
  bool isEmailChecked = false;

  Future<void> checkNickname() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('nickname', isEqualTo: nicknameController.text.trim())
        .get();
    setState(() {
      isNicknameChecked = snapshot.docs.isEmpty;
      error = isNicknameChecked ? '사용 가능한 닉네임입니다.' : '이미 사용 중인 닉네임입니다.';
    });
  }

  Future<void> checkEmail() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: emailController.text.trim())
        .get();
    setState(() {
      isEmailChecked = snapshot.docs.isEmpty;
      error = isEmailChecked ? '사용 가능한 이메일입니다.' : '이미 사용 중인 이메일입니다.';
    });
  }

  Future<void> register() async {
    if (!isNicknameChecked || !isEmailChecked) {
      setState(() => error = '이메일과 닉네임 중복 확인을 해주세요.');
      return;
    }

    if (emailController.text.isEmpty ||
        passwordController.text.length < 10 ||
        nicknameController.text.isEmpty ||
        nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        gender.isEmpty) {
      setState(() => error = '모든 항목을 올바르게 입력해주세요.');
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim());

      await userCredential.user!.sendEmailVerification();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': emailController.text.trim(),
        'nickname': nicknameController.text.trim(),
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'gender': gender,
      });

      setState(() => error = '회원가입 완료! 이메일 인증을 진행해주세요.');
    } catch (e) {
      setState(() => error = '회원가입 중 오류가 발생했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    double fieldWidth = MediaQuery.of(context).size.width / 3;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('회원가입', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              SizedBox(
                width: fieldWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: '이메일(아이디)',
                        suffixIcon: TextButton(
                          onPressed: checkEmail,
                          child: const Text('중복 확인'),
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: '비밀번호 (10자 이상)'),
                      obscureText: true,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nicknameController,
                      decoration: InputDecoration(
                        labelText: '닉네임',
                        suffixIcon: TextButton(
                          onPressed: checkNickname,
                          child: const Text('중복 확인'),
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: '이름'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: '휴대전화'),
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (digits.length <= 11) {
                          String formatted = digits;
                          if (digits.length >= 3 && digits.length <= 7) {
                            formatted = '${digits.substring(0, 3)}-${digits.substring(3)}';
                          } else if (digits.length > 7) {
                            formatted = '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
                          }
                          phoneController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(offset: formatted.length),
                          );
                        }
                      },
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio<String>(
                          value: '남성',
                          groupValue: gender,
                          onChanged: (val) => setState(() => gender = val!),
                        ),
                        const Text('남성'),
                        const SizedBox(width: 16),
                        Radio<String>(
                          value: '여성',
                          groupValue: gender,
                          onChanged: (val) => setState(() => gender = val!),
                        ),
                        const Text('여성'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(error, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: register, child: const Text('회원가입')),
            ],
          ),
        ),
      ),
    );
  }
}
