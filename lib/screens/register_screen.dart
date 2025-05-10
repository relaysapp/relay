import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _nickCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  Timer? _emailDebounce, _nickDebounce;
  bool _emailChecked = false, _emailExists = false;
  bool _nickChecked = false, _nickExists = false;
  bool _passwordsMatch = true;
  String? _passwordError, _gender;

  @override
  void initState() {
    super.initState();
    _confirmCtrl.addListener(_checkPasswordMatch);
  }

  @override
  void dispose() {
    _emailDebounce?.cancel();
    _nickDebounce?.cancel();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _nameCtrl.dispose();
    _nickCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _checkPasswordMatch() {
    setState(() {
      _passwordsMatch = _passwordCtrl.text == _confirmCtrl.text;
      _passwordError =
          _passwordsMatch ? null : '비밀번호가 일치하지 않습니다.';
    });
  }

  // 중복 확인 로직 생략 (이전과 동일)

  Future<void> _register() async {
    // 유효성 검사, Firestore 저장 등 (이전과 동일)
  }

  void _showError(String m) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text('회원가입'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1) 이메일
                _buildField('이메일', _emailCtrl,
                    suffix: TextButton(
                        onPressed: _checkEmailDup,
                        child: const Text('중복확인'))),
                const SizedBox(height: 16),
                // 2) 비밀번호
                _buildField('비밀번호', _passwordCtrl, obscure: true),
                const SizedBox(height: 16),
                // 3) 비밀번호 확인
                _buildField('비밀번호 확인', _confirmCtrl,
                    obscure: true, errorText: _passwordError),
                const SizedBox(height: 16),
                // 4) 이름
                _buildField('이름', _nameCtrl),
                const SizedBox(height: 16),
                // 5) 닉네임
                _buildField('닉네임', _nickCtrl,
                    suffix: TextButton(
                        onPressed: _checkNickDup,
                        child: const Text('중복확인'))),
                const SizedBox(height: 16),
                // 6) 휴대전화
                _buildField('휴대전화', _phoneCtrl,
                    keyboard: TextInputType.phone),
                const SizedBox(height: 16),
                // 7) 성별
                _buildGenderSelector(),
                const SizedBox(height: 32),
                // 가입하기 버튼
                SizedBox(
                  width: 320,
                  child: ElevatedButton(
                    onPressed: _register,
                    child: const Text('가입하기'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // _buildField, _buildGenderSelector 등은 이전과 동일하게 유지하세요.
}
